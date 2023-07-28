Select * 
From PortfolioProject.. CovidDeaths
where continent is not null
order BY 3,4 

--Select * 
--From PortfolioProject.. CovidVaccinations
--where continent is not null
--order BY 3,4 

-- select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
order by 1, 2

--Looking at The Total Cases VS Total Deaths
--Shows likelikehood of dying if you contract covid in country 

Select Location, date, total_cases, total_deaths, (total_deaths/(total_cases+0.00))*100 as DeathPercentage
From PortfolioProject..coviddeaths
Where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
--Showing what percentage of population got covid

Select Location, date, population, total_cases,  ((total_cases+0.00)/population)*100 as PercentPopulationInfected
From PortfolioProject..coviddeaths
--Where location like '%states%'
order by 1, 2

--Looking at countries with highest Infection Rate compared to  population

Select Location, population, Max(total_cases) as HighestInfectioncount, Max((total_cases+0.00)/population)*100 as
PercentPopulationInfected
From PortfolioProject..coviddeaths
GROUP BY Location, population
--Where location like '%states%'
order by PercentPopulationInfected desc

--showing countries with highest Death count per population

Select Location, Max(Cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
where continent is not null
GROUP BY Location
--Where location like '%states%'
order by TotalDeathCount desc


--Lets break this by continent
--showing continents with highest death count per poupulation  

Select continent, Max(Cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
where continent is NOT null
GROUP BY continent
--Where location like '%states%'
order by TotalDeathCount desc

-- Global Numbers
 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
ISNULL(SUM(new_deaths)/NULLIF(SUM(new_cases+0.00),0),0)*100 as [DeathPercentage]
From PortfolioProject..coviddeaths
--Where location like '%states%'
Where continent is not NULL
Group By date  
order by 1, 2 

--Looking at Total Population vs Vaccinations -- accross the world--
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
ISNULL(SUM(new_deaths)/NULLIF(SUM(new_cases+0.00),0),0)*100 as [DeathPercentage]
From PortfolioProject..coviddeaths
--Where location like '%states%'
Where continent is not NULL
--Group By date  
order by 1, 2 

--looking at total population vs Vaccination
Select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER   (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject ..coviddeaths dea
Join PortfolioProject ..CovidVaccinations vac 
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not NULL
  order by 2,3


  --use CTE 

With PopvsVac (Continent,location , date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER   (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject ..coviddeaths dea
Join PortfolioProject ..CovidVaccinations vac 
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not NULL
  --order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  location  nvarchar(255),
  Date datetime,
  Population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER   (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject ..coviddeaths dea
Join PortfolioProject ..CovidVaccinations vac 
  On dea.location = vac.location
  and dea.date = vac.date
  --Where dea.continent is not NULL
  --order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--creating view to store data for later visualization

Create view PercentPopulationVaccinated AS
Select dea.continent,dea.location ,dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject ..coviddeaths dea
Join PortfolioProject ..CovidVaccinations vac 
 On dea.location = vac.location
  and dea.date = vac.date
 Where dea.continent is not NULL
  --order by 2,3

Select *
From PercentPopulationVaccinated