CREATE TABLE sales AS
SELECT *
FROM read_csv('data/raw/pp-*.csv',
header = false,
names = ['transaction_id', 'price', 'date_of_transfer', 'postcode',
         'property_type', 'old_new', 'duration', 'paon', 'saon', 
         'street', 'locality', 'town_city', 'district', 'county',
         'ppd_category', 'record_status']);
