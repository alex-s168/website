#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../components/header.typ": *
#import "../components/geizhals-price.typ": *

#simple-page(
  gen-table-of-contents: true,
  [My Homelab & PC setup]
)[


#html-opt-elem("header", (:), section[
  #title[ My Homelab & PC setup ]
])

#section[
  = Workstation
  == PC
  - Ryzen 5 7600X (Live pricing: #geizhals-price(2801237, 147))
  - 4x Kingston FURY Beast RGB black UDIMM 16GB DDR5-4800 (KF560C36-16)
  - Radeon RX 6700 XT
  - 2x LG ULTRAGEAR 403NTPC3P936
  - XP-Pen Artist Ultra 16
  - MX Keys S
  - random-ass mouse
  - #strike[WinWing] WinCtrl URSA MINOR Fighter Joystick R

  == Software
  - #link("https://chimera-linux.org")[Chimera Linux] + KDE Plasma
  - #link("https://mullvad.net")[Mullvad VPN]
  - vanilla Firefox, sadly
  - #link("https://gram-editor.com")[Gram Editor]
  - neovim (#link("https://github.com/alex-s168/nvim-config")[config])
  - Tidal for music streaming
  - Mixxx for offline music listening
  - Thunderbird as E-Mail client
  - Krita
  - #link("https://ente.com")[Ente Photos]
  - #link("https://sable.moe")[Sable matrix client]

  == Networking
  - 1x basic-ahh managed 8-port gigabit Netgear switch
  - 1x basic-ahh PoE managed 8-port gigabit Netgear switch
    - with a waterproof isolated MeanWell PSU, because of the annoying-ass humming of the default PSU
  - 1x Arista DCS-7050QX-32, 40gbit qsfp really cool, amazing, and loud-asf managed switch, with ZTP over management VLAN from my PC

  == Server No1
  - Ryzen 9 9950X3D
  - MSI MAG B850 TOMAHAWK MAX WIFI
  - 2x32GB G.Skill Ripjaws S5 White DDR5-5200 CL36
  - 3x Crucial P3 Plus NVMe 2TB

  == Server No2
  - EPYC 7282
  - TYAN s8036
  - currently 2x #link("article-onix-lumi-arc-b580.typ.desktop.html")[Onix Lumi Arc B580], on PCIe - SlimSAS risers
    - in the future, up to 8x
  - one of these old 40G ConnectX ethernet cards
  - ASUS Pro WS 3000W (ouch)
]


]
