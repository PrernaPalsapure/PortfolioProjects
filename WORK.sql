-- used Crop_Yield Dataset
-- divided the dataset into two tables,crop_11 and crop_2

select * from crop_11;

-- showing the Total days taken by respective crops and the count of crops
select Crop, count(crop) as CountCrops,sum(Days_to_Harvest) as TotalDaysOfCrops 
from crop_11
group by crop;

-- showing the crops which are in west region only and used Fertilizer and irrigation 
select region ,crop, Fertilizer_Used , Irrigation_Used 
from crop_11 
where region like "West" and Fertilizer_Used like "TRUE" and Irrigation_Used like "TRUE";

-- table showing the crops produced in Sandy Soil_Type in respective Region 
select Region, Soil_Type, crop 
from crop_11 
where Soil_Type = "Sandy";      -- WE CAN CHANGE THE NAME OF THIS ACC. TO OUR PREFERENCES

-- Total Yield by Region
SELECT region, SUM(Yield_tons_per_hectare) AS total_yield 
FROM crop_11 
GROUP BY region
ORDER BY total_yield DESC;

-- Average Yield for each Crop
SELECT crop, AVG(Yield_tons_per_hectare) AS average_yield 
FROM crop_11 
GROUP BY crop
ORDER BY average_yield DESC;

-- Yields performed based on multiple factors
SELECT region, soil_type, crop, AVG(Yield_tons_per_hectare) AS average_yield 
FROM crop_11
WHERE fertilizer_used = 'TRUE' AND Irrigation_Used = 'TRUE' 
GROUP BY region, soil_type, crop
ORDER BY average_yield DESC;

-- Correlation between Harvest and Yield
SELECT Days_to_Harvest, AVG(Yield_tons_per_hectare) AS average_yield 
FROM crop_11
GROUP BY Days_to_Harvest
ORDER BY Days_to_Harvest;

-- regions with the Highest Yield for a specific Crop
SELECT region, SUM(Yield_tons_per_hectare) AS total_yield 
FROM crop_yield 
WHERE crop = 'Rice'           -- Replace 'Rice' with the crop you're analyzing
GROUP BY region
ORDER BY total_yield DESC;

-- Impact of Irrigation on Yield
SELECT Irrigation_Used, AVG(Yield_tons_per_hectare) AS average_yield 
FROM crop_11 
GROUP BY Irrigation_Used
ORDER BY average_yield DESC;

-- Yield Comparison with Fertilizer Use
SELECT fertilizer_used, AVG(Yield_tons_per_hectare) AS average_yield 
FROM crop_11 
GROUP BY fertilizer_used
ORDER BY average_yield DESC;

-- Identify the Best Soil Type for a Specific Crop
SELECT soil_type, AVG(Yield_tons_per_hectare) AS average_yield 
FROM crop_11
WHERE crop = 'Rice'
GROUP BY soil_type
ORDER BY average_yield DESC Limit 1;

-- Identify Low-Yielding Crops
SELECT Crop, AVG(Yield_tons_per_hectare) AS average_yield 
FROM crop_11
GROUP BY Crop
ORDER BY average_yield ASC
limit 1;

-- second table
select * from crop_2;

-- Joining the two tables now and see how fields are dependent on each other

SELECT 
    c1.Region, 
    c1.Soil_Type, 
    c1.Crop, 
    c1.Yield_tons_per_hectare, 
    c2.Rainfall_mm, 
    c2.Temperature_Celsius, 
    c2.Weather_Condition 
FROM crop_11 c1
JOIN crop_2 c2
ON c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type;

-- 1.Impact of Weather on Yield
WITH JoinedData AS (                  -- used CTE
    SELECT 
        c1.Region, 
        c1.Soil_Type, 
        c1.Crop, 
        c1.Yield_tons_per_hectare, 
        c2.Rainfall_mm, 
        c2.Temperature_Celsius, 
        c2.Weather_Condition 
    FROM 
        crop_11 c1
    JOIN 
        crop_2 c2
    ON 
        c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type
)
SELECT Crop, 
       Weather_Condition, 
       AVG(Yield_tons_per_hectare) AS average_yield 
FROM JoinedData
GROUP BY Crop, Weather_Condition
ORDER BY average_yield DESC;

-- 2. Yield Performance Based on Rainfall
SELECT c1.Region, 
       AVG(c1.Yield_tons_per_hectare) AS average_yield, 
       AVG(c2.Rainfall_mm) AS average_rainfall 
FROM crop_11 c1
JOIN crop_2 c2
ON c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type
GROUP BY c1.Region
ORDER BY average_rainfall DESC;

-- 3. Identify Regions with Low Yield and Extreme Weather
SELECT 
    c1.Region, 
    AVG(c1.Yield_tons_per_hectare) AS average_yield, 
    MAX(c2.Temperature_Celsius) AS max_temperature, 
    MIN(c2.Rainfall_mm) AS min_rainfall 
FROM crop_11 c1
JOIN crop_2 c2
ON c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type
GROUP BY c1.Region 
ORDER BY average_yield asc;

-- 4. Correlation Between Days to Harvest and Rainfall
SELECT c1.Days_to_Harvest, 
       AVG(c2.Rainfall_mm) AS average_rainfall, 
       AVG(c1.Yield_tons_per_hectare) AS average_yield 
FROM crop_11 c1
JOIN crop_2 c2
ON c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type
GROUP BY c1.Days_to_Harvest
ORDER BY c1.Days_to_Harvest;

-- 5. Regions with Optimal Rainfall for High Yield
WITH JoinedTable AS (                                -- used CTE
    SELECT 
        c1.Region, 
        c1.Yield_tons_per_hectare, 
        c2.Rainfall_mm 
    FROM 
        crop_11 c1
    JOIN 
        crop_2 c2
    ON 
        c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type
)
SELECT 
    Region, 
    AVG(Rainfall_mm) AS average_rainfall, 
    AVG(Yield_tons_per_hectare) AS average_yield 
FROM JoinedTable
GROUP BY Region
HAVING AVG(Rainfall_mm) BETWEEN 200 AND 600 
ORDER BY average_yield DESC;

-- Creating VIEW for better visualisation
CREATE VIEW JoinedCropData AS
SELECT 
    c1.Region, 
    c1.Soil_Type, 
    c1.Crop, 
    c1.Fertilizer_Used, 
    c1.Irrigation_Used, 
    c1.Days_to_Harvest, 
    c1.Yield_tons_per_hectare, 
    c2.Rainfall_mm, 
    c2.Temperature_Celsius, 
    c2.Weather_Condition
FROM crop_11 c1
JOIN crop_2 c2 ON c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type;

select * from JoinedCropData;

-- Best Soil Type for Yield under Specific Weather Conditions
CREATE VIEW YieldWeatherView AS
SELECT 
    c1.Soil_Type, 
    c2.Weather_Condition, 
    AVG(c1.Yield_tons_per_hectare) AS average_yield 
FROM crop_11 c1
JOIN crop_2 c2 ON c1.Region = c2.Region AND c1.Soil_Type = c2.Soil_Type
GROUP BY c1.Soil_Type, c2.Weather_Condition
ORDER BY average_yield DESC;

select * from YieldWeatherView;






















