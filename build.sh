set -e

rm -rf build
mkdir build

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

cp build/index.typ.desktop.html build/index.html
