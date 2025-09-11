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
  #br()

  Articles (#html-href("atom.xml")[Atom feed])
  #br()
  #tree-list(..articles.filter(x => x.in-homepage).map(x => (
    level: 1,
    body: html-href(x.url, x.title)
  )))
  #br()

  Socials
  #br()
  #tree-list(
    (level:1, body: link("https://github.com/alex-s168")[ GitHub ]),
    (level:1, body: [Discord: alex_s168]),
    (level:1, body: link("mailto:alexander.nutz@vxcc.dev")[ E-Mail ]),
    (level:1, body: link("https://njump.me/npub17semnd065ahhsajlylkyd3lahcykpuw45rhj7cge3uqdfq24y84st0g4gr")[ nostr ]),
    (level:1, body: link("https://codeberg.org/alex-s168")[ Codeberg ]),
    (level:1, body: link("https://gitea.vxcc.dev")[ vxcc.dev Gitea ])
  )
  #br()

  Noteable projects
  #br()
  #tree-list(
    (level:1, body: [ Programming languages and compilers ]),
     (level:2, body: [ #link("https://github.com/vxcc-backend/vxcc-new")[ vxcc ]: WiP multi-level compiler ]),
     (level:2, body: [ #link("https://github.com/alex-s168/uiuac")[ uiuac ]: (discontinued) Optimizing compiler for the #link("https://uiua.org")[Uiua programming language] ]),
     (level:2, body: [ #link("https://github.com/Lambda-Mountain-Compiler-Backend/lambda-mountain")[ LSTS's standard library ] ]),
     (level:2, body: [ FP programming language compiler mostly using #link("https://en.wikipedia.org/wiki/Interaction_nets")[interaction nets] ]),
     (level:2, body: [ #link("https://github.com/alex-s168/lil-rs")[ lil-rs ]: WiP implementation of #link("http://beyondloom.com/decker/lil.html")[lil] ]),

    (level:1, body: [ Misc. ]),
     (level:2, body: [ #link("https://github.com/alex-s168/tpre")[ tpre ]: Fast and minimal RegEx engine ]),
     (level:2, body: [ nostr relay implementation ]),

    (level:1, body: [ PCBs ]),
     (level:2, body: [ #link("project-etc-nand.typ.desktop.html")[ etc-nand ]: #link("https://github.com/ETC-A/etca-spec/")[ ETC.A ] CPU from NAND gates ]),

    (level:1, body: [ FPGA designs ]),
     (level:2, body: [ RMII MAC in #link("https://www.chisel-lang.org/")[ Chisel ] ]),
     (level:2, body: [ Cryptography accelerators ]),
  )

  #br()
  Skills
  #br()
  #tree-list(
    (level:1, body: [ Writing compiler frontends but mostly backends ]),
    (level:1, body: [ Hardware design with #link("https://www.chisel-lang.org/")[ Chisel ] and Verilog ]),
    (level:1, body: [ Internals of MLIR ]),
  )

  #br()#br()
  This website is written almost entirely in #link("https://typst.app/docs")[typst].

  #link("https://github.com/alex-s168/website")[Website source code]

  #br()#br()
  Latest version of my badge:\
  #raw(people.alex.badge)

  #br()
  Check out these websites:\
  #context if is-web and is-html() { // excludes min.html builds too
    let scale = 1.3
    for id in people.keys() {
      let person = people.at(id)
      if person.at("badge", default:none) != none {
      html.elem("a", attrs:(href:person.url, target:"_blank"))[
        #html.elem("img", attrs:(
          src: res-path()+"badges/"+id,
          alt: "link to " + person.nick,
          attributionsrc: person.badge,
          fetchpriority: "low",
          style: "padding-left:10px; padding-right:14px",
          width: str(88*scale),
          height: str(31*scale),
        ))
      ]
      }
    }
  }
  - #person(people.barracudalake)
  - #person(people.hsp)
  - #link("https://compiler.club/")[compiler.club]

  #br()#br()#br()
  Impressum:\
  Alexander Nutz\
  Gloggnitz, Austria

  #br()#br()#br()
]
