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
  [Alexander Nutz]
)[

  #br()
  #title[Alexander Nutz]

  Low-level programming & electrical engineering
  #br()#br()

  Articles (#html-href("feed.typ.desktop.html")[Feed])
  #tree-list(..articles.filter(x => x.in-homepage).map(x => (
    level: 1,
    body: html-href(x.url, x.title)
  )))
  #br()

  Socials
  #tree-list(
    (level:1, body: link("https://matrix.to/#/"+people.alex.matrix)[ Matrix ]),
    (level:1, body: link("mailto:"+people.alex.mail)[ E-Mail ]),
    (level:1, body: link("https://codeberg.org/alex-s168")[ Codeberg ]),
    (level:1, body: link("https://github.com/alex-s168")[ GitHub ]),
    (level:1, body: [Discord: alex_s168]),
    (level:1, body: [nostr: #nostr-link("alex")]),
    (level:1, body: context link(res-path()+"Alexander_Nutz.pgp")[PGP Key]),
  )
  #br()

  Noteable (WIP) projects
  #tree-list(
    (level:1, body: [ #link("https://codeberg.org/meera-linux")[Meera Linux] ]),
    (level:1, body: [vxauth] ),
    (level:1, body: [ #link("https://vxcc.dev/webchapow_bench.html")[WebChaPow] ]),

    (level:1, body: [ Misc. ]),
     (level:2, body: [ #link("https://github.com/alex-s168/tpre")[ tpre ]: Fast RegEx engine ]),

    (level:1, body: [ Electronics ]),
     (level:2, body: [ #link("project-etc-nand.typ.desktop.html")[ etc-nand ]: #link("https://github.com/ETC-A/etca-spec/")[ ETC.A ] CPU from NAND gates ]),
  )
  #br()

  This website is written almost entirely in #link("https://typst.app/docs")[typst]!

  #link("https://github.com/alex-s168/website")[Website source code]
  #br()

  Check out these websites:\
  #context if is-web and is-html() { // excludes min.html builds too
    for id in people.keys() {
      let person = people.at(id)
      if person.at("badge", default:none) != none {
        badge(id, scale:1.3)
      }
    }
  }

  and:
  - #link("https://compiler.club/")[compiler.club]
  - #person("coppertiel")

  #br()#br()#br()

  Impressum:\
  Alexander Nutz\
  Gloggnitz, Lower Austria

  #br()#br()#br()
]
