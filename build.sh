set -e

rm -rf build
mkdir build

ln -s $(realpath res) build/res

page () {
    last_modified=$(git log -1 --format="%ad" --date="format:%d. %B %Y %H:%M" -- "pages/$1")
    full_commit_hash=$(git log -1 --format="%H" -- "pages/$1")
    git_inp=(--input "git_rev=$full_commit_hash" --input "git_commit_date=$last_modified")

    typst compile --root . --features html -j 6 "${git_inp[@]}" --format pdf --input web=false "pages/$1" "build/$1.min.pdf"
    typst compile --root . --features html -j 6 "${git_inp[@]}" --format html --input web=true "pages/$1" "build/$1.desktop.html"
    typst compile --root . --features html -j 6 "${git_inp[@]}" --format html --input web=false "pages/$1" "build/$1.min.html"
    typst compile --root . --features html -j 6 "${git_inp[@]}" --format html --input web=false --input nano=true "pages/$1" "build/$1.nano.html"
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
