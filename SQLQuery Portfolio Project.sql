Select *
From CovidDeaths
Where continent is NOT NULL
ORDER BY 3,4


Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is NOT NULL
ORDER BY 1,2



-- Extracting a view for the death percentage rate in Egypt

Create View DeathPercentageEgypt as
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentageEgypt
From CovidDeaths
WHERE location = 'Egypt'
AND continent is NOT NULL


-- Extracting a view for the infection percentage rate in Egypt

Create View InfectionPercentage as
Select Location, Date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
From CovidDeaths
WHERE location = 'Egypt'
AND continent is NOT NULL


-- Extracting a view for the highest infection percentage rate by country

Create View HighestInfectionPercentage as
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS HighestInfectionPercentage
From CovidDeaths
Where continent is NOT NULL
GROUP BY Location, population



-- Extracting a view for the highest deaths counts by country & continent

Create View HighestDeathsPerCountry as
Select Location, MAX(cast(total_deaths as int)) AS HighestDeathsCount
From CovidDeaths
Where continent is NOT NULL
GROUP BY Location


Create View HighestDeathsCount as
Select continent, MAX(cast(total_deaths as int)) AS HighestDeathsCount
From CovidDeaths
Where continent is NOT NULL
GROUP BY continent



-- Extracting a view for the deaths percentage by day

Create View DeathPercentage as
Select Date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From CovidDeaths
WHERE continent is NOT NULL
GROUP BY date


-- Extracting a view for the new vaccinations by day

Create View NewVaccinations as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = vac.location
AND Dea.date = vac.date
WHERE Dea.continent is NOT NULL


-- Extracting a view for the additions of vaccinations by each country daily

Create View RollingPeopleVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int))
OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = vac.location
AND Dea.date = vac.date
WHERE Dea.continent is NOT NULL


DROP TABLE IF EXISTS #PercentPopulationVaccinations
CREATE TABLE #PercentPopulationVaccinations
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinations
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int))
OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = vac.location
AND Dea.date = vac.date
WHERE Dea.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinations
From #PercentPopulationVaccinations


Create View PercentPopulationVaccinations as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int))
OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location = vac.location
AND Dea.date = vac.date
WHERE Dea.continent is NOT NULL