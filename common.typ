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
#let is-html() = { return target() == "html" }

#let git_rev = sys.inputs.at("git_rev", default: "")
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

#let html-p(txt) = {
  context if is-html() {
    html.elem("p", txt)
  } else {
    text(txt)
  }
}

#let sized-p(size, txt) = {
  context if is-html() {
    html.elem("p", attrs: (style: "font-size: " + str(size.abs.pt()) + "pt"), txt)
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

#let html-span(attrs, content) = {
  html-opt-elem("span", attrs, content)
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

#let slink(target, link-text) = text(fill: blue)[
  #underline[#link(target, link-text)]
]

#let flink(target, link-text) = text(fill: blue)[
  #underline[#link(target, link-text)]
  #footnote[#text(fill: blue)[#link(target)]]
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

#let stroke2css(stroke) = {
  if type(stroke) == dictionary {
    return "none"
  }
  let th = len2css(stroke.thickness, default: "1pt")
  return th + " solid black" // TODO: paint
}

#let css-style(it) = {
  return "
        display: inline-block;
        border: "+stroke2css(it.stroke)+";
        border-radius: "+len2css(it.radius, default: "0px")+";
        " + option-map(len2css(it.width, default:none), "", x => "width:"+x+";") +"
        " + option-map(len2css(it.height, default:none), "", x => "height:"+x+";") +"
        padding: " + len2css(it.inset)
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

#let table-of-contents() = {
  html-style(class:"table-of-contents", "", box(
      stroke: black,
      radius: 2pt,
      inset: 3%,
    [Table of contents\
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
    url: "https://alex.vxcc.dev"
  ),
  ote: (
    nick: "otesunki",
    url: "https://512b.dev/ote/"
  ),
)

#let person(p) = {
  flink(p.url, p.nick)
}
