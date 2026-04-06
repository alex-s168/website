import sys, json
from feedgen.feed import FeedGenerator


with open("build/pages.json", "r") as f:
    articles = json.load(f)
articles = [x for x in articles if x["in-feed"] == True]

all_authors = {}
for article in articles:
    authors = article["authors"]
    for author in authors:
        nick = author["nick"]
        name = author.get("name", nick)
        mail = author.get("mail", None)
        url = author.get("url", None)
        out = {"name":name}
        if mail:
            out["email"] = mail
        if url:
            out["uri"] = url
        all_authors[nick] = out


def gen(this_ty: str, this_mode: str) -> FeedGenerator:
    fg = FeedGenerator()

    fg.author([v for _,v in all_authors.items()])

    fg.id("https://alex.vxcc.dev")
    fg.title("alex-s168's blog")
    fg.description("Alexander Nutz (aka alex-s168)'s blog")
    fg.icon("https://vxcc.dev/alex/res/favicon.png")
    fg.language("en-US")
    for ty in ["rss", "atom"]:
        for (title, x) in [("Full", ""), ("Summaries", "-summary"), ("Recent full, others summary", "-hybrid")]:
            fg.link(href=f"https://alex.vxcc.dev/{ty}{x}.xml", type=f"application/{ty}+xml", rel="self" if ty == this_ty and x == this_mode else "alternate")

    fg.link(href="https://alex.vxcc.dev/", type="text/html", rel="alternate")

    for i, article in enumerate(reversed(articles)):
        page = article["page"]
        url = article["url"]
        title = article["title"]
        summary = article["summary"]
        modified = article["modified"]
        authors = article["authors"]
        tags = article.get("tags", [])

        content = None
        with open(f"./build/{page}.nano.html", "r") as f:
            content = f.read()

        fe = fg.add_entry()
        fe.id(f"https://vxcc.dev/alex/{url}")
        fe.title(title)
        fe.summary(summary)
        fe.link(href=url)
        fe.updated(modified)
        if this_mode == "" or (this_mode == "-hybrid" and (len(articles)-i-1) < 4):
            fe.content(content, type="html")

        fe.author([all_authors[x["nick"]] for x in authors])

        for tag in tags:
            fe.category(term=tag)

    return fg


gen("atom", "").atom_file("build/deploy/atom.xml")
gen("atom", "-summary").atom_file("build/deploy/atom-summary.xml")
gen("atom", "-hybrid").atom_file("build/deploy/atom-hybrid.xml")

gen("rss", "").rss_file("build/deploy/rss.xml")
gen("rss", "-summary").rss_file("build/deploy/rss-summary.xml")
gen("rss", "-hybrid").rss_file("build/deploy/rss-hybrid.xml")

