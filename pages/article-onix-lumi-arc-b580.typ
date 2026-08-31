#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *
#import "../components/geizhals-price.typ": *

#let article = (
  authors: ("alex",),
  title: "Onix Lumi Arc B580 Teardown",
  html-title: "Onix Lumi Arc B580 Teardown",
  summary: "GPU Teardown"
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
  = Introduction
  The cheapest Arc B580 available in Austria was the ONIX LUMI (by a few Euros) at point of purchase,
  so of course I bought two.

  4-GPU benchmarks will follow later.
  Subscribe to the #html-href("feed.typ.desktop.html")[feed] to not miss that.
]

#section[
  #context wimage(res-path()+"article-onix-lumi/both-gpus.png", width:100%, alt:"Two identical GPUs side-by-side")
]

#section[
  = Why
  Why *I* bought GPUs? AI, simulations, and massively parallel interaction net runtimes.

  Why this card? (Advantages)
  - PCIe4x8 (on a 16x slot): can fit more GPUs per CPU, and PCIe4.0 is cheaper and easier to work with.
  - Really cheap. I bought it at 297€/card. Live price: #geizhals-price(3687439, 297) / card. 
  - Heatsink design (we'll get to this later)
]

#section[
  = Teardown
  First, remove the top plastic cover & fans, by unscrewing screws on the bottom and the card's mounting bracket (on the side).

  #context wimage(res-path()+"article-onix-lumi/pcb+heatsink-top-w-cover.png", width:100%, alt:"Heatsink from top, and fans from the bottom")

  By the way, if you don't want the RGB, you can probably just disconnect the smaller (4-pin) wire.
]

#section[
  The card only takes up two slots with the fans removed:

  #context wimage(res-path()+"article-onix-lumi/pcb+heatsink-side.png", width:100%, alt:"Card without fans from the side")
]

#section[
  You can't see it clearly on the image, but the heatsink seems pretty well suited for cooling it by blowing from the side instead,
  as tinygrad did with their #flink("https://tinycorp.myshopify.com/products/tinybox-pro-v2")[tinybox pro v2]:

  #context wimage(res-path()+"article-onix-lumi/tinybox-pro-v2-gpu-cooling.png", width:100%, alt:"Creative cooling solution for multi-GPU servers by tinygrad")
]

#section[
  Next, you can remove the heatsink by unscrewing the 4 self-tightening screws on the bottom.

  #context wimage(res-path()+"article-onix-lumi/heatsink.png", width:100%, alt:"Heatsink from the bottom")

  #context wimage(res-path()+"article-onix-lumi/top.png", width:100%, alt:"PCB from the top")
]

#section[
  Finally you can take of the backplate:
  
  #context wimage(res-path()+"article-onix-lumi/back.png", width:100%, alt:"PCB and backplate from the back")

  #context wimage(res-path()+"article-onix-lumi/back2.png", width:100%, alt:"PCB from the back")
]

#section[
  = Conclusion
  I don't know. Looks like a solid GPU, especially for this price.

  If you want to know more details before buying one of these, feel free to #flink("https://alex.vxcc.dev")[contact me].
]


]
