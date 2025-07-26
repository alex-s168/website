
// don't import this file directly! it will be post processed by the build script
// generates build/pages.typ

// first element in list will show up first in the homepage and the feed => needs to be newest article!
#let articles = (
  (
    page: "article-gpu-arch-1.typ",
    // unfinished
    feed: false,
    homepage: false,
  ),
  (
    page: "compiler-pattern-matching.typ",
    feed: true,
    homepage: true,
  ),
  (
    page: "article-favicon.typ",
    feed: true,
    homepage: true,
  ),
  (
    page: "article-make-regex-engine-1.typ",
    feed: true,
    homepage: true,
  ),
)

#metadata(articles) <articles>
