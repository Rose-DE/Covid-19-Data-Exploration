--Select *
--From [Portfolio project]..CovidVaccinations$ 
--order by 3,4

--Select *
--from [Portfolio project]..CovidDeaths
--order by 3,4

--select Data that we will be using

Select location, date,total_cases, new_cases, total_deaths, population 
From [Portfolio project]..CovidDeaths 
Where continent is not null
order by 1,2

--looking at Total Cases vs Total Deaths
--shows the likelihood of dying (at time of analysis) if you contract Covid in Africa

Select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths 
Where location = 'Kenya'
and continent is not null
order by 1,2

--looking at the Total Cases vs Population
--shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths 
Where location = 'Kenya'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases), Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths 
--Where location = 'Kenya'
Where continent is not null
Group by location,population 
order by PercentPopulationInfected desc


--Showing countries wit Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths 
--Where location = 'Kenya'
Where continent is not null
Group by location 
order by TotalDeathCount desc

--Showing by continent highest Death Count per Population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths 
--Where location = 'Kenya'
Where continent is not null
Group by continent 
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From [Portfolio project]..CovidDeaths 
--Where location = 'Kenya'
Where continent is not null
Group by date
order by 1,2


--looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio project]..CovidDeaths as dea
Join [Portfolio project]..CovidVaccinations$ as vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--vaccination by rolling count

With PopvsVac (continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeaths as dea
Join [Portfolio project]..CovidVaccinations$ as vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeaths as dea
Join [Portfolio project]..CovidVaccinations$ as vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

--creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeaths as dea
Join [Portfolio project]..CovidVaccinations$ as vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3