Select *
From PortfolioProject.dbo.COVID_DEATHS
Where continent is not null
Order by 3,4
--Select *
--From PortfolioProject.dbo.COVID_VACC
--order by 3,4

-- Select Data that I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject.dbo.COVID_DEATHS
Where continent is not null
order by 1,2


-- Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.COVID_DEATHS
Where location like '%united kingdom%'
and continent is not null
order by 1,2

-- Looking at total cases vs populaiton 
-- This shows what percentage of population got COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as PopCovid
From PortfolioProject.dbo.COVID_DEATHS
-- Where location like '%united kingdom%'
Where continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to its population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From PortfolioProject.dbo.COVID_DEATHS
-- Where location like '%united kingdom%'
Group by Location, population
order by PercentPopInfected desc

-- Showing countries with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.COVID_DEATHS
-- Where location like '%united kingdom%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Breaking things down by continent 

-- Showing continents with higest death count


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.COVID_DEATHS
-- Where location like '%united kingdom%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject.dbo.COVID_DEATHS
--Where Location like '%United Kingdom%'
Where continent is not null
--Group by date
order by 1, 2


-- Joining tables deaths and vaccinations, also creating a new shortened name dea & vac. Joined by date & location.
-- Tables designed to look at total population vs vaccination (total people in world vaccinated per day). 

-- using CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingCountVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
--, (RollingCountVaccinated/population)*100
From PortfolioProject..COVID_DEATHS Dea
Join PortfolioProject..COVID_VACC Vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingCountVaccinated/population)*100
From PopVsVac

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
--, (RollingCountVaccinated/population)*100
From PortfolioProject..COVID_DEATHS Dea
Join PortfolioProject..COVID_VACC Vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3


Select *, (RollingCountVaccinated/population)*100
From #PercentPopulationVaccinated

-- CREATING VIEWS
-- Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
--, (RollingCountVaccinated/population)*100
From PortfolioProject..COVID_DEATHS Dea
Join PortfolioProject..COVID_VACC Vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From  PercentPopulationVaccinated
