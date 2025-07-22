#import "../common.typ": *

#let rev() = [
  #if git_rev != "" {[
    Git revision #flink("https://github.com/alex-s168/website/tree/" + git_rev)[\##short_git_rev]
  ]}

  #if git_commit_date != "" {[
    Modified at #git_commit_date
  ]}
]

// authors is list of people in common:people
#let rev-and-authors(authors) = [
  #rev()

  Written by #authors.map((p) => person(p)).join[, ]
]
