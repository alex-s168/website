set -e

rm -rf build
mkdir build

ln -s $(realpath res) build/res

git_rev=$(git rev-parse --short=12 HEAD)
git_commit_date=$(date -d @$(git log -1 --format=%at) +'%d. %B %Y %H:%M')

compile ()  {
    typst compile --root . --features html --input git_rev=$git_rev --input git_commit_date="$git_commit_date" -j 6 $@
}

page () {
    compile --format pdf --input web=false "pages/$1" "build/$1.min.pdf"
    compile --format html --input web=true "pages/$1" "build/$1.desktop.html"
    compile --format html --input web=false "pages/$1" "build/$1.min.html"
}

page "article-make-regex-engine-1.typ"
page "project-etc-nand.typ"
page "index.typ"
page "compiler-pattern-matching.typ"
page "article-favicon.typ"

rm -rf res/badges && mkdir res/badges && typst query common.typ "<meta-people>" --root . --input query=true --field value --one | jq -r . | jq -r 'to_entries[] | [.key,.value.badge] | @tsv' | awk '{ if ($1 == "alex") { system("cp res/badge.png res/badges/alex") } else { system("curl "$2" > res/badges/"$1) } }'
for b in res/badges/*; do
    bn=$(basename $b)
    if [ -f res/badge_sum_$bn ]; then
        cat res/badge_sum_$bn | sha256sum -c
    else
        echo WRITING CHECK SUM OF $bn
        sha256sum $b > res/badge_sum_$bn
    fi
done

cp build/index.typ.desktop.html build/index.html
