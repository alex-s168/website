import os

gen = """
build always: phony

rule regen
  command = python config.py
  generator = 1

rule update_git_rev
  command = git rev-parse HEAD > build/git_rev.txt.tmp && \
            cmp -s build/git_rev.txt.tmp build/git_rev.txt || mv build/git_rev.txt.tmp build/git_rev.txt; \
            rm -f build/git_rev.txt.tmp
  restat = 1
build build/git_rev.txt: update_git_rev | always

rule typst
  depfile = $out.d
  command = eval "typst compile --root . --features html -j 6 $flags $in $out --make-deps $out.d"

rule git_inp
  command = git log -1 --format="--input git_rev=%H --input git_commit_date=\\\"%ad\\\"" --date="format:%d. %B %Y %H:%M" -- $in > $out

rule badges_list
  command = typst query $in "<meta-people>" --root . --input query=true --field value --one | jq -r . | jq -r 'to_entries[] | [.key,.value.badge] | @tsv' > $out

rule curl
  command = curl $url > $out

rule cp
  command = cp $flags $in $out

rule cpdir
  command = rm -rf $out && cp -rf $in $outdir

rule runclean
  command = rm -rf build && ninja -t clean

rule ttf2woff
  command = fonttools ttLib.woff2 compress $in -o $out


build build/badges.txt: badges_list common.typ

build build.ninja: regen | config.py build/badges.txt res/fonts

build clean : runclean
"""

pages = [
    "article-make-regex-engine-1.typ",
    "project-etc-nand.typ",
    "index.typ",
    "compiler-pattern-matching.typ",
    "article-favicon.typ",
    "article-gpu-arch-1.typ",
]

fonts = [x for x in os.listdir("./res/fonts/")]

variants = [
    {
        "suffix": ".min.pdf",
        "args": "--format pdf --input web=false",
    },
    {
        "suffix": ".min.html",
        "args": "--format html --input web=false",
    },
    {
        "suffix": ".desktop.html",
        "args": "--format html --input web=true",
    },
    {
        "suffix": ".nano.html",
        "args": "--format html --input web=false --input nano=true",
    },
]

web_targets = []

for page in pages:
    gr = "build/" + page + ".git_rev.txt"
    gen += "\n"
    gen += "build "+gr+" : git_inp pages/" + page + " | build/git_rev.txt"
    for var in variants:
        tg = "build/" + page + var["suffix"]
        web_targets.append(tg)
        gen += "\n"
        gen += "build "+tg+" : typst " + "pages/" + page + " | "+gr+"\n"
        gen += "  flags = " + var["args"] + " $$(cat "+gr+")\n"

if os.path.isfile("build/badges.txt"):
    badges = None
    with open("build/badges.txt", "r") as f:
        badges = f.read().split("\n")
    for badge in badges:
        badge = badge.strip()
        if len(badge) == 0:
            continue
        badge = badge.split("\t")
        user = badge[0]
        url = badge[1]
        tg = "build/res/badges/" + user
        web_targets.append(tg)
        gen += "\n"
        gen += "build "+tg+": "
        if user == "alex":
            gen += "cp res/badge.png | build/res/_.txt\n"
        else:
            gen += "curl | build/res/_.txt\n"
            gen += "  url = "+url+"\n"

for font in fonts:
    font = font.replace(".ttf", "")
    tg = f"build/res/{font}.woff2"
    web_targets.append(tg)
    gen += "\n"
    gen += f"build {tg} : ttf2woff res/fonts/{font}.ttf | build/res/_.txt\n"

gen += "\n"
gen += "build build/index.html : cp build/index.typ.desktop.html\n"
web_targets.append("build/index.html")

gen += """
build build/res/_.txt : cpdir res | res/_.txt
  outdir = build
"""
web_targets.append("build/res/_.txt")

gen += """
build web: phony """+ " ".join(web_targets) +"""

rule pub_cmd
  command = rsync -avz build root@195.26.251.204:/srv/http/alex
  pool = console
build pub: pub_cmd web

default web
"""

with open("build.ninja", "w") as f:
    f.write(gen)
