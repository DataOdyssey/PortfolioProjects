select * from CovidDeaths
order by 3,4

select * from CovidVaccinations
order by 3,4

-- Select Data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, [Death Percentage] = (total_cases/total_deaths)*100
from CovidDeaths
order by 1, 2

-- Looking at Death Percentage of United States

select location, date, total_cases, total_deaths, [Death Percentage] = (total_cases/total_deaths)*100
from CovidDeaths
where location like '%states%'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, total_cases, population, [Percent Populaion Infected] = (total_cases/population)*100
from CovidDeaths
where location like '%states%'
order by 1, 2

-- Looking at countries with highest infection rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, [Percent Populaion Infected] = max((total_cases/total_deaths)*100)
from CovidDeaths
Group by Location, population
order by [Percent Populaion Infected] desc

-- Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by Location, population
order by TotalDeathCount desc

-- Breaking things down by Continent
--Showing the continents with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- Global Numbers

select date, [Total cases] = sum(new_cases), [Total deaths] = sum(cast(new_deaths as int)), [Death Percentage] = sum(cast(new_deaths as int)) / sum(new_cases) * 100
from CovidDeaths
where continent is not null
group by date
order by 1, 2

select /*date,*/ [Total cases] = sum(new_cases), [Total deaths] = sum(cast(new_deaths as int)), [Death Percentage] = sum(cast(new_deaths as int)) / sum(new_cases) * 100
from CovidDeaths
where continent is not null
--group by date
order by 1, 2


--Looking at Total Population vs Vaccinations
-- with CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, [Rolling People Vaccinated])
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
[Rolling People Vaccinated] = sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, [Vaccination Rate] = ([Rolling People Vaccinated] / Population) * 100
from PopvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated1 numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
RollingPeopleVaccinated = sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated1 / Population) * 100
from #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
RollingPeopleVaccinated = sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated

































