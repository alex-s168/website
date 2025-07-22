#import "common.typ": *

// pdfs need to be smaller text
#let small-font-size = if is-web { 14pt } else { 9pt }
#let default-font-size = if is-web { 17pt } else { 10pt }

#let core-page-style(html-head: [], content) = {context html-opt-elem("html", (:))[
#context if is-html() {
  html.elem("head",[
    #html-head

    #html.elem("meta", attrs:(charset:"utf-8"))
    #html.elem("meta", attrs:(name:"viewport", content:"width=device-width, initial-scale=1"))

    #let ico = res-path()+"favicon.png"
    #html.elem("link", attrs:(rel:"icon", sizes:"512x512", href:ico))
    #html.elem("link", attrs:(rel:"image_src", type:"image/png", href:ico))
  ])
}
#context html-opt-elem("body", (:))[

#show: x => context {
  set page(width: auto, height: auto) if is-web and not is-html()
  set page(paper: "a4") if not is-web and not is-html()
  set page(numbering: "1 of 1") if not is-web and not is-html()
  x
}

#set text(font: "DejaVu Sans Mono", size: default-font-size)

#show raw: it => if type(it.lang) == str and it.lang != "" and is-nano == false {
  // TODO: after typst fix html exporter breaking line :sob:
  // context html-frame(context 

  box(
    stroke: black,
    radius: 2pt,
    inset: if is-html() { 1.4pt } else { 5pt },
    outset: 0pt,
    baseline: 3.1pt,
    text(it)
  )
} else if is-nano == true {
  html-code(text(it))
} else {
  box(
    stroke: black,
    radius: 2pt,
    inset: if is-html() { 1.4pt } else { 5pt },
    outset: 0pt,
    baseline: 3.1pt,
    text(it)
  )
}

#show box: it => {
  context if is-html() {
    html.elem("span", attrs: (style: css-style(it)))[#it.body]
  } else {
    it
  }
}

#show underline: it => {
  context if is-html() {
    // TODO: NOOO
    html.elem("u", it.body)
  } else {
    it
  }
}

#show heading: it => underline[#it #v(3pt)]

#set underline(stroke: 1pt, offset: 2pt)

#show footnote: it => if is-web { [] } else { it }
#show footnote.entry: it => if is-web { [] } else { it }

#context if is-html() {
html.elem("style", "
  @font-face {
    font-family: 'DejaVu Sans Mono';
    src: url('res/DejaVuSansMono-Bold.woff2') format('woff2'),
        url('res/DejaVuSansMono-Bold.woff') format('woff'),
        local('DejaVu Sans Mono'),
        local('Courier New'),
        local(Courier),
        local(monospace);
    font-weight: bold;
    font-style: normal;
    font-display: swap;
  }

  @font-face {
    font-family: 'DejaVu Sans Mono';
    src: url('res/DejaVuSansMono.woff2') format('woff2'),
        url('res/DejaVuSansMono.woff') format('woff'),
        local('DejaVu Sans Mono'),
        local('Courier New'),
        local(Courier),
        local(monospace);
    font-weight: normal;
    font-style: normal;
    font-display: swap;
  }

  body {
    font-family: DejaVu Sans Mono;
    font-size: "+len2css(default-font-size)+";
  }
  
  td {
    width: 100%;
    display: inline;
    vertical-align: top;
  }
  
  h1,h2,h3,h4 {
    margin-top: 1%;
    margin-bottom: 0.75%;
  " + if is-web { "margin-left: -0.75%;" } else { "" }
  +
  "
  }
  
  p {
    margin-top: 0.75%;
    margin-bottom: 0.75%;
  }

  ul {
    margin-top: 0%;
  }

  .current {
    font-weight: bold;
  }

  pre {
    margin-top: 0px;
    margin-bottom: 0px;
    display: inline;
  }
")
}


#content
]]
}
