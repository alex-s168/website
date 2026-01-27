#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *

#let article = (
  authors: (people.alex,),
  title: "Truthear HEXA vs PURE vs GATE",
  html-title: "HEXA vs PURE vs GATE Review",
  summary: "Being financially irresponsible and spending way too much money on audio tech"
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

#pdf-readability()

#section[
  Note that I have no idea what I'm talking about, and these are just my personal oppinions!
]

#section[
  After being sick of bad headphones, I decided to buy Truthear HEXAs for 99€,
  and they were by far the best headphones I ever tried...

  They produce a really clear sound, with strong bass, allowing you to notice musical details you would have never heard with most cheap setups.
  However! sometimes you don't catch the "vibe" of the music; they force you to overanalyze everything, they are almost too optimal; Quoting the HEXA product page: "Present the excellent objective index".
]

#section[
  That didn't annoy me too much tho, so I just decided to keep them.
  But one day, when pulling the headphones out of my bag, I was shocked to see that I snapped the left headphone-connecting pins on the cable in half!
  Turns out you're not supposed to just throw them into a bag...

  I managed to "repair" the cable by soldering on different pins, but the wires aren't just standard multi-strand copper wires, so I had a hard time soldering
  on new contacts, and the fix broke after a few days.
]

#section[
  Since cheap & good replacement cables are hard to find, I decided to buy Truthear GATEs for 20€, which have compatible cables.
  But I was thinking: "might as well get another pair of headphones as comparision", so I decided to also get Truthear PUREs for 99€...
]

#section[
  = Comparision
  - GATE: 20€
  - HEXA: 99€
  - PURE: 99€
]

#section[
  == GATE
  Really solid for the price point.
  They have a similar "clearness" to the HEXAs, but are noticably worse than both HEXAs and PUREs
]

#section[
  == HEXA vs PURE
  It's easy to notice that they sound different, but it's hard to tell which is "better"...

  The PUREs sound more "fun" and warm than the HEXAs

  Recommendation based on genre:
  - Dark R&B: I think the clear sound of the HEXAs is much better for lots of Dark R&B
  - HipHop: PUREs sound more exciting, and seem to have better bass
  - EDM: The PUREs have better bass in many songs, but tend to be noticably worse than the HEXAs for lead & vocals

  Also consider that according to Truthear, the PUREs are supposed to be an improvement over the HEXA design, based on feedback by "professionals"...
]

#section[
  = Favourites
  If I could only pick one, I'd go with the HEXAs; Even though the "clearness" is annoying sometimes,
  they just sound much better than "warm"er headphones, like the PUREs or the ZERO:RED (which I tried for one day when getting the HEXAs, and then returned), in most cases.

  Keep in mind that I'm not a "professional", so you should definitely read other people's reviews too.
  If you don't want to spend 100€ on headphones, you should probably get GATEs; they are good enough for most things.
]

#section[
  = Foam Eartips
  In my opinion, the foam eartips sound much better than the silicone eartips; Sadly the GATEs don't come with any, and the HEXAs and PUREs only with one set.
  Be careful with the included foam eartips! They break easily...

  If you need replacement eartips, I suggest getting #flink("https://www.complyfoam.com")[Comply] eartips.
  You can just click the button on the top right, and enter the model name of your headphones.

  I got Comply 600 core series (small & medium) eartips, which work for the HEXAs, GATEs, and PUREs.
  They seem to last much longer than the included eartips, and also don't itch after wearing for a long time.

  Also note that getting slightly larger eartips means better sound (and less sound from the environment), but might hurt a bit after wearing them for long.
]

]
