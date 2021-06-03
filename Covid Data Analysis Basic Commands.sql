SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases Vs. Total Deaths
--Chance of dying if you get COVID in a country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
AND location like '%india%'
Order by 1,2

--Total Cases Vs. Population
Select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
Order by 1,2

--Highest Infection Rate/Population
Select location,  population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulation
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Group By location, population
Order by 4 DESC

--By continents
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%india%'
--Order by 1,2
Group by continent
Order by 2 DESC


--Highest Deaths
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%india%'
--Order by 1,2
Group by location
Order by 2 DESC


--Global Numbers-- WHy error??
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%india%'
Group by date
Order by 1,2

--Total Pop Vs. Vacc CET
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVac)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 )
Select *, (RollingPeopleVac/population)*100 as PercentageVaccinations
From PopVsVac

--Total Pop Vs. Vacc CET

DROP table If exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVac numeric
)
Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 Select *, (RollingPeopleVac/population)*100 as PercentageVaccinations
From #PercentPopVaccinated

--View to Store Data

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 Select*
 From PercentPopVaccinated