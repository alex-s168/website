import os

web_targets = []

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
  command = git log -1 --format="--input git_rev=%H --input git_commit_date=\\\"%ad\\\"" --date="format:%d. %B %Y %H:%M" -- $in > $out.temp && \
            cmp -s $out.temp $out || mv $out.temp $out; \
            rm -f $out.temp
  restat = 1

rule badges_list
  command = typst query $in "<meta-people>" --root . --input query=true --field value --one | jq -r . | jq -r 'to_entries[] | [.key,.value.badge] | @tsv' > $out
build build/badges.txt: badges_list common.typ

rule curl
  command = curl $url > $out

rule cp
  command = cp $flags $in $out

rule cpdir
  command = rm -rf $out && cp -rf $in $outdir

rule runclean
  command = rm -rf build && ninja -t clean
build clean : runclean

rule ttf2woff
  command = fonttools ttLib.woff2 compress $in -o $out

rule python_capture
  command = python $in > $out

rule minhtml
  command = minhtml --minify-js --minify-css $in -o $out

build build.ninja: regen | config.py build/badges.txt res pages

build build/deploy/coffee.js : python_capture gen_coffee_js.py

rule cargo_release_bin
  command = (cd $in && cargo build --release) && cp $in/target/release/$file $out
  pool = console

build build/coffee_server : cargo_release_bin coffee
  file = coffee

rule expect_img_size
  command = eval "[ $$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 $in) = $size ]" && touch $out

rule ffmpeg_compress
  command = ffmpeg -y -i $in -compression_level 100 $out -hide_banner -loglevel error

rule pngquant
  command = pngquant $in -o $out --force --quality $quality
"""

web_targets.append("build/deploy/coffee.js")
web_targets.append("build/coffee_server")

pages = [x for x in os.listdir("./pages/")]
fonts = [x for x in os.listdir("./fonts/")]

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
    gen += "build "+gr+" : git_inp pages/" + page + " | build/git_rev.txt"
    for var in variants:
        tg = "build/" + page + var["suffix"]
        gen += "\n"
        gen += "build "+tg+" : typst " + "pages/" + page + " | "+gr+"\n"
        gen += "  flags = " + var["args"] + " $$(cat "+gr+")\n"
        if tg.endswith(".html"):
            gen += "\n"
            deploy_tg = f"build/deploy/{page}"+var["suffix"]
            web_targets.append(deploy_tg)
            gen += f"build {deploy_tg} : minhtml {tg}\n"
        else:
            # TODO: pdf compressor thing?
            gen += "\n"
            deploy_tg = f"build/deploy/{page}"+var["suffix"]
            web_targets.append(deploy_tg)
            gen += f"build {deploy_tg} : cp {tg}\n"

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
        tg = f"build/deploy/res/badges/{user}"
        web_targets.append(tg)

        val = f"build/validate/deploy/res/badges/{user}"

        gen += "\n"
        gen += "build "+tg+": "
        if user == f"alex":
            gen += "cp res/badge.png |@ {val}\n"
        else:
            gen += f"curl |@ {val}\n"
            gen += "  url = "+url+"\n"

        gen += "\n"
        gen += f"build {val} : expect_img_size {tg}\n"
        gen += f"  size = 88x31"

for font in fonts:
    font = font.replace(".ttf", "")
    tg = f"build/deploy/res/{font}.woff2"
    web_targets.append(tg)
    gen += "\n"
    gen += f"build {tg} : ttf2woff fonts/{font}.ttf\n"

gen += "\n"
gen += "build build/deploy/index.html : cp build/deploy/index.typ.desktop.html\n"
web_targets.append("build/deploy/index.html")

manual_res = []

manual_res.append("res/favicon.png")
gen += "\n"
gen +=f"build build/deploy/res/favicon.png : pngquant res/favicon.png\n"
gen += "  quality = 1\n"

for root, dirnames, filenames in os.walk("res"):
    for file in filenames:
        file = os.path.join(root,file)
        if file in manual_res:
            continue
        tg = f"build/deploy/{file}"  # file includes "res/"!
        web_targets.append(tg)
        if any(file.endswith("."+x) for x in ["png", "jpg", "jpeg", "gif", "avif"]):
            gen += "\n"
            gen += f"build {tg} : ffmpeg_compress {file}\n"       
        else:
            gen += "\n"
            gen += f"build {tg} : cp {file}\n"

gen += """
build web: phony """+ " ".join(web_targets) +"""

rule pub_cmd
  command = rsync -avz build/deploy/* root@195.26.251.204:/srv/http/alex
  pool = console
build pub: pub_cmd web

default web
"""

with open("build.ninja", "w") as f:
    f.write(gen)
