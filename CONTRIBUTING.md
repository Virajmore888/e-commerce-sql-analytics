# Contributing

This is a personal portfolio project built for learning and demonstration purposes, so it isn't actively seeking external contributions. That said, feedback and suggestions are welcome.

## Reporting Issues

If you spot a bug, inconsistency in a query, or an error in the analysis, feel free to open an issue describing:
- What you found
- Which file it's in (e.g., `sql/04_advanced_queries.sql`)
- Expected vs. actual behavior

## Suggesting Improvements

Ideas for additional queries, better visualizations, or schema improvements are welcome via issues or pull requests.

## Setup for Local Testing

1. Clone the repo
2. Run the scripts in `sql/` in order: `01_schema.sql` → `02_data_insert.sql` → `03_basic_queries.sql` → `04_advanced_queries.sql`
3. Install Python dependencies: `pip install -r requirements.txt`
4. Set up a `.env` file with your MySQL credentials (not included, excluded via `.gitignore`)
5. Run `python/ecommerce_analysis.py` to regenerate the charts

## Code Style

- SQL: uppercase keywords, one clause per line for readability
- Python: follow PEP 8 conventions

Thanks for taking a look at the project!
