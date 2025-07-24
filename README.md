# 🧙‍♂️ Magic: The Gathering Star Schema Warehouse (via Scryfall API)

This project extracts Magic: The Gathering card data from the [Scryfall API](https://scryfall.com/docs/api), transforms it using a star schema design, and loads it into [Google BigQuery](https://cloud.google.com/bigquery) for analysis. It supports snapshotting price history, tracking card metadata, and enabling rich analytics via SQL or visualization tools.

---

## Star Schema Design

### Fact Tables

- **`fact_card`** – One row per card. Includes release date, stats, rarity, set, and card type.
- **`fact_price`** – Daily snapshot of card prices, one row per card per load date.

### Dimension Tables

| Table             | Description |
|------------------|-------------|
| `dim_rarity`      | Rarity levels (e.g. common, rare, mythic) |
| `dim_set`         | MTG set metadata (code, name, type) |
| `dim_type`        | Supertypes, types, and subtypes (e.g., “Creature — Elf”) |
| `dim_colors`      | Exploded color identity (1 row per card-color) |
| `dim_keywords`    | Exploded keyword abilities (e.g., “Flying”) |
| `dim_legalities`  | Legal status of each card in various formats |
| `dim_image`       | Card image URIs (if available) |
| `dim_purchase`    | Purchase links (e.g. TCGPlayer, Cardmarket) |

---

## ETL Workflow Summary

1. **Extract**
   - Download latest `default_cards` bulk data from Scryfall's public API.
2. **Transform**
   - Flatten nested structures with `pandas.json_normalize`
   - Explode list fields (like colors, keywords) into separate dimension tables
   - Map hierarchies (e.g. type parsing from `type_line`)
   - Handle nulls and sparse fields (e.g. purchase/image URIs)
3. **Load**
   - Load dimension and fact tables into BigQuery
   - Clean and standardize column names for SQL compatibility
   - Append or truncate as appropriate
   - Save daily `fact_price` snapshots to CSV for archival

---

## Price Fact Table Schema (`fact_price`)

| Column               | Description |
|----------------------|-------------|
| `price_fact_id`      | Auto-incrementing key |
| `id`                 | Card UUID (FK to `fact_card`) |
| `prices_usd`         | Market price (USD) |
| `prices_usd_foil`    | Foil version price (USD) |
| `prices_usd_etched`  | Etched foil price (USD) |
| `prices_eur`         | Market price (EUR) |
| `prices_eur_foil`    | Foil version price (EUR) |
| `prices_tix`         | MTGO price |
| `date_loaded`        | Date of snapshot |

> Prices may be `null` for formats or printings where data is unavailable.

---

## Other Dimension Highlights

- **`dim_image`** only retains rows where at least one image URL exists (removes all-null rows).
- **`dim_purchase`** contains eCommerce links and similarly drops fully null rows.
- **`dim_type`** is parsed from `type_line`, breaking it into supertypes, types, and subtypes.

---

## How to Run

### Prerequisites

1. Clone the repo:
   ```bash
   git clone https://github.com/your-repo/MTG-Scryfall-Datawarehouse
   cd MTG-Scryfall-Datawarehouse
   ```

2. Create a GCP project and enable:
   - BigQuery API
   - Cloud Storage API

3. Create a service account (`mtg-pipeline-sa`) and grant:
   - BigQuery Data Editor
   - BigQuery Job User
   - Storage Admin  
   Then download the JSON key file and place it in the project directory.

4. Install dependencies:
   ```bash
   pip install pandas requests google-cloud-bigquery pyarrow
   ```

### Run the pipeline

Run the script or notebook to:
- Pull card data from the Scryfall API
- Transform it into fact/dim tables
- Write CSVs (including a daily `fact_price` snapshot)
- Upload data to BigQuery

---

## Use Cases

- Explore price trends of specific cards
- Compare rarity distributions across sets
- Track availability of cards across legal formats
- Enable dashboards in Looker, Power BI, or Tableau

---

## Future Enhancements

- Automate daily runs with Airflow or dbt
- Create views for latest prices per card
- Create summary table for visual tool ingestion (Looker)

---

_Last updated: 2025-07-24_
