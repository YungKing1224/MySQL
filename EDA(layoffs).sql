SELECT * FROM layoffs_staging2

-- Check company with highest and layoffs
SELECT company, sum(total_laid_off) FROM layoffs_staging2
Group By company
Order By 2 Desc;

-- Check location with highest and layoffs
select location, sum(total_laid_off) From layoffs_staging2
Group By location
Order By 2 Desc;


-- Check industry with highest layoffs
select industry, sum(total_laid_off) From layoffs_staging2
Group By industry
Order By 2 Desc;

-- Check country with highest layoffs
select country, sum(total_laid_off) From layoffs_staging2
Group By country
Order By 2 Desc;


-- do the same for funds raised in case you want to see


-- check company with the max total laid off in a day
SELECT company, max(total_laid_off) FROM layoffs_staging2
Group By company
Order By 2 Desc;

-- check other columns

-- Check ranges of dates of data
SELECT min(`date`), max(`date`)FROM layoffs_staging2

-- Check total laid off by days
SELECT `date`, sum(total_laid_off) FROM layoffs_staging2
Group By `date`
Order By 2 desc;

-- Check total laid off by year
SELECT YEAR(`date`), sum(total_laid_off) FROM layoffs_staging2
Group By YEAR(`date`);

-- Check total laid off by month
SELECT MONTH(`date`), sum(total_laid_off) FROM layoffs_staging2
Group By month(`date`)
Order By 1;

-- Check total laid off using moth and year
SELECT SUBSTRING(`date`,1,7) as date_month, SUM(total_laid_off) FROM layoffs_staging2
Group By date_month
Order By date_month;


-- USE CTE to get rolling total monthly

With cte_example as(
SELECT SUBSTRING(`date`,1,7) date_month, sum(total_laid_off) total FROM layoffs_staging2
group by date_month
)
SELECT date_month, total, sum(total) OVER(Order By date_month) From cte_example;


-- Group by company, with year and total sum for now the code goes in descending order of sum.

SELECT company, YEAR(`date`), sum(total_laid_off) FROM layoffs_staging2
Group By company, YEAR(`date`)
ORDER By 3 DESC;

-- Use first cte to create a ranking order for the table use dense ranking for maintaing
-- ranking if same values. use that ranking to order by then remove it later. Create another cte that selects from 1st cte
-- partition by year and order by total. 
-- Outside cte: SELECT the second cte and end the ranking on 5 to get top 5
WITH cte_example AS (
    SELECT 
        company, 
        YEAR(`date`) AS year_date, 
        SUM(total_laid_off) AS total 
    FROM 
        layoffs_staging2 
    GROUP BY 
        company, YEAR(`date`)
),
company_ranking AS (
    SELECT 
        *, 
        DENSE_RANK() OVER(PARTITION BY year_date ORDER BY total DESC) AS ranking
    FROM 
        cte_example
    WHERE 
        year_date IS NOT NULL
)
SELECT * FROM company_ranking
WHERE ranking <=5;