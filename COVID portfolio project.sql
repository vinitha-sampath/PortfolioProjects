Select *
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 3,4

Select *
FROM PortfolioProject.dbo.CovidVaccinations
Where continent is not null
ORDER BY 3,4

Select location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

Select location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states'
ORDER BY 1,2


-- Countries with Highest Infection rate based on population

Select location,population,MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 as PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states'
Group by location, population
ORDER BY PercentagePopulationInfected desc


-- Countries with Highest death rate compared to population

Select location,MAX(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
ORDER BY DeathCount desc


--Based on continet with highest death rate

Select continent,max(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
group by continent
ORDER BY DeathCount desc


-- Global Numbers

SELECT 
    SUM(new_cases) AS total_new_cases,
    SUM(CAST(new_deaths AS int)) AS total_new_deaths,
    SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM  PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states'
--WHERE continent IS NOT NULL
--GROUP BY  date
ORDER BY 1,2


-- looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- using CTE


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
select *, (RollingPeopleVaccination/ population)*100 as PeopleVaccinated
from PopvsVac
order by 2,3



--using TEMP Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccination numeric)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

select *, (RollingPeopleVaccination/ population)*100 as PeopleVaccinated
from #PercentPopulationVaccinated
order by 2,3


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL


select *
from PercentPopulationVaccinated