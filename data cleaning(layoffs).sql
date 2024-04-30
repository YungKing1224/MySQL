-- Start by downloading data from kaggle:
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- View table
Select * From layoffs;

-- create a staging table to avoid changing raw data
Create Table layoffs_staging
Like layoffs;

-- view table
Select * From layoffs_staging

-- insert data from layoffs into layoffs_staging
INSERT layoffs_staging
Select * From layoffs

-- view new table created
Select * From layoffs_staging


-- use cte to check for dublicate data
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
           total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
    FROM layoffs_staging
)
SELECT * FROM duplicate_cte
Where row_num > 1;


-- create a new table layoff_staging2 and add row_num column
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert data into layoffs_staging2
INSERT INTO layoffs_staging2
SELECT *,
           ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
           total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
    FROM layoffs_staging

-- update thetable by remove spacing at the end and beginning of values. Do this for all values.
Update layoffs_staging2
SET location = trim(location);

-- Check if countries have dublicates or misspellings
select distinct country from layoffs_staging2
Order by 1;

-- change date structure
select `date`, 
str_to_date(`date`, '%m/%d/%Y') 
from layoffs_staging2;

-- make change by updating table
Update layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y') 

-- change date format from text into date format
ALTER TABLE layoffs_staging2
Modify column `date` DATE;


-- check for null or blank industry values
SELECT * FROM layoffs_staging2
Where industry IS NULL
OR
industry ='';

-- check if found company has one with industry value this is to populate the column with that industry value
SELECT * FROM layoffs_staging2
Where company like 'Appsmith%'

-- delete the rows with blank or null industry values
DELETE FROM layoffs_staging2
where industry is NULL 
OR
industry = '';

-- delete rows with both total laid off nad percentage laid off as null or blank values
DELETE FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off ='') 
AND 
(percentage_laid_off IS NULL OR percentage_laid_off ='');

-- delete column row_num after using it
ALTER TABLE layoffs_staging2
drop column row_num;

-- view table
SELECT * FROM layoffs_staging2;

-- check if any values remain of nul or blank total laid off and percentage laid off
SELECT * FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off ='') 
AND 
(percentage_laid_off IS NULL OR percentage_laid_off='');
