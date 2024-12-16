-- The database has the following schema:

-- Customers(customer_id, first_name, last_name, email, phone_number)
-- Pricing(size, daily_rate, weekly_rate)
-- Vehicles(vehicle_id, make, model, year, license_plate, size)
-- Locations(location_id, location_name, address, phone_number)
-- Maintenance(maintenance_id, vehicle_id, maintenance_date, details, status)
-- Rents(customer_id, vehicle_id, rental_start_date, rental_end_date, pickup, dropoff)
-- Payments(payment_id, customer_id, vehicle_id, rental_start_date, amount, payment_date, payment_method)

select max(cnt) as q4 
from (
    select count(vehicle_id) as cnt
    from maintenance
    group by vehicle_id
); -- answer 4

select count(DISTINCT c.customer_id) as q6
from customers c
join rents r on c.customer_id = r.customer_id
where c.phone_number like '+45%'
; -- answer 1966

select count(*) as q8_b
from (
    select DISTINCT customer_id
    from rents
    where pickup = (select location_id from Locations where location_name = 'Egernsund')
    intersect
    select DISTINCT customer_id
    from rents
    where pickup = (select location_id from Locations where location_name = 'Hundested')
    except
    select DISTINCT customer_id
    from rents
    where pickup = (select location_id from Locations where location_name = 'Stouby')
); -- answer 85

select count(DISTINCT r1.customer_id) as q8_c
from rents r1 
join rents r2 on r1.customer_id = r2.customer_id
left join rents r3 on r1.customer_id = r3.customer_id
and r3.pickup = (select location_id from Locations where location_name = 'Stouby')
where r1.pickup = (select location_id from Locations where location_name = 'Egernsund')
and r2.pickup = (select location_id from Locations where location_name = 'Hundested')
and r3.customer_id is NULL; -- answer 85

select max(total_revenue) as q10
from (
    select l.location_name, sum(p.amount) as total_revenue
    from rents r
    join payments p on r.customer_id = p.customer_id
                    and r.vehicle_id = p.vehicle_id
                    and r.rental_start_date = p.rental_start_date
    join Locations l on r.pickup = l.location_id
    group by l.location_name
) as x; -- answer 3404247.50

select count(*) as q11 from (
    select r.customer_id
    from rents r
    join vehicles v on r.vehicle_id = v.vehicle_id
    group by r.customer_id
    having count(DISTINCT v.size) = (select count(DISTINCT size) from vehicles) 
); -- answer 20


drop view if exists dropoffsjan2024;
create view dropoffsjan2024 as 
select r.dropoff as location_id, count(r.dropoff) as dropoffs
from rents r
join vehicles v on r.vehicle_id = v.vehicle_id
where EXTRACT(YEAR FROM r.rental_end_date) = '2024' 
and EXTRACT(MONTH FROM r.rental_end_date) = '01'
and v.size = 'Compact'
group by r.dropoff
;

select l.location_name as q13
from dropoffsjan2024 dr
join locations l on dr.location_id = l.location_id
where dropoffs = (select max(dropoffs) from dropoffsjan2024)
; -- answer Stouby


select round((man*1.00 / vec*1.00)*100.00) as q15 from (
    select count(DISTINCT v.vehicle_id) as vec, 
            count(DISTINCT m.vehicle_id) as man
    from vehicles v
    left join Maintenance m on v.vehicle_id = m.vehicle_id
); -- answer 49

-- How many customers have rented vehicles from all rental locations?
select count(*) as q17 from (
    select r.customer_id
    from rents r
    group by r.customer_id
    having count(DISTINCT r.pickup) = (select count(*) from Locations)
); -- answer 0


-- DROP TRIGGER IF EXISTS CalculatePaymentAmount ON Rents;
-- DROP FUNCTION IF EXISTS CalculatePaymentAmount;

-- CREATE OR REPLACE FUNCTION CalculatePaymentAmount()
-- RETURNS TRIGGER
-- AS $BODY$
-- DECLARE dRate INT;
-- DECLARE wRate INT;
-- DECLARE totalDays INT;
-- BEGIN
--     SELECT daily_rate, weekly_rate INTO dRate, wRate
--     FROM Pricing p
--     JOIN Vehicles v ON p.size = v.size
--     WHERE v.vehicle_id = NEW.vehicle_id;

--     SELECT (NEW.rental_start_date - NEW.rental_end_date) INTO totalDays;

--     INSERT INTO Payments (
--         customer_id, vehicle_id, rental_start_date, amount
--     ) VALUES (
--         NEW.customer_id, NEW.vehicle_id, NEW.rental_start_date,
--         ((totalDays / 7) * wRate + (totalDays % 7) * dRate)
--     );

--     RETURN NEW;
-- END;
-- $BODY$ LANGUAGE plpgsql;

-- CREATE OR REPLACE TRIGGER CalculatePaymentAmount
-- AFTER INSERT ON Rents
-- FOR EACH ROW EXECUTE PROCEDURE CalculatePaymentAmount();

-- BEGIN;
-- INSERT INTO Rents (customer_id, vehicle_id, rental_start_date, rental_end_date, pickup, dropoff) VALUES (2584, 415, '2024-12-05', '2024-12-19', 1, 5);
-- ROLLBACK;

-- DROP TRIGGER IF EXISTS CalculatePaymentAmount ON Rents;
-- DROP FUNCTION IF EXISTS CalculatePaymentAmount;