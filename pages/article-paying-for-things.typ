#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *
#import "../components/header.typ": *

#let article = (
  authors: ("alex",),
  title: "Paying for things",
  html-title: "Paying for things",
  summary: "Big cooperations got us spoiled with free stuff"
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
  These days, most things are available for "free". Google search is free. G-Mail is free. Even Google Photos is free??
  Obviously things are not free because the companies are nice. The companies want to collect your data, and show you ads.

  The situation's gotten so bad, that most people refuse to pay for small things [citation needed].
]

#section[
  There is a good #flink("https://help.kagi.com/kagi/why-kagi/why-pay-for-search.html")[article] by Kagi (search engine & more), about why you should pay for search. \

  You should pay for everything you use.
  Especially things you use many times daily, like search engines, your e-mail software, your web browser, and even your desktop compositor!

  Many people will say "But what about free and open source!". No.
  YOU should pay for *everything* you use. Of course you should not have to pay a subscription, and the software should not have a paywall (or at least not a restrictive paywall), but you, as user, should be willing to pay the software maintainers, developers, and hosters!
]

#section[
  Of course this does not apply to shitty or LLM-written software, like Windows, or GitHub. #flink("https://stephango.com/quality-software")[Quality software deserves your hard‑earned cash].
  This also applies to other media like: music, entertainment, educational content, photographs, blog articles, ...
]

#section[
  = NO Pay-walls!
  Just because I said you should pay for media, like blog articles, doesn't mean everyone should start putting paywalls infront of their blogs!
  Quite the opposite actually! All research, summaries of research, etc, should be publicly accessible (for free)!

  Instead, blogs could have a (non-intrusive!) donate button. Normalize micro-transactions on the web!
  (These could be implemented with for example Cardano, or more privacy focused DeFi)
  // TODO: link on-cryptocurrencies article
]

#section[
  = Against streaming subscriptions
  Even though streaming subscriptions are nice in theory, media should not be streamed. You should be able to own your media.

  Potential alternatives, with music as example:
  - Buy the album/song once, and get the raw audio file. #flink("https://bandcamp.com/")[Bandcamp] allows you to do that.
  - Always have access to the raw audio file, but reliably pay the creators depending on how often you listen to it.

  The only thing worse than streaming music, is DRM: \
  #badge("defectivebydesign", scale: 1.4)
]

#section[
  = Against subscriptions in general
  There are two kinds of subscription users:
  - underuses their subscription: they pay much more for the subscription, than they would have paid for each item / stream / search / ...
  - overuses their subscription: they save a ton of money by having the subscription, and pay less per item than most others.

  The second kind is rather uncommon, so most companies that offer subscriptions do so, knowing that users will underuse them, and they can make more money that way.

  Probably another reason subscription exists, is that it's hard to do seamless micro-transactions. When you do an DeFi payment, typically only your wallet pops up immediately,
  and you can click pay, and it just works. When you do for example a PayPal payment, you often have to log-in again, the payment website loads really slowly, etc.
  This could easily be fixed by the payment processors, if they actually cared. But obviously they don't.
]

#section[
  = What can you do?
  Consider paying or donating to the software you use daily. For example use #flink("https://kagi.com/")[Kagi search], donate to your linux desktop environemnt developers,
  buy songs as directly from artists as possible, ...
]

#br()#br()#br()

]
