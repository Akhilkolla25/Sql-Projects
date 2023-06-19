/*
Select *
From [sql project]..CovidDeaths
Order by 3,4
*/

/*
Select *
From [sql project]..CovidVaccinations
Order by 3,4
*/

--Data Table

Select Location, Date, total_cases, new_cases, total_deaths, population
From [sql project]..CovidDeaths
Order by 1,2

Select Location, Date, total_vaccinations, new_vaccinations, total_tests, new_tests
From [sql project]..CovidVaccinations
Order by 1,2

--Indian Statistics

--Total Cases Versus Total Deaths
--Death rate if Contracted Covid in India

Select Location, Date, total_cases, total_deaths, (total_deaths / total_cases) *100 as DeathPercentage
From [sql project]..CovidDeaths
Where location like '%india%'
Order by 1,2

--Total cases Versus Population
--Percentage Of people Infected by Covid in India

Select Location, Date, population, total_cases, (total_cases / population) *100 as CovidInfectionRate
From [sql project]..CovidDeaths
Where location like '%India%'
Order by Location, date

--Total Death Percentage per Population in India

Select Location, Sum(Cast(new_deaths as bigint)) as TotalDeathsRecorded, Sum(Cast(new_deaths as bigint)) / population *100 as DeathsPercentage
From [sql project]..CovidDeaths
Where location like '%india%'
Group by location, population

--Yearly/monthly Infection Rate in india 

Select Location, Year(Date) as Year, Datename(MM, date) as Month, Population, Max(total_cases) as TotalCases
, Max(total_cases) / population *100 as InfectedPercentage
From [sql project]..CovidDeaths
Where location like '%India%'
Group by Year(date), Datename(MM, date), location, population

--Total vaccinations in india per year

Select dea.location, Year(dea.date)as year, Datename(MM, dea.date) as month, Max(vac.total_vaccinations) as TotalVaccinations
, Max(vac.total_vaccinations / dea.population) *100 as VaccinationPercentage
From [sql project]..CovidDeaths dea
Join [sql project]..CovidVaccinations vac
	on dea.location=vac.location
		and dea.date=vac.date
Where dea.location like '%India%'
And vac.total_vaccinations is not null
Group By dea.location, Year(dea.date), Datename(mm, dea.date), dea.population


--Countries with Highest Infection Rate Compared to Population

Select Location, population, Max(total_cases) as HighestCasesRecorded, Max((total_cases) / population) *100 as HighestInfectedPrecentage
From [sql project]..CovidDeaths
Where continent is not null
Group by location, population
Order by 4 Desc


--Death Count by Countries

Select Location, Max(Cast(total_deaths as int)) as TotalDeathsRecorded
From [sql project]..CovidDeaths
Where continent is not null
Group by location
Order by 2 Desc

--Death Count by Continent

Select continent, Max(Cast (total_deaths as int)) as TotalDeathsRecorded
From [sql project]..CovidDeaths
Where continent is  not null
Group by continent
Order by 2 Desc

--Global Statistics

--Total Death Percentage

Select /*date,*/ Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as bigint)) as TotalDeaths
, Nullif(Sum(Cast(new_deaths as bigint)),0) / (Sum(new_cases)) *100 as DeathPercentage
From [sql project] .. CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

--By Continent

Select /*date,*/ continent, Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as bigint)) as TotalDeaths
, Nullif(Sum(Cast(new_deaths as bigint)),0) / (Sum(new_cases)) *100 as DeathPercentage
From [sql project] .. CovidDeaths
Where continent is not null
Group by Continent

--By Country

Select /*date,*/ location, Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as bigint)) as TotalDeaths
, Nullif(Sum(Cast(new_deaths as bigint)),0) / (Sum(new_cases)) *100 as DeathPercentage
From [sql project] .. CovidDeaths
Where continent is not null
Group by location
Order by 4 Desc

--Total Vaccinations by continent

With Vaccbycon (continent, location , population, TotalVaccinations)
As 
(
Select dea.continent, dea.location, Avg(dea.population) as Population, Sum(Cast(vac.new_vaccinations as bigint)) As TotalVaccinations
From [sql project]..CovidDeaths dea
Join [sql project]..CovidVaccinations vac
	on dea.location=vac.location
		and dea.date=vac.date
Where dea.continent is not null
Group by dea.continent,Dea.location
)

Select continent, Sum(population) as Population, Sum(TotalVaccinations) as TotalVaccination, 
Sum(TotalVaccinations) / Sum(population) *100 as VaccinatedPercentage
From Vaccbycon
Group by continent




--Total Population versus Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
From [sql project]..CovidDeaths dea
Join [sql project]..CovidVaccinations vac
	on dea.location=vac.location
		and dea.date=vac.date
Where dea.continent is not null
--And dea.location like '%buru%'
Order by 2,3


--Vaccination Percentage per Popultion on each Day

With PopvsVacc (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
From [sql project]..CovidDeaths dea
Join [sql project]..CovidVaccinations vac
	on dea.location=vac.location
		and dea.date=vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100 as VaccinationsperPopulation
From PopvsVacc



/*
--Create view
	
Create View PercentagePeopleVaccinated
As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
From [sql project]..CovidDeaths dea
Join [sql project]..CovidVaccinations vac
	on dea.location=vac.location
		and dea.date=vac.date
Where dea.continent is not null

*/