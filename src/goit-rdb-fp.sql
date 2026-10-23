-- 1
CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic; 

SELECT 
	*
FROM infectious_cases
LIMIT 100;

-- 2
CREATE TABLE entities(
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL UNIQUE,
    Code VARCHAR(20)
);

INSERT INTO entities(Entity, Code)
SELECT DISTINCT
	Entity, 
    Code
FROM infectious_cases;

CREATE TABLE normalized_infectious_cases(
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY
) AS
SELECT 
	e.id AS entity_id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e ON e.Entity = ic.Entity;

ALTER TABLE normalized_infectious_cases
ADD CONSTRAINT fk_entity
FOREIGN KEY (entity_id) REFERENCES entities(id);

SELECT COUNT(*) AS original_count
FROM infectious_cases;

SELECT COUNT(*) AS normalized_count
FROM normalized_infectious_cases;

-- 3
SELECT 
	Entity,
    Code,
    AVG(Number_rabies) AS avg_rabies,
    MIN(Number_rabies) AS min_rabies,
    MAX(Number_rabies) As max_rabies,
    SUM(Number_rabies) AS sum_rabies
FROM normalized_infectious_cases AS nic
JOIN entities e ON e.id = nic.entity_id
WHERE nic.Number_rabies != '' AND Number_rabies IS NOT NULL
GROUP BY Entity, Code
ORDER BY avg_rabies DESC
LIMIT 10;

-- 4
SELECT
	Year,
    MAKEDATE(Year, 1) AS year_start,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
		YEAR, 
        MAKEDATE(Year, 1), 
        CURDATE()
	) AS difference_in_years
FROM normalized_infectious_cases;

-- 5
DROP FUNCTION IF EXISTS YearDifference;

DELIMITER //

CREATE FUNCTION YearDifference(input_year INT)
RETURNS INT
NO SQL
DETERMINISTIC
BEGIN
	RETURN TIMESTAMPDIFF(
		YEAR, 
        MAKEDATE(input_year, 1), 
        CURDATE()
	);
END//

DELIMITER ;

SELECT
	entity_id,
    Year,
    YearDifference(Year) AS difference_in_years
FROM normalized_infectious_cases;


