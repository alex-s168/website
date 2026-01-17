#import "common.typ": *
#import "core-page-style.typ": *

#let html-href(target, content) = {
  [#context if is-html() {
    html.elem("a", attrs:(href:target), content)
  } else { content }]
}

#let variant-link(content, variant) = {
  [#context if is-html() {
    html.elem("a", attrs:(href:"#",onclick:"gotoVariant(\""+variant+"\");"), content)
  } else { content }]
}

#let simple-page(
  gen-table-of-contents: true,
  gen-index-ref: true,
  min-pdf-link: true,
  html-title,
  content) = {

  let head = context if is-html() {
    [
      #html.elem("title", html-title)
      #context if (not is-nano) and is-html() {
        html.elem("script", attrs:("src":"coffee.js","async":""))
        html-script("
var on_coffee_update = [];
function onCoffee(clbk) {
  on_coffee_update.push(clbk);
}
        ")
      }
    ]
  } else {[]}

  core-page-style(html-head: head)[
  #if is-web {
    let off = 3;

    table(
      stroke: none,
      columns: (25%, 50%, 25%),
      
      html-style(class:"sidebar", "", column-fixed(
        [#if gen-table-of-contents { [#table-of-contents()] }],

        [#if gen-index-ref {[
           #context br()
           #context html-href("index.html")[#html-bold[Website Home]]
           #context br()
        ]}],
        [#context if min-pdf-link and is-html() [
          Renderings of this page:
          - #variant-link("minimal PDF (printable)", ".min.pdf")
          // TODO: fix and re-add - #variant-link("less bloated HTML", ".min.html")
          - #variant-link("minimal HTML", ".nano.html")
        ]],
        [#if gen-index-ref [
         #html-href("atom.xml")[Atom feed]
         #context br()
        ]],

        [#context if is-html() {
          html.elem("style", "
            @media only screen and (max-width: 1200px) {
              .sidebar {
                display: none !important;
              }

              .column-fixed {
                width: 0% !important;
              }

              .body-column {
                left: "+str(off)+"% !important;
              }
            }

            @media only screen and (max-width: 1800px) {
              .body-column > span {
                width: 75% !important;
              }
            }

            @media only screen and (max-width: 1200px) {
              .body-column {
                width: "+str(100-off)+"% !important;
              }
              .body-column > span {
                width: 100% !important;
              }
            }

            .hide { display: inline;  background: black; transition: background 0.3s linear; }
            .hide:hover, .hide:focus { background: transparent; }
          ")
        }],
      )),
      [
        #html-style(class:"body-column","position: absolute; left: "+str(25+off)+"%; width: "+str(75-off)+"%")[
          #box(width: 50%, content)
        ]
      ],
    )
  } else {
    content
  }

  #context if (not is-nano) and is-html() {
    html-script("
      function gotoVariant(variant) {
        window.location.href = window.location.href.replace(/\.\w+.html/g, variant);
      }

      window.addEventListener('beforeprint', (event) => {
        gotoVariant('.min.pdf');
      });
    ")
  }
  ]
}
