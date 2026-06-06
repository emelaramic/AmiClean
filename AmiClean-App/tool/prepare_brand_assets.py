"""Generira kružnu app ikonu iz kvadratnog izvora."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "images"
SRC = ASSETS / "app_icon.png"
DST = ASSETS / "app_icon_round.png"
SIZE = 1024
INSET = 0.04  # mali rub unutar kruga


def make_circular_icon() -> None:
    img = Image.open(SRC).convert("RGBA")
    img = img.resize((SIZE, SIZE), Image.Resampling.LANCZOS)

    inset_px = int(SIZE * INSET)
    mask = Image.new("L", (SIZE, SIZE), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((inset_px, inset_px, SIZE - inset_px, SIZE - inset_px), fill=255)

    output = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    output.paste(img, (0, 0), mask)
    output.save(DST, "PNG")
    print(f"Created {DST}")


if __name__ == "__main__":
    make_circular_icon()
