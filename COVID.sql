--SELECT *
--FROM portfolio..CovidDeaths
--order by 3,4

Select *
FROM portfolio..Covidvaccination
order by 3,4

Select location, Date, total_cases, new_cases, total_deaths, population 
From Covid..[COVID DEATHS]
order by 1,2

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid..[COVID DEATHS]
WHERE location like '%state%'
order by 1,2

Select location,date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM Covid..[COVID DEATHS]
--WHERE location like '%state%'
order by 1,2

Select location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 AS Percentagepopulationinfected
FROM Covid..[COVID DEATHS]
--WHERE location like '%state%'
group by location, population
order by percentagepopulationinfected desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathscount
FROM Covid..[COVID DEATHS]
--WHERE location like '%state%'
where continent is not null
group by location
order by TotalDeathscount desc

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathspercentage--, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid..[COVID DEATHS]
--WHERE location like '%state%'
where continent is not null
group by date
order by 1,2


WITH popvsVac (continent,Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date ROWS unbounded preceding) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Covid..[COVID DEATHS] dea
JOIN Covid..[COVID VACCINATION] vac
     ON dea.location = vac.location
	 and dea.date =vac.date
where dea.population is not null and dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated)/(Population)*100
from popvsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date ROWS unbounded preceding) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Covid..[COVID DEATHS] dea
JOIN Covid..[COVID VACCINATION] vac
     ON dea.location = vac.location
	 and dea.date =vac.date
--where dea.population is not null and dea.continent is not null
Select *, (RollingPeopleVaccinated)/(Population)*100
from #PercentPopulationVaccinated



Create View PercentPopulationVaccinated As 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date ROWS unbounded preceding) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Covid..[COVID DEATHS] dea
JOIN Covid..[COVID VACCINATION] vac
     ON dea.location = vac.location
	 and dea.date =vac.date
where dea.population is not null and dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated



