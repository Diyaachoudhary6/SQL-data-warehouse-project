/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script perform various quality checks for data consistency, accuracy,
    and standization across the 'silver' schema. It includes checks for:
     - Null or duplicate primary keys.
     - Unwanted spaces in string fields.
     - Data standardization and consistency.
     - Invalid date renges and orders.
     - Data consistency between relted fields.

Usage Notes:
     - Run these checks after data loading Silver Layer.
     - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ===============================================================================
-- Checking 'silver.crm_cust_info' 
-- ===============================================================================

-- Check for NULL or Duplicates in Primary Key 
-- Expectation: No Result
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL ;

-- Check for unwanted Spaces 
-- Expectation: No results

SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data Standardization & Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT *
FROM silver.crm_cust_info;

-- ===============================================================================
-- Checking 'silver.crm_prd_info' 
-- ===============================================================================

-- Check for null or Duplicates in Primary Key 
-- Expectation: No Result

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- expectation: no results

SELECT prd_cost
FROM silver.crm_prd_info 
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization & Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders

SELECT * 
FROM silver.crm_prd_info 
WHERE prd_end_dt < prd_start_dt;

SELECT * 
FROM silver.crm_prd_info

-- ===============================================================================
-- Checking 'silver.crm_sales_details' 
-- ===============================================================================

-- Check for Invalid  Order Dates
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101;


-- Check for Invalid ship Dates
SELECT 
NULLIF(sls_ship_dt,0) sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101


-- Check for Invalid due Dates
SELECT 
NULLIF(sls_due_dt,0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101


-- Check for invalid date orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Check Data Consistency: Between Sales, Quantity, and Price [Business Rule]
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative 

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
          THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
          THEN sls_sales/ NULLIF(sls_quantity,0)
    ELSE sls_price
END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 
ORDER BY sls_sales, sls_quantity, sls_price;

-- Rules:- 
-- >> If Sales is negative, zero,or null, derive it using Quantity and Price.
-- >> If Prices is zero or null, calculate it using Sales and Quantity.
-- >> If Price is negative, convert it to positive value

SELECT * FROM silver.crm_sales_details

-- ===============================================================================
-- Checking 'silver.erp_cust_az12' 
-- ===============================================================================

-- Matching cid and cst_id FRom different table
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))   -- Data Transformation: Remove 'NAS' prefix if present
     ELSE cid
END AS cid 
FROM silver.erp_cust_az12;


-- Identify Out-of-Range Dates (Impossible birthdate)

SELECT DISTINCT 
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency 
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

SELECT 
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'  -- Data Transformation
     WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'      -- Data Transformation
     ELSE  'n/a' 
END AS gen
FROM silver.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12;

-- ===============================================================================
-- Checking 'silver.erp_loc_a101' 
-- ===============================================================================

-- Matching data cid and cst_key from two tables
SELECT 
REPLACE(cid,'-','') cid
FROM silver.erp_loc_a101;

-- Data Standardization & Consistency 
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT * FROM silver.erp_loc_a101;

-- ===============================================================================
-- Checking 'silver.erp_px_cat_g1v2' 
-- ===============================================================================

-- Check for unwanted spaces 
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency 
SELECT DISTINCT 
cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT 
subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT 
maintenance
FROM silver.erp_px_cat_g1v2;

SELECT * FROM silver.erp_px_cat_g1v2;












-- ===============================================================================
-- Checking 'silver.crm_cust_info' 
-- ===============================================================================

-- Check for NULL or Duplicates in Primary Key 
-- Expectation: No Result
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL ;

-- Check for unwanted Spaces 
-- Expectation: No results

SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data Standardization & Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT *
FROM silver.crm_cust_info;

-- ===============================================================================
-- Checking 'silver.crm_prd_info' 
-- ===============================================================================

-- Check for null or Duplicates in Primary Key 
-- Expectation: No Result

SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- expectation: no results

SELECT prd_cost
FROM silver.crm_prd_info 
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization & Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders

SELECT * 
FROM silver.crm_prd_info 
WHERE prd_end_dt < prd_start_dt;

SELECT * 
FROM silver.crm_prd_info

-- ===============================================================================
-- Checking 'silver.crm_sales_details' 
-- ===============================================================================

-- Check for Invalid  Order Dates
SELECT 
NULLIF(sls_order_dt,0) sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101;


-- Check for Invalid ship Dates
SELECT 
NULLIF(sls_ship_dt,0) sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101


-- Check for Invalid due Dates
SELECT 
NULLIF(sls_due_dt,0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101


-- Check for invalid date orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Check Data Consistency: Between Sales, Quantity, and Price [Business Rule]
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative 

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
          THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
          THEN sls_sales/ NULLIF(sls_quantity,0)
    ELSE sls_price
END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 
ORDER BY sls_sales, sls_quantity, sls_price;

-- Rules:- 
-- >> If Sales is negative, zero,or null, derive it using Quantity and Price.
-- >> If Prices is zero or null, calculate it using Sales and Quantity.
-- >> If Price is negative, convert it to positive value

SELECT * FROM silver.crm_sales_details

-- ===============================================================================
-- Checking 'silver.erp_cust_az12' 
-- ===============================================================================

-- Matching cid and cst_id FRom different table
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))   -- Data Transformation: Remove 'NAS' prefix if present
     ELSE cid
END AS cid 
FROM silver.erp_cust_az12;


-- Identify Out-of-Range Dates (Impossible birthdate)

SELECT DISTINCT 
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency 
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

SELECT 
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'  -- Data Transformation
     WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'      -- Data Transformation
     ELSE  'n/a' 
END AS gen
FROM silver.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12;

-- ===============================================================================
-- Checking 'silver.erp_loc_a101' 
-- ===============================================================================

-- Matching data cid and cst_key from two tables
SELECT 
REPLACE(cid,'-','') cid
FROM silver.erp_loc_a101;

-- Data Standardization & Consistency 
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT * FROM silver.erp_loc_a101;

-- ===============================================================================
-- Checking 'silver.erp_px_cat_g1v2' 
-- ===============================================================================

-- Check for unwanted spaces 
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency 
SELECT DISTINCT 
cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT 
subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT 
maintenance
FROM silver.erp_px_cat_g1v2;

SELECT * FROM silver.erp_px_cat_g1v2;

