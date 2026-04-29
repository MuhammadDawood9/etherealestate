"""
Reads data/lahore_housing_prices.csv and writes data/lahore_properties_clean.json.

Transformations applied:
  - Strip province suffix from Location ("DHA Defence, Lahore, Punjab" → "DHA Defence, Lahore")
  - Normalise Area to sqft (Kanal = 4500 sqft, Marla = 225 sqft; fractional Marla supported)
  - Convert Price (PKR) to a formatted string with commas
  - Add a stable UUID derived from house_id so the Flutter app can use it as a Firestore doc id
  - Drop rows with unparseable Area or Price
  - Deduplicate on house_id (keep first occurrence)
"""

import csv
import json
import re
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC  = ROOT / "data" / "lahore_housing_prices.csv"
DST  = ROOT / "data" / "lahore_properties_clean.json"

KANAL_SQFT = 4500
MARLA_SQFT = 225

PLACEHOLDER_IMAGES = [
    "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800",
    "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
    "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
    "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800",
    "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800",
    "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800",
]


def area_to_sqft(raw: str) -> float | None:
    raw = raw.strip()
    kanal = re.fullmatch(r"([\d.]+)\s*Kanal", raw, re.IGNORECASE)
    if kanal:
        return float(kanal.group(1)) * KANAL_SQFT
    marla = re.fullmatch(r"([\d.]+)\s*Marla", raw, re.IGNORECASE)
    if marla:
        return float(marla.group(1)) * MARLA_SQFT
    return None


def clean_location(raw: str) -> str:
    # Remove ", Punjab" or ", Sindh" etc. suffix after the city name
    parts = [p.strip() for p in raw.split(",")]
    # Typically: [Society, City, Province] — drop last if it looks like a province
    known_provinces = {"Punjab", "Sindh", "KPK", "Balochistan", "Islamabad Capital Territory"}
    if len(parts) >= 3 and parts[-1] in known_provinces:
        parts = parts[:-1]
    return ", ".join(parts)


def stable_uuid(house_id: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_DNS, f"etherealestate.lahore.{house_id}"))


def format_price(pkr: int) -> str:
    if pkr >= 10_000_000:
        crore = pkr / 10_000_000
        return f"PKR {crore:.1f} Cr"
    if pkr >= 100_000:
        lakh = pkr / 100_000
        return f"PKR {lakh:.1f} L"
    return f"PKR {pkr:,}"


def main() -> None:
    seen_ids: set[str] = set()
    properties: list[dict] = []

    with SRC.open(newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for i, row in enumerate(reader):
            house_id = row["house_id"].strip()
            if house_id in seen_ids:
                continue
            seen_ids.add(house_id)

            sqft = area_to_sqft(row["Area"])
            if sqft is None:
                continue

            try:
                price_pkr = int(row["Price"])
            except (ValueError, KeyError):
                continue

            try:
                beds = int(row["Bedroom(s)"])
                baths = int(row["Bath(s)"])
            except (ValueError, KeyError):
                continue

            location = clean_location(row["Location"])
            prop_type = row["Type"].strip()
            image_url = PLACEHOLDER_IMAGES[i % len(PLACEHOLDER_IMAGES)]

            properties.append({
                "id": stable_uuid(house_id),
                "sourceId": house_id,
                "title": f"{prop_type} in {location.split(',')[0].strip()}",
                "type": prop_type,
                "location": location,
                "price": format_price(price_pkr),
                "priceRaw": price_pkr,
                "areaSqft": int(sqft),
                "beds": beds,
                "baths": baths,
                "imageUrl": image_url,
            })

    DST.write_text(json.dumps(properties, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Written {len(properties)} properties -> {DST}")


if __name__ == "__main__":
    main()
