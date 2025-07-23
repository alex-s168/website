#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": rev-and-authors

#simple-page(
  gen-table-of-contents: true,
  [GPU architecture: SIMD - Alexander Nutz]
)[

#section[
  #title[GPU Architecture: Compute Cores]

  #sized-p(small-font-size)[
    #rev-and-authors((people.alex,))
  ]
]

#if is-web {section[
  Note that the #gen-min-pdf-link[PDF Version] of this page might look a bit better styling wise.
]}

#section[
  = Introduction
  GPUs consists of multiple (commonly 64) compute units.

]


]
