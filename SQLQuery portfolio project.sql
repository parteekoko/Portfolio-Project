Select *
From [Portfolio Project]..CovidDeaths
Order by 1,2

Select *
From [Portfolio Project]..CovidVaccinations
order by 1,2


--select data I am starting with


 Select location,date,total_cases, new_cases, total_deaths, population
 From [Portfolio Project]..CovidDeaths
 Order by 1,2

 --looking at total cases vs total deaths
 --shows likelihood of dying if you contract covid in your country 

 
Select location, date, total_cases, total_deaths, (Convert(float,total_deaths)/Nullif(Convert(float,total_cases),0))*100 AS DeathPercentage
 From [Portfolio Project]..CovidDeaths
 --Where location like '%Netherlands%'
 Order by 1,2

 --looking at total cases vs population
 --shows what percenta of population got covid

 Select location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS InfectedPopulationPercentage
 From [Portfolio Project]..CovidDeaths
 --Where location like '%Netherlands%'
 Order by 1,2





 --countries with hoghest population rate cpmpared with population


 --query to use if your data type is varchar
 Select location, population, MAX(total_cases) As HighestInfectedCount, MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS InfectedPopulationPercentage
 From [Portfolio Project]..CovidDeaths
 --Where location like '%Netherlands%'
  where continent is not null
 Group By location, population
 Order by InfectedPopulationPercentage desc

 --query to use when your data type is float
 Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

 

 --countries with the highest death count per population

 Select location,  MAX(cast(total_cases as int)) As Totaldeathcount
 From [Portfolio Project]..CovidDeaths
 --Where location like '%Netherlands%'
  where continent is not null
 Group By location
 Order by Totaldeathcount desc

 --breaking things down by continent

 --showing continent with highest death count per population


  Select continent,  MAX(cast(total_cases as int)) As Totaldeathcount
 From [Portfolio Project]..CovidDeaths
 --Where location like '%Netherlands%'
  where continent is not null
 Group By continent
 Order by Totaldeathcount desc


 --global numbers


 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



 Select date, Sum(cast(new_cases as int)), SUM(Cast(new_deaths as int))--, total_deaths, (Convert(float,total_deaths)/Nullif(Convert(float,total_cases))*100 AS DeathPercentage
 From [Portfolio Project]..CovidDeaths
 --Where location like '%Netherlands%'
 where continent is not null
 Group by date
 Order by 1,2


 

 -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As Rollingpeoplevaccinated
 --,(Rollingpeoplevaccinated/population)*100
 From [Portfolio Project]..CovidDeaths dea
 Join [Portfolio Project]..CovidVaccinations vac
    On dea.location= vac.location
    and dea.date=vac.date
where dea.continent is not null
Order by 2,3 


-- Using CTE to perform Calculation on Partition By in previous query



--TEMP TABLE

drop Table #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--creating view to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select*
From PercentPopulationVaccinated
