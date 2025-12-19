CREATE TABLE flights_delay (
    year INT,
    month INT,
    day INT,
    day_of_week INT,
    airline TEXT,
    flight_number TEXT,
    tail_number TEXT,
    origin_airport TEXT,
    destination_airport TEXT,
    scheduled_departure INT,
    departure_time INT,
    departure_delay INT,
    taxi_out INT,
    wheels_off INT,
    scheduled_time INT,
    elapsed_time INT,
    air_time INT,
    distance INT,
    wheels_on INT,
    taxi_in INT,
    scheduled_arrival INT,
    arrival_time INT,
    arrival_delay INT,
    diverted INT,
    cancelled INT,
    cancellation_reason TEXT,
    air_system_delay INT,
    security_delay INT,
    airline_delay INT,
    late_aircraft_delay INT,
    weather_delay INT
	)

select *from flights_delay;

select count(*)from flights_delay;

CREATE TABLE airports (
    iata_code VARCHAR(10) PRIMARY KEY,
    airport_name VARCHAR(150),
    city VARCHAR(100),
    state VARCHAR(10),
    country VARCHAR(50),
    latitude NUMERIC,
    longitude NUMERIC
)

select *from airports;


CREATE TABLE airlines (
    iata_code VARCHAR(10) PRIMARY KEY,
    airline_name VARCHAR(100)
)


select *from airports;

ALTER TABLE flights ADD COLUMN scheduled_departure_time TIME;
ALTER TABLE flights_delay ADD COLUMN wheels_off_time TIME;
ALTER TABLE flights_delay ADD COLUMN wheels_on_time TIME;
ALTER TABLE flights_delay ADD COLUMN scheduled_arrival_time TIME;
ALTER TABLE flights_delay ADD COLUMN arrival_time_converted TIME;


SELECT DISTINCT cancellation_reason FROM flights_delay;

SELECT flight_number, departure_delay
FROM flights_delay
WHERE departure_delay > 30;

SELECT flight_number
FROM  flights_delay
WHERE cancellation_reason IS NULL;

SELECT flight_number , arrival_delay
FROM flights_delay
WHERE arrival_delay > 60;

SELECT flight_number
FROM flights_delay
WHERE departure_delay IS NULL;

UPDATE flights_delay
SET scheduled_departure_time = 
    (LEFT(LPAD(scheduled_departure::TEXT, 4, '0'), 2) || ':' ||
     RIGHT(LPAD(scheduled_departure::TEXT, 4, '0'), 2))::TIME;

UPDATE flights_delay
SET wheels_off_time = 
    (LEFT(LPAD(wheels_off::TEXT, 4, '0'), 2) || ':' ||
     RIGHT(LPAD(wheels_off::TEXT, 4, '0'), 2))::TIME;

UPDATE flights_delay
SET scheduled_arrival_time = 
    (LEFT(LPAD(scheduled_arrival::TEXT, 4, '0'), 2) || ':' ||
     RIGHT(LPAD(scheduled_arrival::TEXT, 4, '0'), 2))::TIME;

UPDATE flights_delay
SET wheels_on_time = 
    (LEFT(LPAD(wheels_on::TEXT, 4, '0'), 2) || ':' ||
     RIGHT(LPAD(wheels_on::TEXT, 4, '0'), 2))::TIME;

UPDATE flights_delay
SET arrival_time_converted = 
    (LEFT(LPAD(arrival_time::TEXT, 4, '0'), 2) || ':' ||
     RIGHT(LPAD(arrival_time::TEXT, 4, '0'), 2))::TIME;


select scheduled_departure,
scheduled_departure_time from
flights_delay limit 10;


--exploratory data anyalysis(EDA)

--TOTAL FLIGHTS AND TOTAL CANCELLATION
SELECT 
COUNT(*) AS total_flights,
SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS total_cancellations,
ROUND(SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_percentage
FROM flights_delay;

--AVERAGE DEPARTURE DELAY AND ARRIVAL DELAY
SELECT 
ROUND(AVG(departure_delay), 2) AS avg_departure_delay,
ROUND(AVG(arrival_delay), 2) AS avg_arrival_delay
FROM flights_delay
WHERE cancelled = 0;

--CANCELLTION REASON DISTRIBUTION
SELECT 
cancellation_reason,
COUNT(*) AS total_cancellations
FROM flights_delay
WHERE cancelled = 1
GROUP BY cancellation_reason
ORDER BY total_cancellations DESC;


--AIRLINE-WISE ON TIME PERFORMANCE(OTP RATE)
SELECT
airline,
COUNT(*) AS total_flights,
SUM(CASE WHEN arrival_delay <= 15 THEN 1 ELSE 0 END) AS on_time_flights,
ROUND(SUM(CASE WHEN arrival_delay <= 15 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS otp_rate_percentage
FROM flights_delay
WHERE cancelled = 0
GROUP BY airline
ORDER BY 4 DESC;  

--ORIGIN AIRPORT -WISE AVERAGE ARRIVAL DELAY
SELECT
origin_airport,
ROUND(AVG(arrival_delay), 2) AS avg_arrival_delay
FROM flights_delay
WHERE cancelled = 0
GROUP BY origin_airport
ORDER BY 2 DESC;

--MONTHLY FLIGHT VOLUMES AND CANCELLATION RATES
SELECT
month,
COUNT(*) AS total_flights,
SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS cancelled_flights,
ROUND(SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_percentage
FROM flights_delay
GROUP BY month
ORDER BY month;


--TIME OF DAY ANALYSIS- DEPARTURE DELAY BY HOUR
SELECT
EXTRACT(HOUR FROM scheduled_departure_time) AS departure_hour,
ROUND(AVG(departure_delay), 2) AS avg_departure_delay
FROM flights_delay
WHERE cancelled = 0
GROUP BY departure_hour
ORDER BY departure_hour;


select *from flights_delay;


select *from flights_cleaned_view;


--JOINS
SELECT
    fd.flight_number,
    fd.airline AS airline_code,
    al.airline_name,
    fd.origin_airport AS origin_code,
    ap1.airport_name AS origin_airport_name,
    fd.destination_airport AS destination_code,
    ap2.airport_name AS destination_airport_name,
    fd.departure_delay,
    fd.arrival_delay,
    fd.cancellation_reason
FROM flights_delay fd
JOIN airlines al
    ON fd.airline = al.iata_code
JOIN airports ap1
    ON fd.origin_airport = ap1.iata_code
JOIN airports ap2
    ON fd.destination_airport = ap2.iata_code;

--TOTAL FLIGHTS PER AIRLINE
SELECT 
al.airline_name, 
COUNT(*) AS total_flights
FROM flights_delay fd
JOIN airlines al ON fd.airline = al.iata_code
GROUP BY al.airline_name;

--AIRPORT WITH HIGHTEST DEPARTURE DELAYS
SELECT 
ap.airport_name, 
AVG(fd.departure_delay) AS avg_departure_delay
FROM flights_delay fd
JOIN airports ap ON fd.origin_airport = ap.iata_code
GROUP BY ap.airport_name
ORDER BY avg_departure_delay DESC
LIMIT 5;

--FLIGHTS CANCELLED DUE TO WEATHER (REASON 'B')
SELECT 
fd.flight_number, 
fd.cancellation_reason
FROM flights_delay fd
WHERE fd.cancellation_reason = 'B'


--ON TIME PERFORMANCE (FLIGHTS WITH ARRIVAL DELAY <=15MINS)
SELECT 
COUNT(*) AS on_time_flights
FROM flights_delay
WHERE arrival_delay <= 15;

--TOP 5 AIRLINES WITH HIGHTEST AVERAGE DELAY
SELECT 
al.airline_name, 
AVG(fd.arrival_delay) AS avg_arrival_delay
FROM flights_delay fd
JOIN airlines al ON fd.airline = al.iata_code
GROUP BY al.airline_name
ORDER BY avg_arrival_delay DESC
LIMIT 5;