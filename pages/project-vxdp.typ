
#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../components/pcb-view.typ": *
#import "../components/header.typ": *
#import "../components/donate.typ": *

#let pcb-size-percent = 80
#let qpcb(file) = {
  let p = res-path()+"etc-nand/"+file
  pcb(p+"_front.png", p+"_back.png", size-percent: pcb-size-percent)
}

#simple-page(
  gen-table-of-contents: true,
  [vxdp]
)[


#html-opt-elem("header", (:), section[
  #title[ vxdp ]
])

#section[
  vxdp will be a new method of transporting Ethernet packets over cables. The goal is to be significantly cheaper than 10Base-T and even 10Base-T1L.

  The main target application is embedded and industrial contexts, like connecting actuators inside robots, servo drives inside machines, toolhead boards inside 3d-printers, etc.

  The goal is *not* to compete with Base-T for speed! Base-T will always be faster than anything we can reasonably achieve without custom ASICs and infinite RnD budget (for an example of what that would look like, see 40GBASE-T).

  We do however want to achieve high reliability for transporting at one to ten mbit/s inside a noisy environment, at almost no cost.
]

#section[
  = Cost measurement
  If you want to use ethernet inside a machine, the costs are: a PHY, a MCU with MAC (or an PHY with MAC), pulsing transformer, connector, and an L2 switch.

  This adds up really quickly. That's probably one of the reasons CANbus is so popular.

  Our base measurement for cost combines:
  - two ports (including conenctors)
  - an L2 switch, for the two ports, and one host connection
]

#section[
  = Why Base-T is expensive
  == 1. PHY
  Base-T requires a really fancy PHY (the transceiver). Don't get me wrong, Base-T PHYs are genius, and absolutely required for longer distances or noisy environments at gigabit speed, but at 1-10mbit/s, it's absolutely overkill.
]

#section[
  == 2. Pulse Transformer
  Each Base-T port also requires a pulse transformer module. These modules consist of 4 tiny isolating transformers, plus 4 tiny transformers as CMC. Look up "ethernet pulse transformer"...

  We don't need these modules, because most vxdp applications do not require isolation between conenections, and if they do, vxdp uses an digital isolator for signalls, and an flyback transformer for power delivery (also replacing PoE), and because we run at much lower speeds.
]

#section[
  == 3. fancy connector & MAC interface
  An Rj45 connector is also not free,

  and the interface between the PHY and the system processor takes up a bit of hardware space on the processor, so a lot of really affordable microcontrollers don't have it built-in.
]

#section[
  == 4. L2 switches
  3-port L2 switches cost a few bucks as well
]

#section[
  = vxdp hardware overview
  - for eg. machine-internal connections, we use a 5-pin JST-PH connector
  - Cables carry two simplex differential twisted pairs (one in each direction), crossing over the two pairs, plus the shielding, connected to the 5th pin
  - We use dirt cheap RS-485 transceiver chips basically as PHYs
  - For optional power delivery, we use one of the many dirt cheap integrated 10mbit/s digital isolators (which use fancy semiconductor tech to galvanically isolate signals without transformers), and an fylback transformer for up/down conversion, and isolation. This is much cheaper than PoE aswell.
  - The switch / mcu handle the line encoding, and the protocol
]

#section[
  = vxdp protocol
  We do not just transmit ethernet frames, for efficiency and reliability reasons.

  Instead, we can transmit arbitrary sized packets with MAC destination (including *any* ethernet frame), by splitting it into many, many, small packets.

  Each of these small packet gets routed seperately, and will only be fully reassembled at the final destination.

  Every link (connection between two devices) buffers the mini packets it receives, and then immediately forwards it as soon as it validated the packet.
  The packets stay in the buffer for as long as possible, to allow for retransmission.

  When there is a short link interruption (caused through noise, or by switch overload), instead of dropping the whole ethernet frame (like in Base-T),
  vxdp links will instead automatically ask for retransmission. That way, short interruptions will not destroy the packet, and instead only delay it.
]

#section[
  This mini-packet system also allows for adding advanced QoS features. The packets from priority ethernet frames can interrupt lower priority ethernet frames, with much less data loss (only up to one mini-packet).

  This is especially useful inside machines or industrial environments.
]

#section[
  = Timeline
  - (DONE) October 9th 2026, first prototype L2 switch & phy PCB designed
  - (WIP) October 11th 2026, power delivery stage PCB prototype PCB designed
  - October 12th 2026, PCBs ordered
  - October 23rd 2026, L2 switch & phy prototype PCB assembled, simple serial communication via specific line encoding working
  - October 26th 2026, power delivery hardware tested in isolation from the transceivers.
  - November 1st 2026, rough protocol design completed, and simulator created for testing various environments
  - November 5th 2026, protocol fully working as expected on hardware
  - November 14th 2026, more production-ready 3+1 port L2 switch with full power delivery&receive capabilities, PCB designed
  - November 25th 2026, above hardware assembled and working.
  - November 30th 2026, advanced protocol features/extensions working on hardware (QoS, time sensitivity, etc), protocol requirements achieved
  - December 7th 2026, formalized protocol draft
  - December 16th 2026, fully production-ready 1+1&2+1&3+1 PD switch/trx PCB designed
  - December 31st 2026, formalized protocol fully reviewed by multiple people, and carefully future-prooved
  - Janurary 11th 27, seller/"manufacturer" found, and starts selling the prod hardware
  - February 27, exact physical interface requirements and internal connection system formalized
  - August 27, multiple boards now available for purchase with vxdp integration (processor dev boards, actuators, stepper controllers, etc)
  - August 27, protocol working group established, and working on extension to the protocol / a version 2, or an extension feature set "2"
  - October 27, we ourselves sell hardware from Austria
]

#section[
  Subscribe to the #html-href("feed.typ.desktop.html")[feed] to get notified of vxdp progress.

  If you're interested in helping with, reviewing, or discussing protocol design, please #flink("https://alex.vxcc.dev")[contact me].
  There will be public protocol drafts open for reviews (will be up on the feed).

  Also contact me if you're interested in building hardware with vxdp, or selling vxdp-capable modules/devices.
]

#section[
  If you'd like to support this project, consider donating (over Cardano), so I can do quicker prototyping:
  - #donate-cardano(people.alex.cardano, mult:1)
  - #donate-cardano(people.alex.cardano, mult:7)
  - #donate-cardano(people.alex.cardano, mult:16)
]


]
