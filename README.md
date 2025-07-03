# mtg-api-etl-datawarehouse
A complete data engineering pipeline that extracts Magic: The Gathering card data from the Scryfall API, transforms it into a star schema, and stores it in a mini data warehouse. Includes a historical price fact table, dimensional modeling, and automated ETL logic for time-series insights.

# Magic: The Gathering Price Fact Table

This repository documents the structure and purpose of the **`price_fact_df`**, a fact table within a dimensional model designed to track daily price changes of Magic: The Gathering cards using the [Scryfall API](https://scryfall.com/docs/api).

---

## Table Structure

| Column               | Description |
|----------------------|-------------|
| `id`                 | Unique card identifier (FK to `card_fact`) |
| `date_loaded`        | Date the price was recorded (supports time-series tracking) |
| `prices.usd`         | Market price in USD |
| `prices.usd_foil`    | Foil version price in USD |
| `prices.usd_etched`  | Etched foil version price in USD |
| `prices.eur`         | Market price in EUR |
| `prices.eur_foil`    | Foil version price in EUR |
| `prices.tix`         | Magic: The Gathering Online (MTGO) price |

> ⚠️ Missing values (e.g., for non-foil cards) are recorded as `None`.

---

## Data Refresh Strategy

- Prices are fetched daily using the Scryfall API.
- Each load appends a new row for every card, capturing a snapshot of current market prices.
- The grain of the table is **one row per card per day**, allowing for historical trend analysis.

---

## Use Cases

- Analyze card price trends over time
- Compare foil vs non-foil valuation
- Identify fluctuations in MTGO prices
- Power visualizations and dashboards for collectors or traders

---

## Future Enhancements

- Integrate with tools like dbt or Airflow for automated daily loads

---

## Related Tables

- `card_fact` – Core fact table with card metadata
- `dim_rarity` – Card rarity (common, rare, etc.)
- `dim_set` – Set metadata (set name, type)
- `dim_type` – Supertypes, types, and subtypes (e.g., "Creature – Elf")
- `dim_color` – Color identity and color types
- `dim_legalities` – Format legality by game mode
- `dim_keywords` – Exploded list of card mechanics (e.g., "Flying")

