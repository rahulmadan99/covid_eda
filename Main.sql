

Select *
From covid_deaths
Where continent in ('')
order by 3,4;

Select *
From covid_vacc
-- Where continent in ('')
order by 3,4;

-- Select Data that we are going to be starting with

Select Location, STR_TO_DATE(date, '%e-%c-%Y ') as new_date, total_cases, new_cases, total_deaths, population
From covid_deaths
Where continent not in ('')
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, STR_TO_DATE(date, '%e-%c-%Y ') as new_date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_deaths
Where location like '%india%'
and continent not in ('')
-- and total_deaths not in ('')
order by 1,2;

-- Total cases with respect to the population

Select Location, STR_TO_DATE(date, '%e-%c-%Y ') as new_date, 
total_cases,total_deaths, population, (total_cases/population)*100 as PercentPopulationInfected
From covid_deaths
Where location like '%india%'
and continent not in ('')
-- and total_deaths not in ('')
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Where continent not in ('')
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From covid_deaths
Where continent not in ('')
Group by Location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From covid_deaths
Where location in ('Africa','Europe','Asia','North america', 'Oceania','South America')
Group by location
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From covid_deaths
where continent not in ('')
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, STR_TO_DATE(d.date, '%e-%c-%Y ') as date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, STR_TO_DATE(d.date, '%e-%c-%Y ')) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From covid_deaths d
Join covid_vacc v
	On d.location = v.location
	and d.date = v.date
where d.continent not in ('') 
and new_vaccinations is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, STR_TO_DATE(d.date, '%e-%c-%Y ') as new_date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, STR_TO_DATE(d.date, '%e-%c-%Y ')) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From covid_deaths d
Join covid_vacc v
	On d.location = v.location
	and d.date = v.date
where d.continent not in ('') 
and new_vaccinations is not null
-- order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists Percent_PopulationVaccinated;
Create Table Percent_PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into Percent_PopulationVaccinated
Select d.continent, d.location, STR_TO_DATE(d.date, '%e-%c-%Y ') as date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, STR_TO_DATE(d.date, '%e-%c-%Y ')) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From covid_deaths d
Join covid_vacc v
	On d.location = v.location
	and d.date = v.date
where d.continent not in ('') 
and new_vaccinations is not null
order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From Percent_PopulationVaccinated;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, STR_TO_DATE(d.date, '%e-%c-%Y ') as date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.Location Order by d.location, STR_TO_DATE(d.date, '%e-%c-%Y ')) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From covid_deaths d
Join covid_vacc v
	On d.location = v.location
	and d.date = v.date
where d.continent not in ('') 
and new_vaccinations is not null;

