
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths,
	(CAST(Total_Cases AS float) / CAST(Population AS float)) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 3,4

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

-- ini gabisa krn Operasi pembagian (/) umumnya digunakan pada tipe data numerik, dan nvarchar adalah tipe data untuk data karakter atau string.
-- Konversi Tipe Data: Jika tipe data kolom adalah nvarchar, Anda dapat mencoba mengonversinya ke tipe data numerik menggunakan fungsi konversi, seperti CAST atau CONVERT
--select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--order by 1,2

SELECT Location, Date, Population, Total_Cases,
    (CAST(Total_Cases AS float) / CAST(Population AS float)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount,
    MAX((CAST(Total_Cases AS float) / CAST(Population AS float))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location
ORDER BY TotalDeathCount desc

SELECT Location, MAX(CAST(Total_deaths AS float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Let's break things down by continent 
-- Showing contintents with the highest death count per population

SELECT Continent, MAX(CAST(Total_deaths AS float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
Where continent is not null
GROUP BY Continent
ORDER BY TotalDeathCount desc

-- Global Numbers

--ini salah. Sepertinya salah satu atau kedua kolom new_cases dan new_deaths memiliki tipe data nvarchar, yang tidak dapat dijumlahkan secara langsung.
Select date, SUM(new_cases), SUM(cast(new_deaths as int))
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

--ini bener
SELECT date,
    SUM(CAST(new_cases AS float)) AS TotalNewCases,
    SUM(CAST(new_deaths AS float)) AS TotalNewDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

--ini gatau
SELECT SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths as float)) as total_deaths, 
    SUM(CAST(new_deaths as float))/(CAST(new_cases AS Float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

--bisa di running
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp table

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
 
 -- Creating View to store data for later visulizations

 Create View PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated



