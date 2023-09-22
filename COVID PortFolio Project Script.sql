Select *
From PortfolioProject.dbo.CovidDeaths$
where continent is not Null
order by 3,4

--Select data that we are going to use

Select location, date, total_cases,new_cases, total_deaths, population 
From PortfolioProject.dbo.CovidDeaths$
order by 1,2

--Looking At Total Cases Vs Total Deaths
--Shows Likelihoood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
where location like '%stan%'
order by 1,2


--Loooking at Total Cases vs population

Select location,date,population, total_cases,(total_cases/population)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--where location like '%stan%'
--where location like '%ia%'
order by 1,2


--Looking at countries with Highest Infection rate compared to Population


Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--where location like '%ia%'
Group by location,population
order by PercentPopulationInfected desc

--Showing continents with highest death count per population
--LET'S DO THIS BY CONTINENT
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount

From PortfolioProject.dbo.CovidDeaths$
--where location like '%ia%'
where continent is  Null
Group by location
order by TotalDeathCount desc

--Showing Countries with Highest Death Count Per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount

From PortfolioProject.dbo.CovidDeaths$
--where location like '%ia%'
where continent is not Null
Group by location,population
order by TotalDeathCount desc





--GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--where location like '%stan%'
where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int) )OVER (Partition By dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date =  vac.date
where dea.continent is not null
order by 2,3


--USE CTE


With PopVsVac(Continent , Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int) )OVER (Partition By dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date =  vac.date
where dea.continent is not null
--order by 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100
From PopVsVac





--TEMP TABLE


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int) )OVER (Partition By dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date =  vac.date
where dea.continent is not null
--order by 2,3

Select * ,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int) )OVER (Partition By dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date =  vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

