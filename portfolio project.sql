select *
from CovidDeaths
where continent is not null
order by 3,4


select*
from CovidVaccinations
where continent is not null
order by 3,4

select country,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
select country,date,total_cases,total_deaths,
case
when total_cases=0
then null
else (total_deaths/total_cases)*100 
end as Deathprecentage
from CovidDeaths
where continent is not null
and country = 'Egypt'
order by 1,2


--looking at the totasl cases vs the population
--shows what % of population got covid
select country,date,population,total_cases,(total_cases/population)*100  as precentage_of_population_got_covid
from CovidDeaths
where country = 'Egypt'
and continent is not null
order by 1,2

--looking at countries with highets cases compared to population
select country,population,max(total_cases) as Highest_Cases_Count,max((total_cases/population))*100  as precentage_of_population_got_covid
from CovidDeaths
where continent is not null
group by country,population
order by precentage_of_population_got_covid desc

--showing the countries with highest death_count per population
select country,max(total_deaths) as totaldeathcount ,population
from CovidDeaths
where continent is not null
group by country,population
order by totaldeathcount desc


-- showing the continent with highest death_count per population

SELECT continent, 
       MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM CovidDeaths
GROUP BY continent
ORDER BY totaldeathcount DESC;                

---Global Numbers
select sum(new_cases)as total_new_cases,sum(new_deaths)as total_new_deaths,
case
when sum(new_cases) = 0
then null
else
(sum(new_deaths)/sum(new_cases))*100 
end as deathprecentage
from CovidDeaths
where continent is not null
--group by date 
--order by deathprecentage desc


select *
from CovidVaccinations 
where country = 'Maldives'
order by date

--- looking and total population vs vaccination

select dea.continent,dea.country,dea.date, dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.country order by dea.country,dea.date) as rolling_people_vaccinated 
from CovidDeaths as dea 
join CovidVaccinations as vac
on dea.country = vac.country and dea.date = vac.date
where dea.continent is not null
order by 2,3




--use CTE

WITH popvsvac(continent,country,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,dea.country,dea.date, dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.country order by dea.country,dea.date) as rolling_people_vaccinated 
from CovidDeaths as dea 
join CovidVaccinations as vac
on dea.country = vac.country and dea.date = vac.date
where dea.continent is not null
)
select * ,(rolling_people_vaccinated/population)*100 as precntage_of_people_who_got_vaccinantion
from popvsvac

--TempTable
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
country nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric,
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.country,dea.date, dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.country order by dea.country,dea.date) as rolling_people_vaccinated 
from CovidDeaths as dea 
join CovidVaccinations as vac
on dea.country = vac.country and dea.date = vac.date
where dea.continent is not null
select * ,(rolling_people_vaccinated/population)*100 as precntage_of_people_who_got_vaccinantion
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create view precntage_of_people_who_got_vaccinantion as
select dea.continent,dea.country,dea.date, dea.population,vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.country order by dea.country,dea.date) as rolling_people_vaccinated 
from CovidDeaths as dea 
join CovidVaccinations as vac
on dea.country = vac.country and dea.date = vac.date
where dea.continent is not null
--select * ,(rolling_people_vaccinated/population)*100 as precntage_of_people_who_got_vaccinantion
select*
from precntage_of_people_who_got_vaccinantion

















