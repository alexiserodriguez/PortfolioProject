Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Venezuela%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population get Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Venezuela%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, MAX(total_cases) AS HighestInfectionCount, population, Max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Venezuela%'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Venezuela%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking things down by continent
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Venezuela%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Venezuela%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Venezuela%' 
where continent is not null
Group by date
order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated