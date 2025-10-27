#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *

#let article = (
  authors: (people.alex,),
  title: "Comparing Compiler Frameworks & Backends",
  html-title: "Comparing Comparing Frameworks & Backends",
  // summary: "If you are working an more advanced compilers, you probably had to work with pattern matching already. In this article, we will explore different approaches.",
)

#metadata(article) <feed-ent>

#simple-page(
  gen-table-of-contents: true,
  article.html-title
)[

#section[
  #title(article.title)

  #sized-p(small-font-size)[
    #rev-and-authors(article.authors)
  ]
]

#section[
  TODO:
  - TPDE https://arxiv.org/abs/2505.22610
  - QBE
  - BB backend
  - TB
  - Cranelift
  - luajit
  - llvm (and llvm-mos)
  - llvm drect mc: seldag vs gisel
  - llvm polly
  - mlir -> llvm
  - mlir direct codegen
  - gcc
  - ROSE
  - sdcc
  - .net jit & aot
  - binaryninja
  - tinygrad
  - the different v8 JITs
  - hotspot jre jit
  - asmjit
  - todo: other JITs
  - LoopStack
  - Halide
  - TVM
  - mesa
]

]
