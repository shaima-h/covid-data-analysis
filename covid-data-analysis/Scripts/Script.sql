SELECT * FROM coviddeaths LIMIT 10;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2

-- total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like '%States%'
order by 1,2;