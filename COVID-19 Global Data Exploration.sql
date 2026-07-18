/*
COVID-19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- 1. Select data we are going to start with
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- 2. Select starting columns
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- 3. Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

-- 4. Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases,  
(CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0)) * 100 AS PercentPopulationAffected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- 5. Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, 
MAX((CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- 6. Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- 7. Breaking things down by Continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 8. Global Numbers per Date
SELECT date, 
SUM(CAST(new_cases AS int)) AS total_cases, 
SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- 9. Total Population vs Vaccinations (using CTE)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint, ISNULL(v.new_vaccinations, 0))) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
    ON d.location = v.location
    and d.date = v.date
WHERE d.continent is not null
)
SELECT *, (CAST(RollingPeopleVaccinated AS float) / NULLIF(CAST(Population AS float), 0)) * 100 AS PercentPeopleVaccinated
FROM PopvsVac;

-- 10. Using Temp Table to perform Calculation
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population bigint,
    New_vaccinations bigint,
    RollingPeopleVaccinated bigint
);

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, 
CAST(d.population AS bigint), 
CAST(ISNULL(v.new_vaccinations, 0) AS bigint),
SUM(CONVERT(bigint, ISNULL(v.new_vaccinations, 0))) OVER (Partition by d.Location Order by d.location, d.Date)
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
    ON d.location = v.location
    and d.date = v.date;

SELECT *, (CAST(RollingPeopleVaccinated AS float) / NULLIF(CAST(Population AS float), 0)) * 100 AS PercentPeopleVaccinated
FROM #PercentPopulationVaccinated;

-- 12. Global Total Cases, Deaths, and Death Percentage
SELECT 
    SUM(CAST(new_cases AS bigint)) AS Total_Cases, 
    SUM(CAST(new_deaths AS bigint)) AS Total_Deaths,
    (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- 13. Total Vaccinations by Continent
SELECT 
    continent, 
    SUM(CAST(new_vaccinations AS bigint)) AS TotalVaccinations
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalVaccinations DESC;

-- 13. Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT d.continent, d.location, d.date, 
CAST(d.population AS bigint) AS Population, 
CAST(ISNULL(v.new_vaccinations, 0) AS bigint) AS New_Vaccinations,
SUM(CONVERT(bigint, ISNULL(v.new_vaccinations, 0))) OVER (Partition by d.Location Order by d.location, d.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
    ON d.location = v.location
    and d.date = v.date
WHERE d.continent is not null;