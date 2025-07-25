#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *

#simple-page(
  gen-table-of-contents: true,
  [Designing a GPU architecture: Waves]
)[

#section[
  #title[Designing a GPU Architecture: Waves]

  #sized-p(small-font-size)[
    #rev-and-authors((people.alex,))
  ]
]

#pdf-readability()

#section[
  = Introduction
  In this article, we'll be looking into the hardware of GPUs, and then designing our own.
  Specifically GPUs with unified shader architecture.
]

#section[
  == Comparision with CPUs
  GPUs focus on operating on a lot of data at once (triangles, vertecies, pixels, ...),
  while CPUs focus on high performance on a single core, and low compute delay.
]

#section[
  = GPU Architecture
  GPUs consists of multiple (these days at least 32) compute units (= CU).

  Each compute unit has multiple SIMD units, also called "wave", "wavefront" or "warp".
  Compute units also have some fast local memory (tens of kilobytes),
  main memory access queues, texture units, a scalar unit, and other features. (see future article)

  The main memory (graphics memory) is typically outside of the GPU, and is slow, but high-bandwidth memory.
]

#section[
  == Waves
  A wave is a SIMD processing unit consisting of typically 32 "lanes" (sometimes called threads).

  Each wave in a CU has seperate control flow, and doesn't have to be related.

  Instructions that waves support:
  - arithmetic operations
  - cross-lane data movement
  - CU local and global memory access: each SIMD lane can access a completely different address. similar to CPU gather / scatter.
  - synchronization with other CUs in the work group (see future article)

  Since only the whole wave can do control flow, and not each lane, all operations can be masked so that they only apply to specific lanes.

  => waves are really similar to SIMD on modern CPUs
]

#section[
  == Local memory
  The local memory inside GPUs is banked, typically into 32 banks.
  The memory word size is typically 32 bits.

  The addresses are interlaved, so for two banks:
  - addr 0 => bank 0
  - addr 1 => bank 1
  - addr 2 => bank 0
  - addr 3 => bank 1
  - ...

  Each bank has an dedicated access port, so for 32 banks, you get 32 access ports.

  The lanes of the waves inside a CU get routed to the local memory banks magically.
]

#section[
  === Why are the banks interlaved?
  When the whole wave wants to read a contiguos array of `f32`, so when each wave performs `some_f32_array[lane_id()]`,
  all 32 banks can be used at the same time.
]

#section[
  === Why multiple waves share the same local memory
  A wave doesn't do memory accesses every instruction, but also does computations.
  This means that there are cycles where the memory isn't doing anything.

  By making multiple waves share the same local memory and access ports, you save resources.
]

#section[
  == Global memory
  Since global memory reads/writes are really slow, they happen asynchronosly.

  This means that a wave requests an access, then can continue executing, and then eventually waits for that access to finish.

  Because of this, modern compilers automagically start the access before the data is needed, and then wait for the data later on.
]

#section[
  == Scalar unit
  Most newer GPUs also have a scalar unit for saving energy when performing simple operations.

  When the controller sees a scalar instruction in the code running on a wave, it automatically makes the code run on the scalar unit.

  The scalar unit can be used for:
  - address calculation
  - partial reductions
  - execution of expensive operations not implemented on SIMD because of costs
]

#section[
  = GPU Programming Terminology
  - "work item": typically maps to a SIMD lane
  - "kernel": the code for a work item
  - "work group": consists of multiple work items. typically maps to an CU. the `__local` memory in OpenCL applies to this.
  - "compute task": a set of work groups
]

#section[
  OpenCL and other APIs let you specify both the number of work groups and work items.

  Since a program might specify a higher number of work items per work group than we have available,
  the compiler needs to be able to put multiple work items onto one SIMD lane.
]

#section[
  = Our own architecture
  We'll go with these specs for now:
  - N compute units
  - 2 waves per CU
  - 32 lanes per wave.
  - 1KiB local memory per lane => 64 KiB
  - 48 vector registers of 16x32b per wave
  - one scalar unit per CU
  - 128 global memory ports
  - no fancy out of order or superscalar execution
  - support standard 32 bit floating point, without exceptions.

  Note that we won't specifiy the exact instruction encoding.
]

#section[
  == Predefined Constants
  We will pre-define 16 constants (as virtual vector registers):
  - `zero`
  - `one`
  - `sid`: 0,1,2,3,4,5,6
  - `wave`: the ID of the wave in the compute task, broadcasted to all elements.
  - `u8_max`: 255,255,...
  - `n2nd`: 1,2,1,2,...
  - `n3rd`: 1,2,4,1,...
  - `n4th`: 1,2,4,8,1,...
  - `lo16`: 1,1,1,... (x16) 0,0,0,... (x16)
  - `ch2`: 1,1,0,0,1,1,...
  - `ch4`: 1,1,1,1,0,0,0,0,1,...
  - `alo8`: 1 (x8)  0 (x8)  1 (x8)  0 (x8)
  - a few reserved ones
]

#section[
  == Operands
  We define the following instruction operands:
  - `Vreg`: vector register
  - `M`:  (read only) vector gp reg as mask (1b).
          only first 32 registers can be used as mask. 
          the operand consists of two masks and-ed together, each of which can conditionally be inverted first.
          this means that this operand takes up 12 bits
  - `Vany`: `Vreg` or `M`
  - `Simm`: immediate scalar value
  - `Sreg`: the first element of a vector register, as scalar
  - `Sany`: a `Simm` or an `Sreg`
  - `dist`: `Vany`, or a `Sany` broadcasted to each element
]

#section[
  == Instructions
  We will add more instructions in future articles.
]

#section[
  === Data Movement
  - `fn mov(out out: Vreg, in wrmask: M, in val: dist)`
  - `fn select(out out: Vreg, in select: M, in false: dist, in true: dist)`
  - `fn first_where_true(out out: Sreg, in where: M, in values: dist)`:
    if none of the elements are true, it doesn't overwrite the previous value in out.
  - cross-lane operations: not important for this article
]

#section[
  === Mathematics
  - simple (unmasked) `u32`, `i32`, and `f32` elementwise arithmetic and logic operations:
    `fn add<u32>(out out: Vreg, in left: Vany, in right: dist)`
  - scalar arithmetic and logic operations:
    `fn add<u32>(out out: Sreg, in left: Sany, in right: Sany)`
  - partial reduction operations:
    "chunks" the input with a size of 8, reduces each chunk, and stores it in the first element of the chunk.
    this means that every 8th element will contain a partial result.
  - and operations to finish that reduction into the first element of the vector
]

#section[
  === Memory
  - `fn local_load`
  TODO
]

#section[
  === Control flow (whole wave)
  TODO
]

#section[
  = Hand-compiling code
  TODO
]

]
