set -e

rm -rf build
mkdir build

compile ()  {
    typst compile --root . --features html -j 4 $@
}

page () {
    compile --format pdf --input web=false "pages/$1" "build/$1.min.pdf"
    compile --format html --input web=true "pages/$1" "build/$1.desktop.html"
    compile --format html --input web=false "pages/$1" "build/$1.min.html"
}

page "article-make-regex-engine-1.typ"
page "project-etc-nand.typ"
page "index.typ"

cp build/index.typ.desktop.html build/index.html
