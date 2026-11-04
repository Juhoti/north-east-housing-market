# North East Housing Market Analysis

Where in the North East of England can a first-time buyer still afford a home, and how has that changed since 2020?

The analysis uses HM Land Registry Price Paid Data for the twelve North East council areas, 2020 to 2025.

## Status

| Phase | Tool | Status |
|---|---|---|
| 1. Data preparation | SQL (DuckDB) | Complete |
| 2. Analysis and comparison with ONS earnings | Excel | In progress |
| 3. Interactive dashboard | Tableau Public | Planned |
| 4. Summary and slides for non-technical readers | Word, PowerPoint | Planned |

## Data

- [HM Land Registry Price Paid Data](https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads), yearly files 2020 to 2025. The files have no header row; the 16 columns are described in [About the Price Paid Data](https://www.gov.uk/guidance/about-the-price-paid-data).
- [ONS Housing affordability in England and Wales: 2025](https://www.ons.gov.uk/peoplepopulationandcommunity/housing/bulletins/housingaffordabilityinenglandandwales/2025), used in Phase 2.

The raw files (about 1 GB) are not stored in this repository. See [Reproducing](#reproducing).

## Phase 1: data preparation

| Stage | Sales |
|---|---|
| All sales in England and Wales, 2020 to 2025 | 6,044,045 |
| In the twelve North East council areas | 299,737 |
| Standard sales of homes | 235,563 |
| Price of £20,000 or more | 235,417 |

The twelve council areas are County Durham, Darlington, Gateshead, Hartlepool, Middlesbrough, Newcastle upon Tyne, North Tyneside, Northumberland, Redcar and Cleveland, South Tyneside, Stockton-on-Tees and Sunderland.

### Cleaning rules

- **Standard sales only** (`ppd_category = 'A'`). Category B covers repossessions, buy-to-let purchases and other transfers that do not reflect what a first-time buyer pays. This removes about a fifth of North East sales.
- **Homes only** (`property_type <> 'O'`). Every type O (other) sale in the data is also category B, so this filter removes no further rows. It is kept so the rule is explicit.
- **Price floor of £20,000.** Below £20,000, sales occur at about 14 per £1,000 of price; between £20,000 and £22,500 the rate is about 77 per £1,000. Sales below the floor are treated as non-market transfers. The rule removes 146 sales (0.06%). No upper limit is applied: high-value sales are genuine and fall outside any first-time-buyer budget.
- No date filter is needed: every sale in the 2020 to 2025 yearly files falls within those years.

### Checks

- Row counts in DuckDB match the line counts of the raw files (for example, 898,194 sales in 2020).
- [`output/counts_by_district_year.csv`](output/counts_by_district_year.csv) gives sales per council area per year (72 rows), summing to the 235,417 total.

The Land Registry adds late-registered sales to earlier yearly files, so files downloaded at a later date may give slightly different counts. The figures above come from files downloaded on 30 October 2026.

## Phase 2: Excel analysis (in progress)

[`ne_housing.xlsx`](ne_housing.xlsx) holds the 235,417 North East sales as an Excel Table named `Sales`, with:

- readable labels for property type and new build status, added with `VLOOKUP` against two small tables on the `Lookups` sheet
- a `within_budget` column: 1 if the price is at or below the first-time-buyer budget on the `Inputs` sheet (currently £130,000), otherwise 0
- three pivot tables by council area and year: number of sales, average price, and share of sales within budget (with a property type filter)

### Checks

- The sales-count pivot totals 235,417 and matches [`output/counts_by_district_year.csv`](output/counts_by_district_year.csv) cell by cell.
- 82,999 sales (35.3%) are at or below £130,000 in both Excel and DuckDB.

## Reproducing

Requires [DuckDB](https://duckdb.org) and `curl`.

```sh
mkdir -p data/raw output
for y in 2020 2021 2022 2023 2024 2025; do
  curl -L -o data/raw/pp-$y.csv \
    "http://prod2.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-$y.csv"
done

duckdb housing.duckdb < sql/01_load_sales.sql
duckdb housing.duckdb < sql/02_north_east.sql

duckdb housing.duckdb -c "COPY ne_sales TO 'output/ne_sales.csv' (HEADER);"
duckdb housing.duckdb -c "COPY (SELECT district, sale_year, count(*) AS sales FROM ne_sales
  GROUP BY district, sale_year ORDER BY district, sale_year)
  TO 'output/counts_by_district_year.csv' (HEADER);"
```

| File | Purpose |
|---|---|
| `sql/01_load_sales.sql` | Loads the six yearly files into a `sales` table with named columns |
| `sql/02_north_east.sql` | Builds `ne_sales`: North East standard sales of homes at £20,000 or more |
| `output/counts_by_district_year.csv` | Sales per council area per year, used as a completeness check |
| `ne_housing.xlsx` | Phase 2 workbook: lookups, budget flag and pivot tables |

## Licence

Contains HM Land Registry data © Crown copyright and database right 2026. This data is licensed under the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
