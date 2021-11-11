CREATE OR REPLACE FUNCTION getTopSales(year1 INT, year2 INT,
                                         OUT Year INT, OUT Film CHAR,
                                          OUT sales bigint) returns TABLE AS $$
    DECLARE
        tab TABLE;
    BEGIN
        FOR y IN year1..year2
        LOOP
        SELECT orderid as o_id FROM orders WHERE EXTRACT(YEAR FROM orders.orderdate) = y 
            