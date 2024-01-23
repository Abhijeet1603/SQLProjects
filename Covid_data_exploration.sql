SELECT * FROM Portfolio_Project.dbo.covid_deaths
where continent is not null
order by 3,4;

SELECT * FROM Portfolio_Project.dbo.covid_vaccination
order by 3,4;

--Selecting the data that we are going to use
SELECT Location, date, total_cases, new_cases, total_deaths, population  
FROM Portfolio_Project.dbo.covid_deaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--Show the likelyhood of dying with covid positive
SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as decimal(12,0))/total_cases)*100 as death_percentage
FROM Portfolio_Project.dbo.covid_deaths
WHERE Location like '%Asia%' 
order by 1,2

-- looking at totalcases vs population
-- show what percentage of people got covid
SELECT Location, date, total_cases, population, (Cast(total_cases as decimal(12,0)) / population) * 100 as postive_cases_percentage
FROM Portfolio_Project.dbo.covid_deaths
WHERE Location like '%Asia%'
order by 1,2


-- looking at countries with highest infection rate compared to population
SELECT Location, MAX(total_cases) as Highest_infection_count, population, MAX((Cast(total_cases as decimal(12,0))) / population) * 100 as percent_POPULATION_INFECTED
FROM Portfolio_Project.dbo.covid_deaths
--WHERE Location like '%Asia%'
GROUP BY Location, Population
order by percent_POPULATION_INFECTED DESC


-- looking countries with the higest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as Total_deaths_count
FROM Portfolio_Project.dbo.covid_deaths
--WHERE Location like '%Asia%'
where continent is not null
GROUP BY Location
order by Total_deaths_count DESC

--Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as Total_deaths_count
FROM Portfolio_Project.dbo.covid_deaths
--WHERE Location like '%Asia%'
where continent is  not null
GROUP BY continent
order by Total_deaths_count DESC

--Showing the continents with higest death counts

SELECT continent, MAX(cast(total_deaths as int)) as Total_deaths_count
FROM Portfolio_Project.dbo.covid_deaths
--WHERE Location like '%Asia%'
where continent is  not null
GROUP BY continent
order by Total_deaths_count DESC

--showing the continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as Total_deaths_count
FROM Portfolio_Project.dbo.covid_deaths
--WHERE Location like '%Asia%'
where continent is  not null
GROUP BY continent
order by Total_deaths_count DESC

-- global numbers
SET ARITHABORT OFF   
SET ANSI_WARNINGS OFF 

SELECT   SUM(New_cases) as total_cases, SUM(New_deaths) as total_deaths, SUM(CAST(New_deaths as decimal(12,0)))/SUM(New_cases) *100 as death_percentage
FROM Portfolio_Project.dbo.covid_deaths
--WHERE Location like '%Asia%' 
where continent is NOT null
--GROUP BY date
order by 1,2

-- Joining covid vaccination and covid deaths tables
-- looking at total population vs vaccination
-- Using cte

WITH popvsvac (continent, location, date, population, new_vaccinations,rolling_people_vaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, CAST(cv.new_vaccinations as bigint), SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as rolling_people_vaccinated
FROM Portfolio_Project.dbo.covid_deaths AS cd
JOIN Portfolio_Project.dbo.covid_vaccination AS cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null

)

SELECT *, (Convert(float,rolling_people_vaccinated)/population) as percentage_popvsvacc
FROM popvsvac

-- temp table

DROP TABLE IF EXISTS Portfolio_Project.dbo.PercentPopulationVaccinated
GO
CREATE TABLE Portfolio_Project.dbo.PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinate numeric
)
INSERT INTO Portfolio_Project.dbo.PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, CAST(cv.new_vaccinations as bigint), 
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location , cd.date) 
as rolling_people_vaccinated
FROM Portfolio_Project.dbo.covid_deaths AS cd
JOIN Portfolio_Project.dbo.covid_vaccination AS cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null

SELECT *, (Convert(float,rolling_people_vaccinated)/population) as percentage_popvsvacc
FROM PercentPopulationVaccinated

-- Creating View  to store data for later visualization 
 
 USE model;
GO
CREATE VIEW h AS 

SELECT cd.continent, cd.location, cd.date, cd.population, CAST(cv.new_vaccinations as bigint) AS new_vaccinations, 
SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location , cd.date) 
as rolling_people_vaccinated
FROM Portfolio_Project.dbo.covid_deaths AS cd
JOIN Portfolio_Project.dbo.covid_vaccination AS cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null;
GO
