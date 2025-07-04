#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *

#simple-page(
  gen-table-of-contents: true
)[

#section[
  #title[Approaches to pattern matching in compilers]

  #sized-p(small-font-size)[
    Written by alex_s168
  ]
]

#if is-web {section[
  Note that the #min-pdf-link[PDF Version] of this page might look a bit better styling wise.
]}

#section[
  = Introduction
  Compilers often have to deal with find-and-replace inside the compiler IR (intermediate representation).

  Common use cases for pattern matching in compilers:
  - "peephole optimizations": the most common kind of optimization in compilers.
    They find a short sequence of code and replace that with some other code,
    for example replacing ```c x & 1 << b``` with a bit test.
  - finding a sequence of operations for complex optimization passes to operate on:
    advanced compilers have complex operations that can't really be performed with
    simple IR operation replacements, and instead requires complex logic.
    Patterns are used here to find operation sequences where those optimizations
    are applicable, and also to extract details inside that sequence.
  - code generation: converting the IR to machine code / VM bytecode.
    A compiler needs to find operations (or sequences of operations)
    inside the IR, and "replace" them with machine code.
]

#section[
  = Simplest Approach
  Currently, most compilers mostly do this inside the compiler's source code.
  For example, in MLIR, *most* pattern matches are performed in C++ code.

  The only advantage to this approach is that it will reduce compiler development time
  if the compiler only needs to match a few patterns.
]

#section[
  == Disadvantages
  Doing pattern matching inside the compiler's source code has many disadvantages.

  I strongly advertise against doing pattern matching this way.

  \
  Some (but not all) disadvantages:
  - debugging pattern matches can be hard
  - IR rewrites need to be tracked manually (for debugging)
  - verbose and hardly readable pattern matching code
  - overall error-prone

  I myself did pattern matching this way in my old compiler backend,
  and I speak from experience when I say that this approach sucks.
]

#section[
  = Pattern Matching DSLs
  A custom language for describing IR patterns and IR rewrites.

  I will put this into the category of "structured pattern matching".
]

#section[
  An example is Cranelift's ISLE:
  #context html-frame[```isle
  ;; x ^ x == 0.
  (rule (simplify (bxor (ty_int ty) x x))
        (subsume (iconst_u ty 0)))
  ```]
  Don't ask me what that does exactly. I have no idea...
]

#section[
  Another example is tinygrad's pattern system:
  #context html-frame[```python
  (UPat(Ops.AND, src=(
     UPat.var("x"),
     UPat(Ops.SHL, src=(
       UPat.const(1),
       UPat.var("b")))),
   lambda x,b: UOp(Ops.BIT_TEST, src=(x, b)))
  ```]
  Fun fact: tinygrad actually decompiles the python code inside the second element of the pair to optimize complex matches.
]

#section[
  Pattern matching and IR rewrite DSLs are a far better way of doing pattern matching.

  This approach is used by many popular compilers such as
  LLVM, GCC, and Cranelift for peephole optimizations and code generation.
]

#section[
  == Advantages
  - debugging and tracking of rewrites can be done properly
  - patterns themselves can be inspected and modified programmatically.
  - they are easier and nicer to use and read than manual pattern matching in the compiler's source code.

  \
  There is however a even better alternative:
]

#section[
  = Pattern Matching Dialects
  This section also applies to compilers that don't use dialects, but do pattern matching this way.
  For example GHC has the `RULES` pragma, which does something like this. I don't know where that is used, or if anyone even uses that...

  \
  I will also put this into the category of "structured pattern matching".

  \
  The main example of this is MLIR, with the `pdl` and the `transform` dialects.
  Sadly few projects use these dialects, and instead have C++ pattern matching code.
  One reason for this could be that they aren't documented very well.
]

#section[
  == What are compiler dialects?
  Modern compilers, especially multi-level compilers, such as MLIR,
  have their operations grouped in "dialects".

  Each dialect represents either a specific kind of operations, like arithmetic operations,
  or a specific compilation target / backend's operations, such as the `llvm` dialect in MLIR.

  Dialects commonly contain operations, data types, as well as optimization and dialect conversion passes.
]

#section[
  == Core Concept
  Instead of, or in addition to having a separate language for pattern matching and rewrites,
  the patterns and rewrites are represented in the compiler IR.
  This is mostly done in a separate dialect.
]

#section[
  == Advantages
  - the pattern matching infrastructure can optimize it's own patterns:
    The compiler can operate on patterns and rewrite rules like they are normal operations.
    This removes the need for special infrastructure regarding pattern matching DSLs.
  - the compiler could AOT compile patterns
  - the compiler could optimize, analyze, and combine patterns to reduce compile time.
  - IR (de-)serialization infrastructure in the compiler can also be used to exchange peephole optimizations.
  - bragging rights: your compiler represents it's own patterns in it's own IR
]

#section[
  = More Advantages of Structured Pattern Matching

  == Smart Pattern Matchers
  Instead of brute-forcing all peephole optimizations
  (of which there can be a LOT in advanced compilers),
  the compiler can organize all the patterns to provide more efficient matching.
  I didn't yet investigate how to do this. If you have any ideas regarding this, please #flink(alex_contact_url)[contact me.]

  There are other ways to speed up the pattern matching and rewrite process using this too.
]

#section[
  == Reversible Transformations
  I don't think that there currently is any compiler that does this.
  If you do know one, again, please #flink(alex_contact_url)[contact me.]
]

#section[
  Optimizing compilers typically deal with code (mostly written by people)
  that is on a lower level than the compiler theoretically supports.
  For example, humans tend to write code like this for testing for a bit: ```c x & 1 << b```,
  but compilers tend to have a high-level bit test primitive.
  A reason for having higher-level primitives is that it allows the compiler to do more high-level optimizations,
  but also some target architectures have a bit test operation that is faster.
]

#section[
  This is not just the case for "low-level" things like bit tests, but also high level concepts,
  like a reduction over an array, or even the implementation of a whole algorithm.
  For example LLVM, since recently, can detect implementations of CRC.
]

#section[
  Now let's go back to the ```c x & 1 << b``` (bit test) example.
  Optimizing compilers should be able to detect that pattern, and also other bit test patterns (like ```c x & (1 << b) > 0```),
  and then replace those with a bit test operation.
  But they also have to be able to convert bit test operations back to their implementation for targets that don't have a bit test operation.
  (Another reason to convert a pattern to a operation and then back to a different implementation is to optimize the implementation)
  Currently, compiler backends to this by having separate patterns for converting to the bit test operation, and back.

  A better solution is to associate a set of implementations with the bit test operation,
  and make the compiler *automatically reverse* those to generate the best implementation (in the instruction selector for example).
]

#section[
  == Runtime Library
  Compilers typically come with a runtime library that implement more complex operations
  that aren't supported by most processors or architectures.

  The implementation of those functions should also use that pattern matching / rewriting "dialect".
  The reason for this is that this allows your backend to detect code written by users with a similar implementation as in the runtime library,
  giving you some more free optimizations.

  I don't think any compiler currently does this either.
]

#section[
  = Conclusion
  One can see how pattern matching dialects are the best option by far.

  \
  PS: I'll hunt down everyone who still decides to do pattern matching in their compiler source after reading this article.
]

]
