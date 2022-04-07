Select * 
from portfolioProject..deaths
order by 3,4

--Select * 
--from portfolioProject..vaccination
--order by 3,4

--Seelct the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..deaths
order by 1,2

--Looking at the total cases vs total deaths 
--Shows the likelihood of dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject..deaths
where location like '%states%'
order by 1,2

--Looking at the total_cases vs Population
--Shows what percentage of population get covid

Select Location, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from portfolioProject..deaths
where location like '%states%'
order by 1,2

--Looking at the country with the highest infection rate compared to population

Select Location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as HighestInfectionPercentage
from portfolioProject..deaths
--where location like '%states%'
group by location, population 
order by HighestInfectionPercentage desc

--Showing the countries with Highest death count per population

Select Location, MAX(CAST(total_deaths as int)) as totalDeathCount
from portfolioProject..deaths
where continent is not null
group by location
order by totalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENTS
--Showing continents with the highest death count per population

Select location, MAX(CAST(total_deaths as int)) as totalDeathCount
from portfolioProject..deaths
where continent is null
group by location
order by totalDeathCount desc

--Global numbers

Select date, SUM(new_cases), SUM(CAST((new_deaths as int)) as total_deaths, SUM(CAST((new_deaths as int))/ SUM(new_cases) * 100 as DaethPercentage
from portfolioProject..deaths
where continent is not null
group by date 
order by 1,2

Select  SUM(new_cases), SUM(CAST((new_deaths as int)) as total_deaths, SUM(CAST((new_deaths as int))/ SUM(new_cases) * 100 as DaethPercentage
from portfolioProject..deaths
where continent is not null
--group by date 
order by 1,2


--Looking at total population vs vaccinaton

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject..deaths dea
Join portfolioProject..vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3


