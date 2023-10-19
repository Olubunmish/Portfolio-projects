select*  
from CovidDeaths$
where continent is not null

--Looking @ total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
---where location like '%states%'
order by 1,2

-- Total cases vs poppulation
select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from CovidDeaths$
---where location like '%states%'
order by 1,2

---Countries with the highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths$
---where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

--Countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
--cast let's you convert varchar to int for maths purpose
from CovidDeaths$
---where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--Break by continent with the highest death count by population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
--cast let's you convert varchar to int for maths purpose
from CovidDeaths$
---where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



---- Breaking down to global numbers

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
---where location like '%states%'
Group by date
order by 1,2

--Total Cases vs Total Deaths

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
---where location like '%states%'
--Group by date
order by 1,2


select *
from [dbo].[CovidVaccinations$]



---Joins the tables

select *
from [dbo].[CovidDeaths$] Dea
join [dbo].[CovidVaccinations$] Vac
on Dea.location = vac.location
and Dea.date = vac. date

---Looking @ toral population vs Vaccinations

select Dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
from [dbo].[CovidDeaths$] Dea
join [dbo].[CovidVaccinations$] Vac
on Dea.location = vac.location
and Dea.date = vac. date
where dea.continent is not null
order by 1,2,3

-- to break down by location and date by cumulative
select Dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths$] Dea
join [dbo].[CovidVaccinations$] Vac
on Dea.location = vac.location
and Dea.date = vac. date
where dea.continent is not null
order by 1,2,3

---Use CTE 

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths$] Dea
join [dbo].[CovidVaccinations$] Vac
on Dea.location = vac.location
and Dea.date = vac. date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


---Temp Table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select Dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths$] Dea
join [dbo].[CovidVaccinations$] Vac
on Dea.location = vac.location
and Dea.date = vac. date
where dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100

select *
from #PercentPopulationVaccinated


Create view PercentPopulationVaccinated as 
select Dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths$] Dea
join [dbo].[CovidVaccinations$] Vac
on Dea.location = vac.location
and Dea.date = vac. date
where dea.continent is not null

select *
from PercentPopulationVaccinated