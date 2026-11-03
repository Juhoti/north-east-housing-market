CREATE TABLE ne_sales AS
SELECT transaction_id, price, date_of_transfer,
       year(date_of_transfer) AS sale_year,
       postcode, property_type, old_new, district
FROM sales
WHERE district IN ('NORTHUMBERLAND', 'COUNTY DURHAM', 'GATESHEAD', 'NORTH TYNESIDE',
                   'SOUTH TYNESIDE', 'SUNDERLAND', 'NEWCASTLE UPON TYNE', 'MIDDLESBROUGH',
                   'HARTLEPOOL', 'DARLINGTON', 'STOCKTON-ON-TEES', 'REDCAR AND CLEVELAND')
  AND ppd_category = 'A'
  AND property_type <> 'O'
-- Outlier rule: Sales under £20,000 are for the most part too sparse to be considered normal market purchases
  AND price >= 20000;
