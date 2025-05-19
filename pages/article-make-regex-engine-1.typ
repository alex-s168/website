#import "../common.typ": *
#import "../simple-page-layout.typ": *
#import "../core-page-style.typ": *

#simple-page(
  gen-table-of-contents: true
)[

#section[
  #title[Making a simple RegEx engine]

  #title[Part 1: Introduction to RegEx]

  #sized-p(small-font-size)[
    Written by alex_s168
  ]
]

#if is-web {section[
  Note that the #min-pdf-link[PDF Version] of this page might look a bit better styling wise.
]}

#section[
  = Introduction
  If you are any kind of programmer,
  you've probably heard of #flink("https://en.wikipedia.org/wiki/Regular_expression", "RegEx")
  
  RegEx (Regular expression) is kind of like a small programming language 
  used to define string search and replace patterns.
  
  \
  RegEx might seem overwhelming at first, but you can learn the most important features of RegEx very quickly.
  
  \
  It is important to mention that there is not a single standard for RegEx syntax,
  but instead each "implementation" has it's own quirks, and additional features.
  Most common features however behave identically on most RegEx "engines"/implementations.
]

#section[
  = Syntax
  The behavior of RegEx expressions / patterns depends on the match options passed to the RegEx engine.
  
  Common match options: <match-options>
  - Anchored at start and end of line
  - Case insensitive
  - multi-line or instead whole string
]

#section[
  == "Atoms"
  In this article, we will refer to single expression parts as "atoms".
]

#section[
  === Characters
  Just use the character that you want to match. For example ```re a``` to match an `a`.
  This however does not work for all characters, because many are part of special RegEx syntax.
]

#section[
  === Escaped Characters <escaped-chars>
  Thee previously mentioned special characters like `[` can be matched by putting a backslash in front of them: ```re \[```

  #context html-frame[
    #table(
      columns: (auto,auto),
      table.header(
        [Pattern],
        [Description]
      ),
  
      [```re \\```], [match a literal backslash],
      [```re \n```], [match a new-line],
    )
  ]
]

#section[
  === Character Groups <char-groups>
  RegEx engines already define some groups of characters that can make writing RegEx expressions quicker.

  #context html-frame[
    #table(
      columns: (auto,auto),
      table.header(
        [Pattern],
        [Description],
      ),
      
      [```re .```], [any character except for line breaks],
      [```re \s```], [any whitespace or line break],
      [```re \S```], [any character except whitespaces or line breaks],
      [```re \d```], [any digit from 0 to 9],
      [```re \D```], [any character except digits from 0 to 9],
      [```re \w```], [a letter, digit, or underscore],
      [```re \W```], [any character except for letters, digits, and underscores],
    )
  ]
]

#section[
  === Anchors
  ```re ^``` is used to assert the beginning of a line in multi-line mode,
  or the beginning of the string in whole-string mode.

  ```re $``` is used to assert the end of a line in multi-line mode,
  or the end of the string in whole-string mode.
  
  The behaviours of these depend on the #slink(<match-options>)[match options] 
]

#section[
  == Greedy VS Lazy <greedy>
  Some combinators will either match "lazy", or "greedy".

  Lazy is when the engine only matches as many characters required to get to the next step.
  This should almost always be used.

  Greedy matching is when the engine tries to match as many characters as possible.
  The problem with this is that it might cause "backtracking",
  which happens when the engine goes back in the pattern multiple times to ensure that as many characters
  as possible where matched. This can cause big performance issues.
]

#section[
  == Combinators
  Multiple atoms can be combined together to form more complex patterns.
]

#section[
  === Chain
  When two expressions are next to each other, they will be chained together,
  which means that both will be evaluated in-order.

  Example: ```re x\d``` matches a `x` and then a digit, like for example `x9`
]

#section[
  === Or
  Two expressions separated by a `|` cause the RegEx engine to first try to match the left side,
  and only if it fails, it tries the right side instead.

  Note that "or" has a long left and right scope,
  which means that ```re ab|cd``` will match either ```re ab``` or ```re cd```
]

#section[
  === Or-Not  
  Tries to match the expression on the left to it, but won't error if it doesn't succeed.

  Note that "or-not" has a short left scope,
  which means that ```re ab?``` will always match ```re a```, and then try to match ```re b```
]

#section[
  === Repeated
  A expression followed by either a ```re *``` for #slink(<greedy>)[greedy] repeat,
  or a ```re *?``` for #slink(<greedy>)[lazy] repeat.

  This matches as many times as possible, but can also match the pattern zero times.

  Note that this has a short left scope.
]

#section[
  === Repeated At Least Once
  A expression followed by either a ```re +``` for #slink(<greedy>)[greedy] repeat,
  or a ```re +?``` for #slink(<greedy>)[lazy] repeat.

  This matches as many times as possible, and at least one time.

  Note that this has a short left scope.
]

#section[
  === (Non-Capture) Group <non-capture-group>
  Groups multiple expressions together for scoping.

  Example: ```re (?:abc)``` will just match `abc`
]

#section[
  === Capture Group
  Similar to #slink(<non-capture-group>)[Non-Capture Groups] except that they capture the matched text.
  This allows the matched text of the inner expression to be extracted later.

  Capture group IDs are enumerated from left to right, starting with 1.

  Example: ```re (abc)de``` will match `abcde`,
  and store `abc` in group 1. 
]

#section[
  === Character Set
  By surrounding multiple characters in square brackets,
  the engine will match any of them.
  Special characters or expressions won't be parsed inside them,
  which means that this can also be used to escape characters.

  For example: ```re [abc]``` will match either `a`, `b` or `c`.

  and ```re [ab(?:c)]``` will match either `a`, `b`, `(`, `?`, `:`, `c`, or `)`.

  #slink(<char-groups>)[Character groups] and #slink(<escaped-chars>)[escaped characters]
  still work inside character sets.

  Character sets can also contain ranges.
  For example: ```re [0-9a-z]``` will match either any digit, or any lowercase letter.
]

#section[
  = Conclusion
  RegEx is perfect for when you just want to match some patterns,
  but the syntax can make patterns very hard to read or modify.

  In the next article, we will start to dive into implementing RegEx.

  Stay tuned!
]



]
