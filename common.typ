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
    let idx = tags.map(x => 0 > x.getBoundingClientRect().top - 10).lastIndexOf(true);
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
    matrix: "@alex-s168:matrix.org",
    cardano: "addr1qy9nhw7rcldtnlxpa2s9ue0fh6qyj32f84h3grryxtv83tczfcn66nzzye84dqe4s6gyre3qv8ev9zu2yfc0zxml259saxhelz",
    git: (
      "github.com": "alex-s168",
      "codeberg.org": "alex-s168",
      "git.vxcc.dev": "alexander.nutz",
    ),
    nostr: (
      nip05: "alex@vxcc.dev",
      pub: "npub17semnd065ahhsajlylkyd3lahcykpuw45rhj7cge3uqdfq24y84st0g4gr",
    ),
    pgp: "-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMESV+rKRYJKwYBBAHaRw8BAQdAnqCll9RSzZqdkNQ7wPflC5lxdrBjLfrUJL9d
Sn6Kg6W0KEFsZXhhbmRlciBOdXR6IDxhbGV4YW5kZXIubnV0ekB2eGNjLmRldj6I
ggQTFggAKgIbAwIeAQMFAHgWIQSny6VCXd8Q/yPCYL/el7gu1slQUQUCaduf/wIZ
AQAKCRDel7gu1slQUfmXAP9HAa/HlqFfJhwm9BLOa5S7LwLUfxSWGwCBXw8tva75
KwEAo1jck/4gzP+6muo1ZxFcTkaCjDLLeTVqdiiKDrgfFA20KkFsZXhhbmRlciBO
dXR6IDxhbGV4YW5kZXJudXR6NjhAZ21haWwuY29tPoiTBBMWCgA7FiEEp8ulQl3f
EP8jwmC/3pe4LtbJUFEFAmnbn6gCGwMFCwkIBwICIgIGFQoJCAsCBBYCAwECHgcC
F4AACgkQ3pe4LtbJUFEirQEAs0J0En4KSfYFWXT/GJmPjnGzlLLnuutlhamcfcOy
mGUBAO3ZKRXYQVCCqQmcpbx6nt5pkKyKcO29zFlzB1ZUn88NuDgESV+rKRIKKwYB
BAGXVQEFAQEHQJ/O38y0ZWRNCZvY43M6M2Mu2FdBG6nO3d3A4AKE3V1hAwEICYh7
BBgWCAAuBQJJX6spCRDel7gu1slQURYhBKfLpUJd3xD/I8Jgv96XuC7WyVBRAhsM
AwUAeAAACfsBAL9QXbGZ5zZUJDuWNenUr7oLOeUXuxP2TNT6mfIna2aMAPinL6Jw
q6OPeVl2nHGzp9eSrD08/i1VOl0EM0N3j2sE
=dxfr
-----END PGP PUBLIC KEY BLOCK-----",
  ),
  ote: (
    nick: "otesunki",
    url: "https://512b.dev/ote/",
    badge: "https://512b.dev/assets/lagtrain.gif",
    git: (
      "codeberg.org": "otesunki",
    ),
    pgp: "-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEZokIaxYJKwYBBAHaRw8BAQdASKCVZE6xNDUbp6m0KqzG2xmxDzxMOx24iQaf
zxtfWAO0HU90ZXN1bmtpIDxvdGVzdW5raUBnbWFpbC5jb20+iJkEExYKAEEWIQTQ
hyCBybuaYfcCd83EP/jiTm91hAUCZokIawIbAwUJBaOagAULCQgHAgIiAgYVCgkI
CwIEFgIDAQIeBwIXgAAKCRDEP/jiTm91hDCKAP42sI2F+mHZ/Rod07EFWDSIzupy
MxK8Q89NFZSP+ui6JQD8DbeRDmCNHPAdidU/2g7kIdFD/2sXoK07qRyc6TyrDQC4
OARmiQhrEgorBgEEAZdVAQUBAQdAAZZi/zB8YOaF/beesG3WR7ZHyPP94G1/yyjX
p2NH0hgDAQgHiH4EGBYKACYWIQTQhyCBybuaYfcCd83EP/jiTm91hAUCZokIawIb
DAUJBaOagAAKCRDEP/jiTm91hCxmAP42Ga8sEHJ2e+XUkfZGD+iFZfCB8do3wF7R
SKLjfdPIAgEAhsmMKrGzSC2J4HcVcRbkGtFN/cZYxrSynBZhMqbwWg8=
=UDI3
-----END PGP PUBLIC KEY BLOCK-----",
  ),
  hsp: (
    nick: "hemisputnik",
    url: "https://512b.dev/hsp/",
    badge: "https://512b.dev/hsp/assets/images/buttons/hsp.gif",
    git: (
      "codeberg.org": "hemisputnik",
    ),
  ),
  syn: (
    nick: "syn",
    url: "https://512b.dev/syn/",
    badge: "https://512b.dev/syn/badge.png",
  ),
  barracudalake: (
    nick: "barracudalake",
    url: "https://barralake.de/",
    badge: "https://static.barralake.de/banner.gif",
  ),
  iczelia: (
    nick: "iczelia", // todo: correct?
    name: "Kamila Szewczyk",
    url: "https://iczelia.net/",
    badge: "https://iczelia.net/static/8831/me.png",
    pgp: "-----BEGIN PGP PUBLIC KEY BLOCK-----

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
q9qe
=i3ys
-----END PGP PUBLIC KEY BLOCK-----",
  ),
  mj: (
    nick: "mj",
    url: "https://512b.dev/mjm/",
    badge: "https://512b.dev/mjm/88x31.png",
    git: (
      "codeberg.org": "ufrag",
    ),
  ),
  illuc: (
    nick: "illuc",
    url: "https://home.illuc.xyz/",
    badge: "https://home.illuc.xyz/assets/8831.gif",
    mail: "me@illuc.xyz"
  ),
  coppertiel: (
    nick: "coppertiel",
    url: "https://1558.space/",
  ),
  defectivebydesign: (
    nick: "defectivebydesign",
    url: "https://www.defectivebydesign.org/",
    badge: "https://512b.dev/ote/dbd.gif",  // TODO: aaaa non reproducable aaaaaaaaaaaa
  ),
)

#metadata(people) <meta-people>

#let person(id) = {
  let p = people.at(id)
  flink(p.url, p.at("name", default: p.nick))
}

#let nostr-link(id) = {
  let p = people.at(id)
  flink("https://nostr.com/" + p.nostr.pub, p.nostr.at("nip05", default:p.nostr.pub))
}

#let badge(id, scale: 1) = {
  let person = people.at(id)
  context html.elem("a", attrs:(href:person.url))[
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

#let blocking-code(raw) = {
  if is-nano {
    raw
  } else {
    context html-frame(raw)
  }
}
