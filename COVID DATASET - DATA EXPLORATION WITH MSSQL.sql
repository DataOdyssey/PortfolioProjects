-- WORKING WITH COVIDDEATHS TABLE

select * from CovidDeaths
order by 3, 4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'India' and continent is not null
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like 'India' and continent is not null
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population

select location, date, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
where location like 'India' and continent is not null
group by location, date, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the continents with highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2

-- WORKING WITH COVIDVACCINATIONS TABLE

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location)
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
						   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USING CTE


with PopvsVac (continent, location, date, population,new_vaccinations, Rollingpeoplevaccinated)
as
(
select top 244010 dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
						   and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select *, (Rollingpeoplevaccinated/population) * 100 from PopvsVac


-- USING TEMP TABLES

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
						   and dea.date = vac.date
order by 2,3

select *, (Rollingpeoplevaccinated/population) * 100 from #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations


Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac on dea.location = vac.location
						   and dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated



