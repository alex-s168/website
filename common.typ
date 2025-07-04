#let alex_contact_url = "https://alex.vxcc.dev"


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

#let table-of-contents() = {
  html-style(class:"table-of-contents", "", [
    #box(
      stroke: black,
      radius: 2pt,
      inset: 3%,
    )[
      Table of contents\
      #context {
        let idx = state("stupid-gen-page-state", 0);
        gen-tree-from-headings(query(heading),
          elemfn: (content, x) => { 
            [#content #context html-span((class:"headingr",id:"headingr-"+str(idx.get())), link(x.location(), x.body)) #context idx.update(x=> x + 1) #br()]
          })
      }
    ]
    #html-script-dom-onload("
      let tags = ['h2','h3','h4'].flatMap(x => Array.from(document.getElementsByTagName(x)));
      document.getElementById('headingr-0').classList.add('current')
      document.addEventListener('scroll', (event) => {
        let curr = tags.map(x => [x, (x.getBoundingClientRect().top + x.getBoundingClientRect().bottom) / 2]).filter(x => x[1] >= 0).sort((a,b) => a[1] > b[1])[0][0];
        let idx = tags.sort((a,b) => a.getBoundingClientRect().top > b.getBoundingClientRect().top).map((x, idx) => [idx, x]).filter(x => x[1] == curr)[0][0];
        Array.from(document.getElementsByClassName('headingr')).map(x => x.classList.remove('current'))
        document.getElementById('headingr-'+idx).classList.add('current')
      });
    ")
  ] + [
    #context if is-html() {
      html.elem("style", "
        .table-of-contents > p > span { width: 100%; }
      ")
    }
  ])
}
