/*
CREATE TABLE CovidDeaths (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population NUMERIC,
    total_cases NUMERIC,
    new_cases NUMERIC,
    new_cases_smoothed NUMERIC,
    total_deaths NUMERIC,
    new_deaths NUMERIC,
    new_deaths_smoothed NUMERIC,
    total_cases_per_million NUMERIC,
    new_cases_per_million NUMERIC,
    new_cases_smoothed_per_million NUMERIC,
    total_deaths_per_million NUMERIC,
    new_deaths_per_million NUMERIC,
    new_deaths_smoothed_per_million NUMERIC,
    reproduction_rate NUMERIC,
    icu_patients NUMERIC,
    icu_patients_per_million NUMERIC,
    hosp_patients NUMERIC,
    hosp_patients_per_million NUMERIC,
    weekly_icu_admissions NUMERIC,
    weekly_icu_admissions_per_million NUMERIC,
    weekly_hosp_admissions NUMERIC,
    weekly_hosp_admissions_per_million NUMERIC
);

CREATE TABLE CovidVaccinations (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    new_tests NUMERIC,
    total_tests NUMERIC,
    total_tests_per_thousand NUMERIC,
    new_tests_per_thousand NUMERIC,
    new_tests_smoothed NUMERIC,
    new_tests_smoothed_per_thousand NUMERIC,
    positive_rate NUMERIC,
    tests_per_case NUMERIC,
    tests_units VARCHAR(50),
    total_vaccinations NUMERIC,
    people_vaccinated NUMERIC,
    people_fully_vaccinated NUMERIC,
    new_vaccinations NUMERIC,
    new_vaccinations_smoothed NUMERIC,
    total_vaccinations_per_hundred NUMERIC,
    people_vaccinated_per_hundred NUMERIC,
    people_fully_vaccinated_per_hundred NUMERIC,
    new_vaccinations_smoothed_per_million NUMERIC,
    stringency_index NUMERIC,
    population_density NUMERIC,
    median_age NUMERIC,
    aged_65_older NUMERIC,
    aged_70_older NUMERIC,
    gdp_per_capita NUMERIC,
    extreme_poverty NUMERIC,
    cardiovasc_death_rate NUMERIC,
    diabetes_prevalence NUMERIC,
    female_smokers NUMERIC,
    male_smokers NUMERIC,
    handwashing_facilities NUMERIC,
    hospital_beds_per_thousand NUMERIC,
    life_expectancy NUMERIC,
    human_development_index NUMERIC
);
*/

SELECT * FROM coviddeaths LIMIT 10;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2

-- total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like '%States%'
order by 1,2

-- total cases vs population: shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from coviddeaths
order by 1,2

-- countries with highest infection rate vs population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
	as percent_population_infected
from coviddeaths
where total_cases is not null and population is not null
group by location, population
order by percent_population_infected desc

-- countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as total_death_count
from coviddeaths
where total_deaths is not null and continent <> ''
group by location
order by total_death_count desc

-- breaking down by continent: continents with highest death count
select location, MAX(cast(total_deaths as int)) as total_death_count
from coviddeaths
where continent = ''
group by location
order by total_death_count desc

-- global numbers
select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage--total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where continent <> ''
group by date
order by 1,2

-- total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
	as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
order by 2,3

-- use cte
with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
	(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
		as rolling_people_vaccinated
	from coviddeaths dea
	join covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent <> ''
	--order by 2,3
	)
select *, (rolling_people_vaccinated/population)*100
from pop_vs_vac

-- creating view to store data for later visualizations
/*
create view percent_pop_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
	as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
--order by 2,3
*/

select * from percent_pop_vaccinated


-- queries for tableau
-- 1.
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 
	as DeathPercentage
from coviddeaths
where continent <> ''
order by 1,2

-- 2.
select location, SUM(new_deaths) as TotalDeathCount
from coviddeaths
where continent <> '' 
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

-- 3.
select location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 
	as PercentPopulationInfected
from coviddeaths
Group by location, population
order by PercentPopulationInfected desc

-- 4.
select location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 
	as PercentPopulationInfected
from coviddeaths
group by location, population, date
order by PercentPopulationInfected desc




