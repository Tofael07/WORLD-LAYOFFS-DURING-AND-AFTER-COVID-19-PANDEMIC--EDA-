-- Data Cleaning world layoffs data --

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT *
FROM layoffs;


-- First thing we want to do is create a staging table. This is the one we will work in and clean the data. 
-- We want a table with the raw data in case something happens.

CREATE TABLE layoffs_staging
LIKE layoffs;


INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Now when we perform data cleaning, we usually follow a few steps

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns and rows.


-- 1. Remove Duplicates

-- Checking for duplicates.

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- checking if they are really duplicates or not!

SELECT *
FROM layoffs_staging
WHERE company ="casper";

-- Creating a table with "row_num" column.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

-- Inserting data in to new table.

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Removing the duplicates finally!

SELECT *
FROM layoffs_staging2
WHERE row_num >1;

DELETE
FROM layoffs_staging2
WHERE row_num >1;


-- Standardizing Data.


SELECT *
FROM layoffs_staging2;

-- Removing the blank spaces.

-- company

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- industry

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT industry, TRIM(industry)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = TRIM(industry);

-- There are some spelling mistakes we are correcting them.

SELECT *
FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";

-- country

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT country, TRIM(country)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(country);

-- There is an extra "." in country column so removing it.

SELECT DISTINCT country, TRIM(TRAILING "." FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING "." FROM country)
WHERE country LIKE "United States%";

SELECT *
FROM layoffs_staging2;

-- Changing The Date Format

SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, "%m/%d/%Y")
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Looking at Null values and Blank values!

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = "" ;

SELECT *
FROM layoffs_staging2
WHERE company = "Airbnb";


SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = "")
AND t2.industry IS NOT NULL;

-- Setting The Blank Values into NUll

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = "";

-- Populationg The Null Values 

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2;

-- 4. REMOVING COLUMNS AND ROWS

SELECT *
FROM layoffs_staging2
WHERE((total_laid_off IS NULL) OR (total_laid_off = ""))
AND ((percentage_laid_off IS NULL) OR (percentage_laid_off = "")) ;


-- DELETING The unwanted Rows that contain Null Values

DELETE 
FROM layoffs_staging2
WHERE ((total_laid_off IS NULL) OR (total_laid_off = ""))
AND ((percentage_laid_off IS NULL) OR (percentage_laid_off = ""));

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;