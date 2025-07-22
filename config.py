import os.path

gen = """
rule regen
  command     = python config.py
  generator   = 1

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
  command = cp $in $out

build build/badges.txt: badges_list common.typ

build build.ninja: regen config.py build/badges.txt
"""

pages = [
    "article-make-regex-engine-1.typ",
    "project-etc-nand.typ",
    "index.typ",
    "compiler-pattern-matching.typ",
    "article-favicon.typ",
]

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

for page in pages:
    gr = "build/" + page + ".git_rev.txt"
    gen += "\n"
    gen += "build "+gr+" : git_inp pages/" + page
    for var in variants:
        gen += "\n"
        gen += "build build/" + page + var["suffix"] + " : typst " + "pages/" + page + " | "+gr+"\n"
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
        gen += "\n"
        gen += "build res/badges/" + user + ": "
        if user == "alex":
            gen += "cp res/badge.png\n"
        else:
            gen += "curl\n"
            gen += "  url = "+url+"\n"

gen += "\n"
gen += "build build/index.html : cp build/index.typ.desktop.html\n"

with open("build.ninja", "w") as f:
    f.write(gen)
