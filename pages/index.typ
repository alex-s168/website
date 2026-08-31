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
  #title[Alexander C. Nutz]

  Systems programming & electrical engineering
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
    (level:1, body: [ #link("mailto:"+people.alex.mail)[ E-Mail ] (Currently non-operational!) ]),
    (level:1, body: context link(res-path()+"Alexander_Nutz.pgp")[PGP Key]),
    (level:1, body: link("https://codeberg.org/alex-s168")[ Codeberg ]),
    (level:1, body: link("https://x.com/alexn168")[ X.com ]),
    (level:1, body: [Discord: alex_s168 (checked rarely)]),
    (level:1, body: [nostr: #nostr-link("alex") (checked barely ever)]),
    (level:1, body: link("https://github.com/alex-s168")[ GitHub ]),
  )
  #br()

  Other works
  #tree-list(
    (level:1, body: [ (WIP) #context link(res-path()+"classof09-fanfic/crispin-likes-cars.png")[Class Of '09 FanFic: "Crispin likes Cars"] ])
  )
  #br()

  Working on:
  #tree-list(
    (level:1, body: [Everyone deserves cryptography: new authentication system] ),
    (level:1, body: [ #link("https://vxcc.dev/webchapow_bench.html")[WebChaPow]: Memory-dependent Proof-of-Work prototype ]),
    (level:1, body: [ Interaction Combinator hardware (soonTM) ]),
    (level:1, body: [ Learning how to build a modern SMT solver (SMT-COMP 2027, I'm coming!) ]),
    (level:1, body: [ Designing the perfect beginner-friendly&practical PL (there is gonna be a rant about this coming soon) ]),
    //(level:1, body: [ Electronics ]),
    (level:1, body: [ #link("project-etc-nand.typ.desktop.html")[ etc-nand ]: #link("https://github.com/ETC-A/etca-spec/")[ ETC.A ] CPU from NAND gates ]),
  )
  #br()

  Other Pages:
  #tree-list(
    (level:1, body: [ #link("homelab-pc-setup.typ.desktop.html")[Homelab & PC setup] ]),
  )
  #br()

  This website is written almost entirely in #link("https://typst.app/docs")[typst]
  #br()

  Edit June 2026: I am (passively...) working on a new website that is soo much better thant his and amazing, but thanks to the *truly amazing* JavaShi- JavaScript ecosystem, it's still not done...
  #br()

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
  - #link("https://essenceia.github.io")[Tales on the wire]

  #br()#br()#br()

  Impressum:\
  Alexander Nutz\
  Gloggnitz, Lower Austria

  #br()#br()#br()
]
