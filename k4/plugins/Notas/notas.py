#!/usr/bin/env python3
"""Small, dependency-free Markdown store for the K4 Notes plugin.

Each note is one ``<uuid>.md`` file.  The metadata is a JSON object inside a
Markdown front-matter block so the files remain easy to copy and edit by hand
without needing a YAML dependency at runtime.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import tempfile
import time
import uuid
from pathlib import Path


NOTES_DIR = Path.home() / "Documents" / "Notes"
ID_RE = re.compile(r"^[0-9a-fA-F-]{8,64}$")


def fail(message: str, code: int = 1) -> None:
    print(json.dumps({"ok": False, "error": message}, ensure_ascii=False))
    raise SystemExit(code)


def ensure_dir() -> None:
    NOTES_DIR.mkdir(parents=True, exist_ok=True)


def note_path(note_id: str) -> Path:
    if not ID_RE.fullmatch(note_id):
        fail("Недопустимый идентификатор заметки")
    path = (NOTES_DIR / (note_id + ".md")).resolve()
    if path.parent != NOTES_DIR.resolve():
        fail("Недопустимый путь заметки")
    return path


def clean_tags(value) -> list[str]:
    if isinstance(value, str):
        values = value.split(",")
    elif isinstance(value, list):
        values = value
    else:
        values = []

    result = []
    seen = set()
    for item in values:
        tag = str(item).strip().lstrip("#")
        if tag and tag not in seen:
            result.append(tag)
            seen.add(tag)
    return result


def normalized(data: dict, note_id: str | None = None, old: dict | None = None) -> dict:
    old = old or {}
    ident = str(data.get("id") or note_id or old.get("id") or uuid.uuid4())
    title = str(data.get("title", old.get("title", ""))).strip()
    if not title:
        fail("Название заметки обязательно")

    now = int(time.time())
    created = int(old.get("created") or data.get("created") or now)
    return {
        "id": ident,
        "title": title,
        "description": str(data.get("description", old.get("description", ""))).strip(),
        "completed": bool(data.get("completed", old.get("completed", False))),
        "tags": clean_tags(data.get("tags", old.get("tags", []))),
        "created": created,
        "updated": now,
        "body": str(data.get("body", old.get("body", ""))),
    }


def parse(path: Path) -> dict | None:
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError:
        return None

    if not raw.startswith("---\n"):
        return None
    end = raw.find("\n---\n", 4)
    if end < 0:
        return None
    try:
        data = json.loads(raw[4:end])
    except (TypeError, ValueError):
        return None
    if not isinstance(data, dict) or not data.get("id") or not data.get("title"):
        return None

    data["id"] = str(data["id"])
    data["title"] = str(data["title"])
    data["description"] = str(data.get("description", ""))
    data["completed"] = bool(data.get("completed", False))
    data["tags"] = clean_tags(data.get("tags", []))
    data["created"] = int(data.get("created", 0) or 0)
    data["updated"] = int(data.get("updated", data["created"]) or data["created"])
    data["body"] = raw[end + len("\n---\n") :]
    return data


def encoded(note: dict) -> str:
    metadata = {key: note[key] for key in (
        "id", "title", "description", "completed", "tags", "created", "updated"
    )}
    return "---\n" + json.dumps(metadata, ensure_ascii=False) + "\n---\n" + note["body"]


def write(note: dict) -> dict:
    ensure_dir()
    path = note_path(note["id"])
    fd, temporary = tempfile.mkstemp(prefix=".k4-note-", suffix=".md", dir=NOTES_DIR)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            stream.write(encoded(note))
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        try:
            os.unlink(temporary)
        except FileNotFoundError:
            pass
    return note


def list_notes() -> None:
    ensure_dir()
    notes = []
    for path in sorted(NOTES_DIR.glob("*.md")):
        note = parse(path)
        if note is not None:
            notes.append(note)
    notes.sort(key=lambda note: (note["completed"], -note["updated"], note["title"].casefold()))
    print(json.dumps({"ok": True, "notes": notes}, ensure_ascii=False))


def save_note(payload: str) -> None:
    try:
        data = json.loads(payload)
    except (TypeError, ValueError):
        fail("Некорректные данные заметки")
    if not isinstance(data, dict):
        fail("Некорректные данные заметки")

    ident = str(data.get("id") or uuid.uuid4())
    path = note_path(ident)
    old = parse(path) if path.is_file() else None
    note = normalized(data, ident, old)
    print(json.dumps({"ok": True, "note": write(note)}, ensure_ascii=False))


def delete_note(note_id: str) -> None:
    path = note_path(note_id)
    try:
        path.unlink()
    except FileNotFoundError:
        fail("Заметка уже удалена")
    print(json.dumps({"ok": True, "id": note_id}, ensure_ascii=False))


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="action", required=True)
    subparsers.add_parser("list")
    save_parser = subparsers.add_parser("save")
    save_parser.add_argument("--payload", required=True)
    delete_parser = subparsers.add_parser("delete")
    delete_parser.add_argument("--id", required=True)
    args = parser.parse_args()

    if args.action == "list":
        list_notes()
    elif args.action == "save":
        save_note(args.payload)
    elif args.action == "delete":
        ensure_dir()
        delete_note(args.id)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        pass
