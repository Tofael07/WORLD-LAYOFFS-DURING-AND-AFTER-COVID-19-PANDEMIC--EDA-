-- Exploratory Data Analysis (EDA) of world layoffs data.

-- Here we are going to explore the data and find trends or patterns or anything interesting.

SELECT *
FROM layoffs_staging2;

-- Looking at Total and Percentage to see how big these layoffs were

SELECT MAX(total_laid_off)
FROM layoffs_staging2;

SELECT MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Which companies had 1 which is basically 100 percent of their company laid off

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT COUNT(*)
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- these are mostly startups it looks like who all went out of business during this time.
-- if we order by funds_raised_millions we can see how big some of these companies were.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies with the biggest layoffs

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

-- industries with the biggest layoffs

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Countries with the biggest layoffs

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Locations with the biggest layoffs

SELECT location, country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location, country
ORDER BY 3 DESC;

-- Layoffs in different stages

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Time period of these layoffs

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Layoffs count in different years

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- layoffs count by months

SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ;

-- Cumulative total of layoffs by months

WITH Cumulative_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1
)
SELECT `month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS cumulative_total
FROM Cumulative_Total;


-- Year by Year Ranking of 5 Industries by Layoffs 

WITH industry_Year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
),industry_Year_Rank AS 
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM industry_Year_Rank
WHERE Ranking <= 5; 

-- Year by Year Ranking of 5 Companies by layoffs

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

