/*

Queries for Tableau Project

*/

/*
 ---------------------------------------------
DATA CLEANING
 ---------------------------------------------
 */

show databases;
use PortfolioProject;

-- Update Population of Northern Cyprus to 326000
UPDATE PortfolioProject.CovidDeaths
SET population = 326000
WHERE location = 'Northern Cyprus'

/*
 ---------------------------------------------
 DASHBOARD 1 - Covid Deaths && Infection %
 ---------------------------------------------
 */

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

-- Looking at the total death count per continent, organized in descending order
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
-- Across each day, in descending order (of percent_population_infected)
SELECT location, population, `date`, MAX(total_cases) AS highest_infection_count
, COALESCE(MAX(total_cases/population), 0) AS percent_population_infected
FROM PortfolioProject.CovidDeaths cd 
WHERE continent != '' 
GROUP BY location, population, `date` 
ORDER BY percent_population_infected DESC -- , highest_infection_count, `date` 







/*
 ---------------------------------------------
 DASHBOARD 2 - Covid Vaccs && Vaccination %
 ---------------------------------------------
 */


SELECT *
FROM CovidDeaths cd
-- WHERE cd.location LIKE '%world%'
WHERE location = 'Northern Cyprus'

SELECT *
FROM CovidVaccinations cv 
-- WHERE cd.location LIKE '%world%'
WHERE location = 'Asia'


-- 5.

-- Looking at Worldwide vaccination percentages for partial and complete vaccinations
SELECT SUM(population) as total_population
, SUM(people_vaccinated) as total_people_vaccinated
, SUM(people_fully_vaccinated) as total_people_fully_vaccinated
, SUM(people_vaccinated) / SUM(population) as percentage_population_vaccinated
, SUM(people_fully_vaccinated) / SUM(population) as percentage_population_fully_vaccinated
FROM (SELECT cd.location, MAX(cd.population) as population
	, MAX(cv.people_vaccinated) as people_vaccinated
	, MAX(cv.people_fully_vaccinated) as people_fully_vaccinated
	FROM PortfolioProject.CovidDeaths cd 
	JOIN PortfolioProject.CovidVaccinations cv
		ON cd.location = cv.location 
		AND cd.`date` = cv.`date` 
	WHERE cd.continent != ''
	GROUP BY cd.location
) VaccinationsByLocation



-- Reshaping the table into 2 rows
-- Used a messy UNION ALL since I couldn't get CROSS APPLY to work for MySQL 
SELECT SUM(population) as total_population
, SUM(people_vaccinated) as vaccinations
, SUM(people_vaccinated) / SUM(population) as percentage_population_vaccinated
FROM (SELECT cd.location, MAX(cd.population) as population
	, MAX(cv.people_vaccinated) as people_vaccinated
	, MAX(cv.people_fully_vaccinated) as people_fully_vaccinated
	FROM PortfolioProject.CovidDeaths cd 
	JOIN PortfolioProject.CovidVaccinations cv
		ON cd.location = cv.location 
		AND cd.`date` = cv.`date` 
	WHERE cd.continent != ''
	GROUP BY cd.location
) VaccinationsByLocation
UNION ALL
SELECT SUM(population) as total_population
, SUM(people_fully_vaccinated)
, SUM(people_fully_vaccinated) / SUM(population)
FROM (SELECT cd.location, MAX(cd.population) as population
	, MAX(cv.people_vaccinated) as people_vaccinated
	, MAX(cv.people_fully_vaccinated) as people_fully_vaccinated
	FROM PortfolioProject.CovidDeaths cd 
	JOIN PortfolioProject.CovidVaccinations cv
		ON cd.location = cv.location 
		AND cd.`date` = cv.`date` 
	WHERE cd.continent != ''
	GROUP BY cd.location
) VaccinationsByLocation







-- Double checking based on data provided under location 'World'
-- Numbers are very close, so we'll keep them

-- SELECT cd.population, cv.people_vaccinated, cv.people_fully_vaccinated
-- , cv.people_vaccinated / cd.population as percentage_population_vaccinated
-- , cv.people_fully_vaccinated / cd.population as percentage_population_fully_vaccinated
-- FROM PortfolioProject.CovidDeaths cd 
-- JOIN PortfolioProject.CovidVaccinations cv
-- 	ON cd.location = cv.location 
-- 	AND cd.`date` = cv.`date` 
-- WHERE cd.location LIKE '%world%'
-- ORDER BY cd.`date` DESC
-- LIMIT 1


-- 6.

-- Looking at total vaccination count by continent, organized in descending order
SELECT cd.location
, MAX(cv.people_vaccinated) as people_vaccinated
, MAX(cv.people_fully_vaccinated) as people_fully_vaccinated
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent = ''
AND cd.location NOT IN ('World', 'European Union', 'International')
GROUP BY cd.location
ORDER BY people_vaccinated DESC


-- 7.

-- Looking at each Country's Vaccination Rate compared to Population
-- As of recent date, in descending order (of people_vaccinated)
SELECT cd.location, cd.population
, MAX(cv.people_vaccinated) as people_vaccinated
, MAX(cv.people_fully_vaccinated) as people_fully_vaccinated
, CASE 
	WHEN MAX(cv.people_vaccinated) / MAX(cd.population) > 0.99 THEN '>0.99'
	ELSE MAX(cv.people_vaccinated) / MAX(cd.population)
END as percentage_vaccinated
, CASE 
	WHEN MAX(cv.people_fully_vaccinated) / MAX(cd.population) > 0.99 THEN '>0.99'
	ELSE MAX(cv.people_fully_vaccinated) / MAX(cd.population)
END as percentage_fully_vaccinated
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent != ''
GROUP BY cd.location, cd.population 
ORDER BY 
	CASE REGEXP_LIKE(percentage_vaccinated, '^0.[0-9.]+$')
		WHEN 1 THEN percentage_vaccinated
		ELSE 5
	END DESC


-- 8.

-- Looking at each Country's Vaccination Rate compared to Population
-- Across each day, in descending order (of percentage_vaccinated)
SELECT cd.location, cd.population, cd.`date` 
, MAX(cv.people_vaccinated) as people_vaccinated
, MAX(cv.people_fully_vaccinated) as people_fully_vaccinated
, CASE 
	WHEN MAX(cv.people_vaccinated) / MAX(cd.population) > 0.99 THEN '>0.99'
	ELSE MAX(cv.people_vaccinated) / MAX(cd.population)
END as percentage_vaccinated
, CASE 
	WHEN MAX(cv.people_fully_vaccinated) / MAX(cd.population) > 0.99 THEN '>0.99'
	ELSE MAX(cv.people_fully_vaccinated) / MAX(cd.population)
END as percentage_fully_vaccinated
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv
	ON cd.location = cv.location 
	AND cd.`date` = cv.`date` 
WHERE cd.continent != ''
GROUP BY cd.location, cd.population, cd.`date` 
ORDER BY 
	CASE REGEXP_LIKE(percentage_vaccinated, '^0.[0-9.]+$')
		WHEN 1 THEN percentage_vaccinated
		ELSE 5
	END DESC

	
	

	
	
	
	
	
	
	
	
	


-- Additional queries regarding vaccination numbers: 


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


