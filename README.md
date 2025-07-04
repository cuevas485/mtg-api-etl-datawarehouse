# Magic: The Gathering Star Schema Warehouse (via Scryfall API)

This project extracts data from the [Scryfall API](https://scryfall.com/docs/api), transforms it into a clean and analyzable format, and stores it using a dimensional model (star schema). It supports daily refresh of card prices and historical tracking while enabling insights into card metadata, keywords, color identity, legalities, and more.

---

## Star Schema Design

- `card_fact` – Primary fact table (1 row per card), with attributes like name, power, toughness, etc.
- `price_fact` – Time-series fact table for daily prices (1 row per card per day)
- `dim_rarity` – Card rarity dimension
- `dim_set` – Set metadata
- `dim_type` – Supertypes, types, and subtypes (e.g., “Creature — Elf”)
- `dim_color` – Exploded color identity (1 row per card-color)
- `dim_keywords` – Exploded keyword abilities (e.g., "Flying")
- `dim_legalities` – Format legality flags by game mode

---

## ETL Workflow Summary

1. **Extract** – Full card data is downloaded from Scryfall’s bulk endpoint.
2. **Transform** – Normalize, explode, and map data into fact/dim tables.
3. **Load** – Save all data into separate CSVs, with price snapshots daily.

---

## Price Fact Table

The `price_fact_df` tracks market prices for each Magic: The Gathering card on a daily basis.

| Column               | Description |
|----------------------|-------------|
| `price_fact_id`      | Primary key for the table |
| `id`                 | Unique card identifier (FK to `card_fact`) |
| `date_loaded`        | Date the price was recorded (supports time-series tracking) |
| `prices.usd`         | Market price in USD |
| `prices.usd_foil`    | Foil version price in USD |
| `prices.usd_etched`  | Etched foil version price in USD |
| `prices.eur`         | Market price in EUR |
| `prices.eur_foil`    | Foil version price in EUR |
| `prices.tix`         | Magic: The Gathering Online (MTGO) price |

> ⚠Missing values (e.g., for non-foil cards) are recorded as `None`.

---

## How to Run

1. Clone this repository
2. Install required Python packages (`pandas`, `requests`)
3. Run the Jupyter notebook or `.py` script

---

## Use Cases

- Analyze card price trends over time
- Compare foil vs non-foil valuation
- Identify fluctuations in MTGO prices
- Power visualizations and dashboards for collectors or traders

---

## Future Enhancements

- Automate daily runs using dbt or Airflow
- Store data in a relational database (e.g., PostgreSQL, BigQuery)
- Create visual dashboards (Tableau, Power BI)
- Add `dim_purchase_url` for TCGPlayer/Cardmarket links

---

_Last updated: 2025-07-03_
