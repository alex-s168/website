#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *

#let article = (
  authors: (people.alex,),
  title: "The making of the favicon",
  html-title: "The making of the favicon",
  summary: "It turns out that websites need a favicon, and making one is hard..."
)

#metadata(article) <feed-ent>

#simple-page(
  gen-table-of-contents: true,
  article.html-title
)[

#section[
  #title(article.title)

  #sized-p(small-font-size)[
    #rev-and-authors(article.authors)
  ]
]

#let w = 38%

#section[
  The favicon of my website currently is:
  #context wimage(res-path()+"favicon.png", width:w)
]

#let ic_url = "https://www.sciencedirect.com/science/article/pii/S0890540197926432"

#section[
  This represents an #flink(ic_url)[interaction combinator] tree, that can be interpreted as a
  #flink("https://en.wikipedia.org/wiki/Lambda_calculus")[lambda calculus] expression.
]

#section[
  = Step 0: Designing the Circuit
  I ended up with this:
  #context wimage(res-path()+"article-favicon/step0.png", width:32%)
  (this is the second attempt at layouting the circuit)
]

#section[
  = Step 1: Sketching
  While starting doing this, I realised that one wire always overlaps with one node triangle, unless I cheated.
  Here is a visual representation of this (inaccurate):
  #context wimage(res-path()+"article-favicon/step1_0.png", width:18%)

  \
  This means that I have to modify the layouting from step 0 a bit, which is unfortunate,
  but in retrospect, I think that it makes the result look better:
  #context wimage(res-path()+"article-favicon/step1_1.png", width:25%)

  \
  That however takes up too much space, so I did another variation:
  #context wimage(res-path()+"article-favicon/step1_2.png", width:25%)

  \
  I also did another variation here, but decided to not use that.
]

#section[
  = Step 2: Preparation for coloring
  I colored the back side of the piece of paper which contains the sketeches with a pencil,
  put a white piece of paper behind it,
  and then re-traced the line, to get a lighter version of the sketch onto the white paper.
  #context wimage(res-path()+"article-favicon/step2.png", width:25%)

  \
  Then I used modern technology (a copier) to copy that piece of paper multiple times,
  and also scale it up (to allow for more details).
]

#section[
  = Step 3: Coloring
  It was a disaster...

  #context wimage(res-path()+"article-favicon/step3_0.png", width:70%) \
  #context wimage(res-path()+"article-favicon/step3_1.png", width:70%)

  \
  Some variants actually look nice, but only parts of it.
]

#section[
  = Step 4: Outsourcing the coloring
  After some time, I just gave up, and decided to ask my sister for help...

  #context wimage(res-path()+"article-favicon/step4_0.png", width:70%)

  \
  I only told her (translated):
  ```
  Can you please color this?
  It's supposed to be a circuit, and it will be a small logo for a website.
  The website is mainly black and white, but this (context: persian blue) blue would work too.
  ```

  And less than half a minute later, she came up with this:
  #context wimage(res-path()+"article-favicon/step4_1.png", width:w)

  \
  We considered that the logo will end up being quite small, so "we" wanted it to look good when zoomed out.
  This is a pretty nice idea, because the different colored wires end up blending together nicely.

  \
  I put that into the scanner, and meanwhile she experimented with different filling styles.

  \
  Then she came up with this (the final version):
  #context wimage(res-path()+"article-favicon/step4_2.png", width:w)

  Filling the drawing only took her about 20 seconds!
]

#section[
  = Step 5: Digital Modifications
  As last step, I removed some of the sketch lines and some minor imperfections digitally.
]

#section[
  = Conclusion
  I like the final result a lot (as small logo), but it's a bit too detailed as favicon.
  
  I will re-visit this topic in the future.
]

]
