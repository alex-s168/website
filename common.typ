#let to-bool(str) = {
  if str == "true" {
    return true
  }
  if str == "false" {
    return false
  }
  assert(false)
}

#let is-web = to-bool(sys.inputs.at("web", default: "true"))
#let is-nano = to-bool(sys.inputs.at("nano", default: "false"))
#let is-html() = { if sys.inputs.at("query", default:"false") == "true" {
  return false
} else {
  return target() == "html"
} }

#let git_rev = sys.inputs.at("git_rev", default: "")
#let short_git_rev = if git_rev != "" {
  git_rev.slice(0, count:8)
} else { "" }
#let git_commit_date = sys.inputs.at("git_commit_date", default: "")

#let res-path() = {
  if is-html() {
    "res/"
  } else {
    "/res/"
  }
}

#let title(content) = {
  context if is-html() {
    html.elem("h1", content)
  } else {
    text(23pt, content)
  }
}

#let br() = {
  context if is-html() {
    html.elem("br")
  }
  "\n"
}

#let space(num: 1) = {
  context if is-html() {
    [~] * (num - 1) + [ ]
  } else {
    " " * num
  }
}

#let sized-p(size, txt) = {
  context if is-html() {
    html.elem("span", attrs: (style: "font-size: " + str(size.abs.pt()) + "pt"), txt)
  } else {
    text(size, txt)
  }
}

#let html-frame(content) = {
  context if is-html() {
    html.frame(content)
  } else {
    content
  }
}

#let html-opt-elem(kind, attrs, content) = {
  context if is-html() {
    html.elem(kind, attrs: attrs, content)
  } else {
    content
  }
}

#let html-code(inner) = {
  html-opt-elem("code", (:),
    inner)
}

#let html-span(attrs, content) = {
  html-opt-elem("span", attrs, content)
}

#let html-div(attrs, content) = {
  html-opt-elem("div", attrs, content)
}

#let html-bold(content) = {
  context if is-html() {
    html.elem("b", content)
  } else {
    content
  }
}

#let html-style(class:"", style, content) = {
  html-span((class:class, style: style), content)
}

#let html-style-div(class:"", style, content) = {
  html-div((class:class, style: style), content)
}

#let slink(target, link-text) = text(fill: blue)[
  #link(target, link-text)
]

#let flink(target, link-text) = text(fill: blue)[
  #link(target, link-text)
  #context if not is-html() {
    footnote[#text(fill: blue)[#link(target)]]
  }
]

#let section(b) = block(breakable: false, [
  \
  #b
])

#let take-while(array, fn) = {
  let out = ();
  for x in array {
    if fn(x) {
      out += (x,);
    } else {
      break;
    }
  }
  return out;
}

#let gen-tree-from-headings(
  hide-first: false,
  marker: context "├─" + space(),
  marker-end: context "└─" + space(),
  side: context "|" + space(num:2),
  side-empty: context space(num:3),
  elemfn: x => x,
  headings,
) = {
  for (idx, item) in headings.enumerate() {
    let content = [];
    for ind in range(item.level - 1) {
      let will-future = take-while(headings.slice(idx),
                                    x => x.level > ind)
                                  .any(x => x.level == ind + 1);
      content += if will-future {
        side
      } else {
        side-empty
      }
    }
    content += if take-while(headings.slice(idx + 1),
                    x => x.level >= item.level)
                  .any(x => x.level == item.level) {
      marker
    } else {
      marker-end
    }
    elemfn(content, item)
  }
}

#let len2css(len, default: "auto", map-pt: x => str(x)+"pt") = {
  if len == auto or type(len) == dictionary {
    return default
  }
  if type(len) == relative and float(len.ratio) * 100 != 0 {
    assert(len.length.pt() == 0)
    return str(float(len.ratio) * 100) + "%";
  }
  if type(len) == relative {
    len = len.length
  }
  return map-pt(len.abs.pt())
}

#let option-map(option, default, fn) = {
  if option == none { default }
  else { fn(option) }
}

#let stroke2css(stroke, default:"none") = {
  if type(stroke) == dictionary {
    return default
  }
  let th = len2css(stroke.thickness, default: "1pt")
  return th + " solid black" // TODO: paint
}

#let css-style(it) = {
  return "
        " + option-map(stroke2css(it.stroke, default:none), "", x => "border:"+x+";") + "
        " + option-map(len2css(it.radius, default:none), "", x => "border-radius:"+x+";") + "
        " + option-map(len2css(it.width, default:none), "", x => "width:"+x+";") +"
        " + option-map(len2css(it.height, default:none), "", x => "height:"+x+";") +"
        " + option-map(len2css(it.inset, default:none), "", x => "padding:"+x+";")
}

#let wimage(path, width:100%, alt:"image") = {
  context if is-html() {
    html.elem("img", attrs:(src:path, alt:alt, style:"width:"+len2css(width+0pt)+";"))
  } else {
    image(path)
  }
}

#let html-script(code) = {
  [#context if is-html(){
  html.elem("script", code)
  }]
}

#let html-script-dom-onload(code) = {
  html-script("document.addEventListener('DOMContentLoaded', function() { "+code+" })")
}

#let column-fixed(..contents) = {
  html-style(class:"column-fixed", "display: inline-flex; position: fixed; justify-content: center; width: 25%")[
    #table(..contents)

    #context if is-html() {
      html.elem("style", "
        .column-fixed > table > tbody > tr > td > * { width: 100%; }
      ")
    }
  ]
}

#let spoiler(content) = {
  [#context if is-html() {
    html-style(class:"hide", "", content)
  } else {
    content
  }]
}

#let inline-block(content) = {
  [#context if is-html() {
    html-style("white-space:nowrap;", content)
  } else {
    block(breakable:false, content)
  }]
}

// TODO: move to component
#let table-of-contents() = {
  html-style(class:"table-of-contents", "", block(
      stroke: 1.2pt+black,
      radius: 2pt,
      inset: 3%,
    [#underline[Table of contents]\
      #let idx = state("stupid-gen-page-state", 0);

      #context gen-tree-from-headings(query(heading),
          elemfn: (content, x) => { 
            [ 
              #html-opt-elem("p", (style:"line-height:1.1"))[
                #html-style("display:flex; text-indent:0pt;")[
                  #html-style("margin-right: 11pt;", content)
                  #html-style("flex:1;")[
                    #context html-span((class:"headingr",id:"headingr-"+str(idx.get())), link(x.location(), x.body))
                    #context idx.update(x=> x + 1)
                  ]
                ]
              ]
            ]
          })
    ])) + html-style(class:"table-of-contents", "", html-script-dom-onload("
let tags = ['h2', 'h3', 'h4'].flatMap(x => Array.from(document.getElementsByTagName(x))).sort((a, b) => a.getBoundingClientRect().top - b.getBoundingClientRect().top);
let pageHeight = document.documentElement.scrollHeight-window.innerHeight;
document.addEventListener('scroll', (event) => {
    let progress = -(document.documentElement.getBoundingClientRect().y / pageHeight);
    let delta = progress * window.innerHeight;
    let idx = tags.map(x => 0 > x.getBoundingClientRect().top - delta).lastIndexOf(true);
    Array.from(document.getElementsByClassName('headingr')).map(x => x.classList.remove('current'));
    if (idx != -1) {
        document.getElementById('headingr-' + idx).classList.add('current');
    }
}
);
    ") + [
    #context if is-html() {
      html.elem("style", "
        .table-of-contents > p > span { width: 100%; }
      ")
    }
  ])
}

#let people = (
  alex: (
    nick: "alex_s168",
    name: "Alexander Nutz",
    url: "https://alex.vxcc.dev",
    badge: "https://alex.vxcc.dev/res/badge.png",
    mail: "alexander.nutz@vxcc.dev",
  ),
  ote: (
    nick: "otesunki",
    url: "https://512b.dev/ote/",
    badge: "https://512b.dev/assets/lagtrain.gif"
  ),
  syn: (
    nick: "syn",
    url: "https://512b.dev/syn/",
    badge: "https://512b.dev/syn/badge.png",
  ),
  hsp: (
    nick: "hemisputnik",
    url: "https://512b.dev/hsp/",
    badge: "https://512b.dev/hsp/assets/images/buttons/hsp.gif",
  ),
  barracudalake: (
    nick: "barracudalake",
    url: "https://barralake.de/",
    badge: "https://static.barralake.de/banner.gif"
  ),
  mj: (
    nick: "mj",
    url: "https://512b.dev/mjm/",
    badge: "https://512b.dev/mjm/88x31.png",
  ),
  illuc: (
    nick: "illuc",
    url: "https://home.illuc.xyz/",
    badge: "https://home.illuc.xyz/assets/8831.gif",
    mail: "me@illuc.xyz"
  ),
)

#metadata(people) <meta-people>

#let person(p) = {
  flink(p.url, p.nick)
}

#let blocking-code(raw) = {
  if is-nano {
    raw
  } else {
    context html-frame(raw)
  }
}
