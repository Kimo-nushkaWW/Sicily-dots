#!/usr/bin/env python3
"""Focused tests for the Notes file store."""

import json
import os
import pathlib
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
STORE = ROOT / "plugins" / "Notas" / "notas.py"


def run(*args, env):
    result = subprocess.run(
        [sys.executable, str(STORE), *args],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise AssertionError(result.stderr or result.stdout)
    data = json.loads(result.stdout)
    if not data.get("ok"):
        raise AssertionError(data)
    return data


def main():
    with tempfile.TemporaryDirectory() as temp:
        home = pathlib.Path(temp)
        env = os.environ.copy()
        env["HOME"] = str(home)
        payload = json.dumps({
            "title": "Первая заметка",
            "description": "Проверить хранилище",
            "body": "# Текст\n\nСодержимое",
            "tags": "тест, работа, тест",
        }, ensure_ascii=False)
        saved = run("save", "--payload", payload, env=env)["note"]
        assert saved["title"] == "Первая заметка"
        assert saved["tags"] == ["тест", "работа"]

        notes = run("list", env=env)["notes"]
        assert len(notes) == 1
        assert notes[0]["body"] == "# Текст\n\nСодержимое"

        updated = json.dumps({"id": saved["id"], "title": saved["title"], "completed": True}, ensure_ascii=False)
        run("save", "--payload", updated, env=env)
        notes = run("list", env=env)["notes"]
        assert notes[0]["completed"] is True
        assert notes[0]["body"] == "# Текст\n\nСодержимое"

        run("delete", "--id", saved["id"], env=env)
        assert run("list", env=env)["notes"] == []

    print("Notes store: ok")


if __name__ == "__main__":
    main()
