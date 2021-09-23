/*

Queries for Tableau Project

*/

show databases;
use PortfolioProject;


-- 1.

-- Looking at the Worldwide death percentage of covid 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) AS death_percentage
FROM PortfolioProject.CovidDeaths cd 
WHERE continent != ''
ORDER BY 1,2

-- Double checking based on data provided under location 'World'
-- Numbers are very close, so we'll keep them

-- SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) as  death_percentage
-- FROM PortfolioProject.CovidDeaths cd 
-- WHERE location LIKE 'World'
-- ORDER BY 1,2


-- 2.

-- Looking at the total death count per country, organized in descending order
SELECT location, SUM(new_deaths) AS total_death_count
FROM PortfolioProject.CovidDeaths cd 
WHERE continent = ''
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location, continent 
ORDER BY total_death_count DESC


-- 3.

-- Looking at each Country's Infection Rate compared to Population
-- As of recent date, in descending order
SELECT location, population, MAX(total_cases) AS highest_infection_count
, COALESCE(MAX(total_cases/population), 0 ) AS percent_population_infected
FROM PortfolioProject.CovidDeaths cd 
WHERE continent != '' 
GROUP BY location, population 
ORDER BY percent_population_infected DESC


-- 4. 

-- Looking at each Country's Infection Rate compared to Population
-- Across each day, in descending order
SELECT location, population, `date`, MAX(total_cases) AS highest_infection_count
, COALESCE(MAX(total_cases/population), 0) AS percent_population_infected
FROM PortfolioProject.CovidDeaths cd 
WHERE continent != '' 
GROUP BY location, population, `date` 
ORDER BY percent_population_infected DESC -- , highest_infection_count, `date` 











-- Queries I would like to add into Tableau at a later time


-- 1.

-- Percentage of Population Vaccinated as of recent date
SELECT cd.continent, cd.location, cd.population, MAX(cv.people_vaccinated) as people_vaccinated
, COALESCE(MAX(cv.people_vaccinated/cd.population), 0) AS vaccination_percentage
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent != ''
-- AND cd.location LIKE 'Northern%'
GROUP BY cd.continent, cd.location, cd.population



-- 2.

-- Percentage of Population Vaccinated by country for each day
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.people_vaccinated as people_vaccinated
, MAX(cv.people_vaccinated/cd.population) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.`date`) AS vaccination_percentage
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent != ''

SELECT * FROM PortfolioProject.CovidDeaths cv WHERE location LIKE 'Burundi'


