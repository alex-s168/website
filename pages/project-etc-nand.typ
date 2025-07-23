#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../components/pcb-view.typ": *
#import "../components/header.typ": *

#let pcb-size-percent = 80
#let qpcb(file) = {
  let p = res-path()+"etc-nand/"+file
  pcb(p+"_front.png", p+"_back.png", size-percent: pcb-size-percent)
}

#simple-page(
  gen-table-of-contents: true,
  [etc-nand]
)[


#section[
  #title[ etc-nand ]
]

// #pdf-readability()

#if is-web {section[
  You can click the PCB images to switch to the other side.
]}

#section[
  = Overview

  etc-nand is a real-world #link("https://github.com/ETC-A/etca-spec/")[ ETC.A ] CPU built from almost only quad NAND gate ICs (74hc00)

  It will probably be finished in a few months.
]

#section[
  == Estimates

  Estimated gate count:
  - 2800 NAND gates
  - 320 tristate buffers

  #br()
  Estimated component counts:
  - 700x 74hc00 quad NAND gates
  - 40x 74HC54 octal tristate buffers
  - a few simple resistors
]

#section[
  == Planned Specifications
  ETC.A base instruction set + byte operations + S&F + Von Neumann

  The CPU will communicate with peripherals over a 16 bit data + 15 bit address memory bus
]

#section[
  = Purchase
  You will be able to purchase one in the future.

  Stay tuned!
]

#section[
  = Images
  Images of PCBs that are either already manifactured or currently beeing manifactured by JLCPCB.
]

#section[
  == 16 bit register
  #context qpcb("reg16")
]

#section[
  == 8 bit ALU slice
  A #link(<add8>)[8 bit adder module] will be placed in the middle
  #context qpcb("alu8")
]

#section[
  == 8 bit adder <add8>
  #context qpcb("add8")
]


]
