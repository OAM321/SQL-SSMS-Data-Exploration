SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;



--select * from PortfolioProject..CovidVaccinations
--order by 3,4




-- Looking at Total cases vs Total Deaths by country
-- Shows likelihood of dying depending on home country
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
-- Filter to include only rows where the location contains the word 'states'
WHERE 
    location LIKE '%states%'
    AND continent IS NOT NULL -- Additional filter to ensure continent is not null
-- Order the results by location and date
ORDER BY 
    1, 2;




-- Looking at Total Cases vs Population
-- Shows what percent of population got Covid
SELECT 
    location, 
    date, 
    total_cases, 
    Population,
    (total_cases / Population) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
-- Filter to include only rows where the location contains the word 'states'
-- Uncomment the line below and add the appropriate condition if needed
-- WHERE 
--     location LIKE '%states%'
ORDER BY 
    1, 2;






-- Looking at countries with Highest infection rate compared to Population
-- Selecting location, maximum total cases, population, and maximum percent population infected
SELECT 
    location, 
    MAX(total_cases) AS HighestInfectionCount, 
    Population, 
    MAX((total_cases / Population)) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
-- Filtering to include only rows where the location contains the word 'states'
-- Uncomment the line below and add the appropriate condition if needed
-- WHERE 
--     location LIKE '%states%'
GROUP BY 
    Location, 
    Population
ORDER BY 
    PercentPopulationInfected DESC;




-- Selecting countries with the highest death count per population
SELECT 
    location, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
-- Filtering out rows where the continent is null
WHERE 
    continent IS NOT NULL
-- Grouping the results by location
GROUP BY 
    Location
-- Ordering the results by total death count in descending order
ORDER BY 
    TotalDeathCount DESC;



-- Breaking things down by continent
SELECT 
    continent, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
-- Filtering out rows where the continent is null
WHERE 
    continent IS NOT NULL
-- Grouping the results by continent
GROUP BY 
    Continent
-- Ordering the results by total death count in descending order
ORDER BY 
    TotalDeathCount DESC;




-- Showing Continents with the highest death count per population
SELECT 
    continent, 
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'   -- Commented out for now
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;

-- Global Numbers

SELECT 
    date, 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS int)) AS total_deaths, 
    SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage 
FROM 
    PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'   -- Commented out for now
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1,2;


-- Looking at Total Population vs Vaccinations

	SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    -- Calculate the rolling sum of new vaccinations per location
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    2, 3; -- Ordering by location and date


-- USE CTE

	WITH PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)

SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 
FROM 
    PopvsVac;





--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated; -- Drop the temporary table if it already exists

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)


Insert into #PercentPopulationVaccinated

    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
 order by 2,3

SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 
FROM 
    #PercentPopulationVaccinated;


-- Creating view to store data for later visualizations

Create view #PercentPopulationvaccinated as

    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
 

 select * from #PercentPopulationvaccinated

