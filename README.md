# COVID-19 Global Data Exploration (SQL)

A SQL-based exploratory data analysis project on global COVID-19 case, death, and vaccination data. This project demonstrates core SQL skills used in real-world data analysis: joins, CTEs, temp tables, window functions, aggregate functions, views, and data type conversions.

## 📊 Project Overview

Using publicly available COVID-19 datasets (`CovidDeaths` and `CovidVaccinations`), this project explores:

- Total cases vs. total deaths (death likelihood by country)
- Total cases vs. population (infection rate)
- Countries and continents with the highest infection and death counts
- Global daily case/death trends
- Rolling vaccination totals vs. population
- Global summary statistics and vaccination breakdown by continent

## 🛠️ Skills Demonstrated

- `JOIN`s across multiple tables
- Common Table Expressions (CTEs)
- Temporary tables
- Window functions (`SUM() OVER (PARTITION BY ... ORDER BY ...)`)
- Aggregate functions (`SUM`, `MAX`)
- `CREATE VIEW` for reusable queries (e.g., for BI tool visualizations)
- Data type conversion (`CAST`, `CONVERT`)
- Handling `NULL`s safely with `NULLIF` / `ISNULL`

## 🗃️ Dataset

The queries reference two tables inside a database named `PortfolioProject`:

- **CovidDeaths** — location, date, population, case counts, death counts
- **CovidVaccinations** — location, date, vaccination counts


## 📈 Next Steps

- Build a Tableau/Power BI dashboard on top of the created view
- Extend analysis to include testing rates and hospitalization data

## 👤 Author
    RAQIQA ZAFAR
