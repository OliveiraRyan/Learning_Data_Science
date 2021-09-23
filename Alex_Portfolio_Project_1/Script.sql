show databases;
use PortfolioProject;

SELECT  *
FROM PortfolioProject.CovidDeaths cd
ORDER BY 3,4;

SELECT  *
FROM PortfolioProject.CovidVaccinations cv 
ORDER BY 3,4;

SELECT location, `date`, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.CovidDeaths cd
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if one contracted covid in Canada
SELECT location, `date`, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases) as death_rate
FROM PortfolioProject.CovidDeaths cd
WHERE location LIKE 'Canada'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows the percentage of population that contracted covid
SELECT location, `date`, population, total_cases, (total_cases/population) as population_infection_rate
FROM PortfolioProject.CovidDeaths cd
-- WHERE location LIKE 'Canada'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population) as population_infection_rate
FROM PortfolioProject.CovidDeaths cd
-- WHERE location LIKE 'Canada'
GROUP BY location, population
ORDER BY population_infection_rate desc


-- Filter out rows where location is a continent/world
SELECT  *
FROM PortfolioProject.CovidDeaths cd
WHERE continent != ''
ORDER BY 3,4;


-- Showing countries with Highest Death Count
SELECT location, MAX(total_deaths) as total_death_count
FROM PortfolioProject.CovidDeaths cd
-- WHERE location LIKE 'Canada'
WHERE continent != ''
GROUP BY location
ORDER BY total_death_count desc



-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Continents for drill-down effect:
-- North America, South America, Asia, Europe, Africa, Oceania

-- Showing continents with the highest death count
SELECT location, MAX(total_deaths) as total_death_count
FROM PortfolioProject.CovidDeaths cd
-- WHERE location LIKE 'Canada'
WHERE continent = ''
GROUP BY location
ORDER BY total_death_count desc


-- -- Continents only (improper math) for drill-down effect
-- SELECT continent , MAX(total_deaths) as total_death_count
-- FROM PortfolioProject.CovidDeaths cd
-- WHERE continent != ''
-- GROUP BY continent 
-- ORDER BY total_death_count desc




-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) as death_precentage-- total_cases, new_cases, total_deaths, population, (total_deaths/total_cases) as death_rate
FROM PortfolioProject.CovidDeaths cd
WHERE continent != ''
-- GROUP BY `date`
ORDER BY 1,2



-- Covid vaccinations join with deaths

-- Looking at Total Population vs Vaccinations (BAD STATS since people can take multiple doses)
-- With CTE
With PopvsVac (Continent, Location, `Date`, Population, New_Vaccinations, Rolling_Vaccinations, People_Vaccinated)
as (
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.`date`) as rolling_vaccinations,
cv.people_vaccinated
FROM PortfolioProject.CovidDeaths cd
JOIN PortfolioProject.CovidVaccinations cv 
	ON cd.location = cv.location
	and cd.`date` = cv.`date`
WHERE cd.continent != ''
-- ORDER BY 2,3
)
SELECT *, (Rolling_Vaccinations/Population) as Vaccination_Percentage, (People_Vaccinated/Population) as REAL_Vaccination_Percentage
FROM PopvsVac
ORDER BY 2,3

-- The correct way (less fancy)
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.people_vaccinated, (cv.people_vaccinated/cd.population) AS vaccination_percentage
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent != ''
-- AND cd.location LIKE 'Seychelles'

-- Accounting for people_vaccinated being 0 if there is no change
SELECT cd.continent, cd.location, cd.`date`, cd.population, NULLIF(cv.people_vaccinated, 0) as people_vaccinated
, MAX(cv.people_vaccinated/cd.population) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.`date`) AS vaccination_percentage
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent != ''
-- AND cd.location LIKE 'Seychelles'


SELECT location, `date`, new_vaccinations, total_vaccinations 
FROM PortfolioProject.CovidVaccinations cv 
WHERE continent != ''





-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.`date`, cd.population, NULLIF(cv.people_vaccinated, 0) as people_vaccinated
, MAX(cv.people_vaccinated/cd.population) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.`date`) AS vaccination_percentage
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent != ''

SELECT *
FROM PercentPopulationVaccinated ppv 
