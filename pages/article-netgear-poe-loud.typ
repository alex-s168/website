#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *

#let article = (
  authors: ("alex",),
  title: "I thought Netgear makes Ethernet switches, not SYNTHESIZES",
  html-title: "I thought Netgear makes Ethernet switches, not SYNTHESIZES",
  summary: "Ah yes let me just turn on my PoE swi-"
)

#metadata(article) <feed-ent>

#simple-page(
  gen-table-of-contents: true,
  article.html-title
)[

#html-opt-elem("header", (:), section[
  #title(article.title)

  #sized-p(small-font-size)[
    #rev-and-authors(article.authors)
  ]
])

#section[
  It was a quiet sunday morning. I was looking at my stereo, and then the long cable spanning halfway across my room.

  Naivly, I was thinking: Oh I can just replace that with an Raspberry PI over ethernet, and just power the RPI from an PoE switch. Beautiful.

  So of course I went on Amazon, and bought the first reasonable-looking managed PoE switch I could find. My second Netgear switch.
]

#section[
  A few days later, it finally arrived, so I plugged it in. Eventually, I went to bed, hoping to enjoy the little bit of sleep I was going to get.

  BUT WAIT. What's that?? What is this HUMMING???

  So I started looking for the stupid device ruining my sleep. And a bit later, I figured it out. IT'S THE STUPID POE SWITCH!

  At that point, no single PoE device was even connected to the switch.

  So I got angry, unplugged the switch, and went to bed.
]

#section[
  The next day, I bought a nice IP67 or something isolated (water-proof) Meanwell 52V power supply. Which, apparently, you can not buy as consumer on Mouser, so I bought it from DigiKey.

  Only a month later, I finally got the PSU, measured it, and soldered a connector harness.

  After plugging it into the PoE switch, everything was silent. No noise at all. Without any PoE devices connected.

  Even a month later after I finally connected an PoE Raspberry PI, it was still dead silent!
]

#section[
  = So why was it humming in the first place?
  Pretty much all power supplies these days are switching. They switch an inductor (or a transformer winding) really quickly, to achieve voltage conversion.

  Now there are multiple reasons this could cause sounds.

  First, inductors can resonate weirldy or something no idea. Basically you can't do anything about that, other than making sure the inductor is mounted really solidly, without room for wiggling.
]

#section[
  Next, if the switching frequency is inside the audible frequency range, you will probably hear a humming. This is probably a common reason for humming in old power supplies.

  But new power supplies pretty much always switch much much quicker, so they can use smaller (and cheaper) inductors, and reduce inductor losses. So that's probably not the problem in this case.
]

#section[
  == Energy saving mode
  Guess what. Buck converters usually have a mode where they *reduce* switching speed under *lower load*, to significantly increase efficiency when the device is not under much load, because of switching losses.

  So when I had no PoE devices connected, the switch was only drawing a minimal portion of the maximum converter power, so it went into power saving mode.

  The thing is, almost every power converter these days has a power savings mode like this. It is however possible to avoid this issue by using for example muliple phases and turning some of them off,
  but obviously that is a bit more expensive, and manufacturers would rather have you go crazy because of humming, than spend €1 more...
]


]
