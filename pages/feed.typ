#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../build/pages.typ": articles

#let tree-list(..elements) = {
  gen-tree-from-headings(elemfn: (content, x) => [
    #html-opt-elem("p", (style:"line-height:1.1"))[
      #html-style("display:flex; text-indent:0pt;")[
        #html-style("margin-right: 11pt;", content)
        #html-style("flex:1;", x.body)
      ]
    ]
  ], elements.pos())
}

#simple-page(
  gen-table-of-contents: false,
  gen-index-ref: false,
  min-pdf-link: false,
  [Blog Feed]
)[
  #br()
  #title[Blog Feed]

  #tree-list(
    (level:1, body: [ Atom ]),
     (level:2, body: [ #link("https://alex.vxcc.dev/atom.xml")[ With (compact) contents ] ]),
     (level:2, body: [ #link("https://alex.vxcc.dev/atom-hybrid.xml")[ Only latest articles with contents, others summary only ] ]),
     (level:2, body: [ #link("https://alex.vxcc.dev/atom-summary.xml")[ Without contents (summaries only) ] ]),

    (level:1, body: [ RSS ]),
     (level:2, body: [ #link("https://alex.vxcc.dev/rss.xml")[ With (compact) contents ] ]),
     (level:2, body: [ #link("https://alex.vxcc.dev/rss-hybrid.xml")[ Only latest articles with contents, others summary only ] ]),
     (level:2, body: [ #link("https://alex.vxcc.dev/rss-summary.xml")[ Without contents (summaries only) ] ]),
  )
  #br()

]
