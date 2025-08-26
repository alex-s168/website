import sys, json
from feedgen.feed import FeedGenerator

fg = FeedGenerator()

articles = 0
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

fg.author([v for _,v in all_authors.items()])

fg.id("https://alex.vxcc.dev")
fg.title("alex168's blog")
fg.subtitle("alex_s168's blog")
fg.icon("https://vxcc.dev/alex/res/favicon.png")
fg.language("en-US")
fg.link(href="https://alex.vxcc.dev/atom.xml", rel="self")
fg.link(href="https://alex.vxcc.dev/", rel="alternate")

for article in reversed(articles):
    page = article["page"]
    url = article["url"]
    title = article["title"]
    summary = article["summary"]
    modified = article["modified"]
    authors = article["authors"]

    content = None
    with open(f"./build/{page}.nano.html", "r") as f:
        content = f.read()

    fe = fg.add_entry()
    fe.id(f"https://vxcc.dev/alex/{url}")
    fe.title(title)
    fe.summary(summary)
    fe.link(href=url)
    fe.updated(modified)
    fe.content(content, type="html")

    fe.author([all_authors[x["nick"]] for x in authors])

fg.atom_file("build/deploy/atom.xml")
