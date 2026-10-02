import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

MONTHS = (
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
)


def git_output(*args: str) -> str | None:
    try:
        return subprocess.check_output(["git", *args], text=True).strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None


def revision() -> str:
    return os.environ.get("SITE_REVISION") or git_output("rev-parse", "HEAD") or "nix-source"


def commit_date(path: str) -> tuple[str, str]:
    configured_date = os.environ.get("SITE_COMMIT_DATE")
    if configured_date:
        date = datetime.strptime(configured_date, "%Y%m%d%H%M%S").replace(tzinfo=timezone.utc)
        human = f"{date.day:02d}. {MONTHS[date.month - 1]} {date.year} {date:%H:%M}"
        return human, date.isoformat(timespec="seconds").replace("+00:00", "Z")

    human = git_output(
        "log", "-1", '--format=%ad', "--date=format:%d. %B %Y %H:%M", "--", path
    )
    iso = git_output("log", "-1", "--format=%cI", "--", path)
    if human and iso:
        return human, iso

    date = datetime.fromtimestamp(0, tz=timezone.utc)
    return f"{date.day:02d}. January {date.year} {date:%H:%M}", date.isoformat().replace("+00:00", "Z")


def write_if_changed(path: Path, contents: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_text() == contents:
        return
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(contents)
    temporary.replace(path)


def main() -> None:
    if len(sys.argv) == 3 and sys.argv[1] == "revision":
        write_if_changed(Path(sys.argv[2]), revision() + "\n")
        return

    if len(sys.argv) == 4 and sys.argv[1] == "page":
        page_path, output_path = sys.argv[2:]
        date, iso_date = commit_date(page_path)
        page_revision = os.environ.get("SITE_REVISION") or git_output(
            "log", "-1", "--format=%H", "--", page_path
        ) or revision()
        metadata = f'--input git_rev={page_revision} --input git_commit_date="{date}"\n'
        write_if_changed(Path(output_path), metadata)
        write_if_changed(Path(output_path + ".iso"), iso_date + "\n")
        return

    raise SystemExit("usage: git_metadata.py revision OUTPUT | page INPUT OUTPUT")


if __name__ == "__main__":
    main()
