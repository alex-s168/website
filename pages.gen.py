import sys, json, subprocess

def typst_encode_pre(e, ind="  "):
    if isinstance(e, dict):
        encode_key = json.dumps

        if len(e.items()) == 0:
            return ["(:)"]
        elif len(e.items()) == 1:
            k,v = list(e.items())[0]
            v = typst_encode_pre(v, ind)
            out = ["(" + encode_key(k) + ": " + v[0]]
            out.extend(v[1:])
            out[-1] = out[-1] + ")"
            return out
        else:
            out = ["("]
            first = True
            for k,v in e.items():
                if not first:
                    out[-1] = out[-1] + ","
                first = False
                v = typst_encode_pre(v, ind)
                out.append(ind + encode_key(k) + ": " + v[0])
                out.extend(ind+x for x in v[1:])
                out[-1] = out[-1]
            out.append(")")
            return out
    elif isinstance(e, list):
        if len(e) == 0:
            return ["()"]
        elif len(e) == 1:
            v = typst_encode_pre(e[0], ind)
            out = ["(" + v[0]]
            out.extend(v[1:])
            out[-1] = out[-1] + ")"
            return out
        else:
            out = ["("]
            first = True
            for v in e:
                if not first:
                    out[-1] = out[-1] + ","
                first = False
                v = typst_encode_pre(v, ind)
                out.append(ind + v[0])
                out.extend(ind+x for x in v[1:])
                out[-1] = out[-1]
            out.append(")")
            return out
    elif isinstance(e, bool):
        return ["true" if e else "false"]
    elif isinstance(e, int) or isinstance(e, float):
        return [str(e)]
    elif isinstance(e, str):
        # TODO: can do better (newlines)
        return [json.dumps(e)]
    else:
        raise ValueError(f"can't typst encode {e}")

def typst_encode(e):
    e = typst_encode_pre(e)
    return "\n".join(e)

def typst_query_one(path, tag):
    meta = subprocess.run([
        "typst", "query", path, tag,
        "--one",
        "--field", "value",
        "--root", ".",
        "--input", "query=true",
        "--features", "html"
    ], capture_output=True)
    meta = meta.stdout.decode("utf-8").strip()
    if len(meta) == 0:
        return None
    return json.loads(meta)

out = []
for page in typst_query_one("pages.in.typ", "<articles>"):
    p_page = page["page"]
    p_feed = page["feed"]
    p_homepage = page["homepage"]

    path = f"pages/{p_page}"

    meta = typst_query_one(path, "<feed-ent>")

    last_changed = None
    with open(f"build/{p_page}.git_rev.txt.iso", "r") as f:
        last_changed = f.read().strip()

    res = {
        "url": f"{p_page}.desktop.html",
        "page": p_page,
        "in-feed": p_feed,
        "in-homepage": p_homepage,
        "authors": meta["authors"],
        "title": meta["title"],
        "summary": meta["summary"],
        "modified": last_changed,
    }
    out.append(res)

with open("build/pages.typ", "w") as f:
    f.write("#let articles = " + typst_encode(out) + "\n")

with open("build/pages.json", "w") as f:
    json.dump(out, f)
