#import "common.typ": *
#import "core-page-style.typ": *

#let html-href(target, content) = {
  [#context if is-html() {
    html.elem("a", attrs:(href:target), content)
  } else { content }]
}

#let min-pdf-link(content) = {
  [#context if is-html() {
    html.elem("a", attrs:(href:"#",onclick:"gotoMinPdf();"), content)
  } else { content }]
}

#let simple-page(gen-table-of-contents: true, gen-index-ref: true, content) = {
  core-page-style[
  #if is-web {
    table(
      stroke: none,
      columns: (25%, 50%, 25%),
      column-fixed(
        [#if gen-table-of-contents { [#table-of-contents()] }],
        min-pdf-link("Minimal PDF Version"),
        [#if gen-index-ref {[
           #context br()
           #context html-href("index.html")[#html-bold[Website Home]]
        ]}]
      ),
      [
        #let off = 3;
        #html-style("position: absolute; left: "+str(25+off)+"%; width: "+str(75-off)+"%")[
          #box(width: 50%, content)
        ]
      ],
    )
  } else {
    content
  }

  #html-script("
    function gotoMinPdf() {
      window.location.href = window.location.href.replace(/\.\w+.html/g, '.min.pdf');
    }
  ")
  ]
}
