#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *

#let article = (
  authors: ("alex",),
  title: "Beautifully simple parallelism in C",
  html-title: "Beautifully simple parallelism in C",
  summary: "Rayon-like data-parallelism for C: fearless concurrency, for recursive functions, with work stealing"
)

#metadata(article) <feed-ent>

#simple-page(
  gen-table-of-contents: true,
  article.html-title
)[

#html-opt-elem("header", (:), section[
  #title(article.title)

  #sized-p(small-font-size)[
    #rev-and-authors(article.authors)
  ]
])

#section[
    If you have programmed rust, you probably heard of `rayon`, the fearless parallelism library:
    ```rs
    fn sum_of_squares(input: &[i32]) -> i32 {
        input.par_iter()
             .map(|&i| i * i)
             .sum()
    }
    ```

    The parallel runtime needs to expose only one single function: `join(a: fn(), b: fn())`.

    This function enqueues task b for work, then immediately executes task a, and then either executes task b, or something else, until task b is done,
    returning only after both functions are done.

    This means, you can write parallel sum in just 6 lines of code:
    ```rs
    fn par_sum(inp: &[i32]) -> i32 {
        if (inp.len <= 1) return inp.first().unwrap_or(0);
        let half = inp.len() / 2;
        let (a,b) = join(|| par_sum(inp[0..half]), || par_sum(inp[half..]));
        return a + b;
    }
    ```

    See #flink("https://smallcultfollowing.com/babysteps/blog/2015/12/18/rayon-data-parallelism-in-rust/")[This post] of the  rayon author describing how the early versions of rayon work. Modern rayon still uses basically the same system.
]

#section[
    The issue with the `par_sum` example from above, is that it's slow in practice, because of parallelism overhead, and modern CPU cores want to do many things at once.

    So, we can introduce a `Joiner` trait: (pseudocode)
    ```rs
    trait Joiner {
        fn join<A, B>(a: fn() -> A, b: fn() -> B) -> (A, B);
    }
    ```

    and have both a serial and a parallel joiner:
    ```rs
    struct Serial;
    impl Joiner for Serial {
        fn join<A, B>(a: fn() -> A, b: fn() -> B) -> (A, B) {
            return (a(), b());
        }
    }

    struct Par;
    impl Joiner for Par { ... }
    ```

    Then, we can abstract our function over a joiner:
    ```rs
    fn par_sum<J: Joiner>(inp: &[i32]) -> i32 {
        if (J == Par && inp.len <= 1024)
            // "serialize": process remaining elements serially
            return par_sum::<Serial>(inp);

        if (inp.len <= 1)
            return inp.first().unwrap_or(0);

        let half = inp.len() / 2;
        let (a,b) = J::join(|| par_sum(inp[0..half]),
                            || par_sum(inp[half..]));
        return a + b;
    }
    ```
]

#section[
    Now, after some compiler passes:
    ```rs
    fn par_sum_serial(inp: &[i32]) -> i32 {
        if (inp.len <= 1)
            return inp.first().unwrap_or(0);

        let half = inp.len() / 2;
        let a = par_sum_serial(inp[0..half]);
        let b = par_sum_serial(inp[half..]);
        return a + b;
    }

    fn par_sum_par(inp: &[i32]) -> i32 {
        if (inp.len <= 1024)
            // "serialize": process remaining elements serially
            return par_sum_serial(inp);

        let half = inp.len() / 2;
        let (a,b) = par_join(|| par_sum_par(inp[0..half]),
                             || par_sum_par(inp[half..]));
        return a + b;
    }
    ```

    And now, you might think: Great! Now the compiler just convers the serial variant to a loop, and we're done!

    Except. LLVM doesn't really. #link("https://godbolt.org/z/1ebj4zjEh")[See for yourself].

    gcc however, seems to kindof #link("https://godbolt.org/z/vYqv3snzs")[inline a few recursion levels], but it's still far from optimal.
]

#section[
    == So how did I implement this in C?
    ```c
    mh_par_def(int, sum, int* items; size_t first; size_t len, {
      mh_par_descr(
          "sum [%zu:%zu]", args->first, args->len + args->first);

      if (args->len == 0)
        return 0;
      if (args->len == 1)
        return args->items[args->first];

      if (args->len <= 512)
        mh_par_serialize();

      size_t half = args->len / 2;

      // clang-format off
      int a, b;
      mh_par_join(
          mh_par_f(&a, sum, .items = args->items, .first = args->first,        .len = half),
          mh_par_f(&b, sum, .items = args->items, .first = args->first + half, .len = args->len - half));
      // clang-format on

      return a + b;
    });

    ...

    mh_par_runtime* rt = mh_par_new((mh_par_opts) {
        .numThreads = 4,
        .ingestQueueCap = 256,
        .perThreadQueueCap = 256,
    });

    int res = mh_par_run(rt, sum, .items = items, .len = sizeof(items) / sizeof(*items));
    ```

    - `mh_par_def` defines an argument type struct, the `void sum(void*)`, and a second serial variant: `void sum_serial(void*)`. It also creates a tracy zone for the parallel variant, which can be named with `mh_par_descr`.
    - `mh_par_serialize` tells all following `mh_par_join` to be serial instead.
    - `mh_par_join` and `mh_par_f` are macros, that together either call the runtime primitive `mh_par_do_join(sum, &_a, sum, &_b)`, or, if serialized, call the `sum_serial` variants directly.

    This results in roughly the same effect as the Rust pseudocode.
]

#section[
    == So how does it work?
    Each thread in the runtime has a local work locked ring-buffer (or better), and the runtime has one queue for new tasks.

    A thread appends its own tasks to the end of the local ring-buffer, and pops it from the end.

    Work stealers always search for tasks at the beginning of other thread's ring-buffers instead.

    ```c
    _Thread_local struct { ... } currentThread;

    void mh_par_do_join(void (*fA)(void*), void* argA, void (*fB)(void*), void* argB)
    {
        thread* selfT = currentThread.runtime.threads[currentThread.id];
        task bTask = (task){ fB, argB, .done = atomic() };
        locked_ringbuf_addBack(selfT->workQueue, &bTask);

        fA(argA);

        task* task;
        if ((task = locked_ringbuf_removeBack(selfT->workQueue)) {
            // if there is any task on the work queue at all, it is always task B
            debug_assert(task == &bTask);

            fB(argB);
            return;
        }
        else {
            // No task found on local work queue, meaning another thread already stole it.
            // Make ourselves busy until the task is done
            while (!atomic_load(&bTask.done))
            {
                makeBusy();
            }
        }
    }

    void makeBusy(void) {
        task* t = findWork();
        if (t) {
            t->f(t->arg);
            atomic_store(&t->done, true);
        } else {
            sched_yield();
        }
    }

    task* findWork(void) {
        thread* selfT = currentThread.runtime.threads[currentThread.id];
        task* task;

        // prefer work from our own buffer
        if ((task = locked_ringbuf_removeBack(selfT->workQueue, &task)))
            return task;

        // next, try stealing work
        if ((task = steal()))
            return task;

        // otherwise, start a new task that was enqueued into the runtime
        return bounded_mpmc_dequeue(currentThread.runtime.ingestQueue);
    }

    task* steal(void) {
        thread* selfT = currentThread.runtime.threads[currentThread.id];
        size_t start = prng_next(&currentThread.rng);
        for (size_t i = 0; i < currentThread.runtime.numThreads; i ++) {
            size_t th = (i + start) % currentThread.runtime.numThreads;
            if (th == selfT.id)
                continue;

            task* t;
            // try stealing task from the beginning of the thread's work queue
            if ((t = locked_ringbuf_removeFront(currentThread.runtime.threads[th], &task)))
                return t;
        }
    }

    void workerThread(void) {
        for (;;)
            makeBusy();
    }
    ```
]

#section[
    It is imprtant that we always steal from the front, and threads process from their own end.
    Otherwise, you get bad caching in the task functions, and memory explodes.

    // TODO ^^^ vizualize this

    So far, I haven't had issues with the fact that the local work queues are blocking.
    Since we always steal from random threads, and not all workers finish at the same time, so don't steal at the same time,
    congestion during heavy processing is rare, and you only see congestion when starting work, or when there are more workers than there is work left.

    This can be improved by making threads back off when they didn't find work.
]

#section[
    == Results
    #context wimage(res-path()+"article-beautifully-simple-parallelism/flamegraph-sum-1.png", width:100%, alt:"Tracy flamegraph of sum parallelized to multiple threads")
]
#section[
    When turning on successful-lock-acquiry-vizualization in tracy, you can see where workstealing happens (the green blocks that are not in the same row as most other):
    #context wimage(res-path()+"article-beautifully-simple-parallelism/flamegraph-sum-workStealing.png", width:100%, alt:"Tracy flamegraph of sum parallelized to multiple threads, showing workstealing")
]
#section[
    Parallelized merge-sort shows that there is a lot of congestion at the end, which happens because there is more threads than tasks, but it doesn't seem to affect performance too greatly. This is fixable.

    #context wimage(res-path()+"article-beautifully-simple-parallelism/flamegraph-mergeSort.png", width:100%, alt:"Tracy flamegraph of merge-sort parallelized to multiple threads, showing heavy lock congestion at the end")
]

#section[
    == Try it out
    You can find my implementation #flink("https://codeberg.org/alex-s168/much.heap")[here], but remember to follow that repositories license: for now, evaluaton purposes only!
]


]
