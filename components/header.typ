#import "../common.typ": *
#import "../simple-page-layout.typ": variant-link

#let rev() = [
  #if is-nano [
    #if git_commit_date != "" [
      Last modified: #git_commit_date
      #if git_rev != "" [
        (Git \##raw(short_git_rev))
      ]
    ]
  ] else [
    #if git_rev != "" [
      Git revision #flink("https://github.com/alex-s168/website/tree/" + git_rev)[\##short_git_rev] \
    ]
    #if git_commit_date != "" [
      Modified at #git_commit_date
    ]
  ]
]

// authors is list of people in common:people
#let rev-and-authors(authors) = [
  #rev()

  Written by #authors.map((p) => person(p)).join[, ]
]

#let pdf-readability() = {
  if is-web {section[
    Note that the #variant-link([PDF Version], ".min.pdf") of this page might look a bit better styling wise.
  ]}
}
