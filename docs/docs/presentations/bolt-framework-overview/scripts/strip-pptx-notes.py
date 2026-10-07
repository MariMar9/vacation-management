#!/usr/bin/env python3
"""Remove every speaker note from a Slidev PPTX export.

Slidev writes the markdown HTML comments into the PPTX as notesSlide parts. In
this deck those notes are internal presenter guidance — what not to claim, which
objections to pre-empt, which figures are not measurements. A client who opens
the file in PowerPoint can read all of it.

So: strip the notes before any PPTX leaves the building. The PDF export does not
carry them (it is rasterised per slide), only the PPTX does.

    python scripts/strip-pptx-notes.py bolt-framework-client.pptx

Rewrites the file in place, dropping:
  - ppt/notesSlides/**            the note content
  - the notesSlide relationships   from each slide's .rels
  - the notesSlide overrides       from [Content_Types].xml

Exits non-zero if the file still contains a notesSlide afterwards, so it can be
chained into a release step and actually fail when it should.
"""

import os
import re
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

NOTES_PART = re.compile(r"^ppt/notesSlides/")
NOTES_REL = re.compile(
    r'<Relationship[^>]*Type="[^"]*/notesSlide"[^>]*/>'
)
NOTES_OVERRIDE = re.compile(
    r'<Override[^>]*PartName="/ppt/notesSlides/[^"]*"[^>]*/>'
)


def strip(path: Path) -> int:
    if not path.is_file():
        print(f"error: {path} not found", file=sys.stderr)
        return 2

    with zipfile.ZipFile(path) as src:
        names = src.namelist()
        notes = [n for n in names if NOTES_PART.match(n)]
        if not notes:
            print(f"{path.name}: no speaker notes present, nothing to do")
            return 0

        # close the descriptor before writing: on Windows an open handle keeps
        # the file locked and the move below fails with WinError 32
        fd, tmp_name = tempfile.mkstemp(suffix=".pptx")
        os.close(fd)
        tmp = Path(tmp_name)
        with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as dst:
            for item in src.infolist():
                name = item.filename
                if NOTES_PART.match(name):
                    continue
                data = src.read(name)
                if name == "[Content_Types].xml":
                    data = NOTES_OVERRIDE.sub(
                        "", data.decode("utf-8")
                    ).encode("utf-8")
                elif name.startswith("ppt/slides/_rels/"):
                    data = NOTES_REL.sub("", data.decode("utf-8")).encode("utf-8")
                dst.writestr(item, data)

    shutil.move(str(tmp), str(path))

    with zipfile.ZipFile(path) as check:
        left = [n for n in check.namelist() if NOTES_PART.match(n)]
    if left:
        print(f"error: {len(left)} notes part(s) survived", file=sys.stderr)
        return 1

    print(f"{path.name}: removed {len(notes)} speaker-note part(s)")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(strip(Path(sys.argv[1])))
