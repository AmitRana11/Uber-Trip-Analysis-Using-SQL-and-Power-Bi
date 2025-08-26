USE Uber_Trip_db


SELECT *FROM [Uber Trip Details]
SELECT *FROM [Location Table]

SELECT  COUNT(*) AS Total_Rows 
FROM [Uber Trip Details]

SELECT  COUNT(*) AS Total_Rows 
FROM  [Location Table]



 
-- Problems Queries

--1. Total Booking

 SELECT 
    '$' + CAST(CAST(COUNT([Trip_ID]) / 1000.0 AS DECIMAL(10,2)) AS VARCHAR(20)) + ' K' AS Total_Bookings
FROM [Uber Trip Details];


--2. Total Booking Value

SELECT 
    '$' + CAST(CAST(SUM(fare_amount + [Surge_Fee]) / 1000000 AS DECIMAL(10,2)) AS VARCHAR(20)) + ' M' 
    AS Total_Booking_Value
FROM [Uber Trip Details];

--3. Avg Booking Value

SELECT 
    '$' + CAST(CAST(AVG(fare_amount + [Surge_Fee]) AS DECIMAL(10,2)) AS VARCHAR(20)) 
    AS Avg_Booking_Value
FROM [Uber Trip Details];

--4. Total Trip Distance

SELECT CONCAT(CAST(SUM(trip_distance)/1000 AS decimal(10,2)), ' K miles') AS Total_Trip_Distance 
FROM [Uber Trip Details];

--5. Avg Trip Distance

SELECT CONCAT(CAST(AVG(trip_distance) AS decimal(10,2)), ' K miles') AS Avg_Trip_Distance 
FROM [Uber Trip Details];

--6. Avg Trip Time

SELECT 
    CAST(AVG(DATEDIFF(MINUTE, [Pickup_Time], [Drop_Off_Time])) AS DECIMAL(10,1)) AS Avg_Trip_Time_Minutes
FROM [Uber Trip Details];

--7. Total Booking by Payment Type

SELECT Payment_type, COUNT(Trip_ID) AS Total_Booking_by_Payment_Type
FROM [Uber Trip Details]
GROUP BY Payment_type
ORDER BY Total_Booking_by_Payment_Type DESC;

--8. Total Booking Value by Payment Type

SELECT 
    Payment_type, 
    '$ ' + CAST(CAST(SUM(fare_amount + [Surge_Fee]) AS DECIMAL(10,1)) AS VARCHAR(20)) AS Total_Booking_Value_by_Payment_Type
FROM [Uber Trip Details]
GROUP BY Payment_type
ORDER BY SUM(fare_amount + [Surge_Fee]) DESC;

--9. TOTAL BOOKING BY TRIP(DAY/NIGHT)

SELECT 
    CASE 
        WHEN DATEPART(HOUR, [Pickup_Time]) BETWEEN 6 AND 16 THEN 'Day'
        ELSE 'Night'
    END AS Trip_Shift,
    CAST(CAST(COUNT([Trip_ID]) * 100.0 / SUM(COUNT([Trip_ID])) OVER() AS DECIMAL(5,2)) AS VARCHAR(10)) + ' %' 
        AS Booking_Percentage
FROM [Uber Trip Details]
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, [Pickup_Time]) BETWEEN 6 AND 16 THEN 'Day'
        ELSE 'Night'
    END
ORDER BY Booking_Percentage DESC;


--10. TOTAL BOOKING VALUE BY TRIP(DAY/NIGHT)

SELECT 
    CASE
        WHEN DATEPART(HOUR,[Pickup_Time]) BETWEEN 6 AND 16 THEN 'Day'
        ELSE 'Night'
    END AS Trip_Shift,
    '$ ' + CAST(CAST(SUM(fare_amount + [Surge_Fee]) AS decimal(10,2)) AS VARCHAR(20)) AS Total_Booking_Value
FROM [Uber Trip Details]
GROUP BY 
     CASE
        WHEN DATEPART(HOUR,[Pickup_Time]) BETWEEN 6 AND 16 THEN 'Day'
        ELSE 'Night'
    END
ORDER BY Total_Booking_Value DESC ;

--11. Top 5 Pickup Locations by Total Bookings.

SELECT TOP 5 
    L.Location,
    COUNT(U.[Trip_ID]) AS Total_Bookings
FROM [Uber Trip Details] U
JOIN [Location Table] L 
    ON U.PULocationID = L.LocationID
GROUP BY L.Location
ORDER BY Total_Bookings DESC;

--12. Top 5 Drop Locations by Total Bookings.

SELECT TOP 5 
    L.Location ,
    COUNT(U.[Trip_ID]) AS Total_Bookings
FROM [Uber Trip Details] U
JOIN [Location Table] L 
    ON U.DOLocationID =L.LocationID
GROUP BY L.Location
ORDER BY Total_Bookings DESC;

--13. Top 5 Drop Locations by Revenue

SELECT TOP 5
    L.Location,
    '$ ' + CAST(CAST(SUM(U.fare_amount + U.Surge_Fee) AS DECIMAL(10,2)) AS VARCHAR(20)) AS Total_Revenue
FROM [Uber Trip Details] U
JOIN [Location Table] L 
    ON U.DOLocationID = L.LocationID
GROUP BY L.Location
ORDER BY SUM(U.fare_amount + U.Surge_Fee) DESC;

--14. Revenue Contribution by City (in %)

SELECT 
    L.City,
    CONCAT(
    CAST(
        (SUM(U.fare_amount + U.Surge_Fee) * 100.0) / 
        (SELECT SUM(fare_amount + Surge_Fee) FROM [Uber Trip Details])
        AS DECIMAL(5,2)
        ), ' %'
    ) AS Revenue_Contribution_Percentage
FROM [Uber Trip Details] U
JOIN [Location Table] L 
    ON U.DOLocationID = L.LocationID
GROUP BY L.City
ORDER BY Revenue_Contribution_Percentage DESC;

--15. Most Frequently Used Payment Type by Location

WITH PaymentCounts AS (
    SELECT 
        L.Location,
        U.Payment_type,
        COUNT(U.[Trip_ID]) AS Total_Bookings,
        ROW_NUMBER() OVER (PARTITION BY L.Location
                           ORDER BY COUNT(U.[Trip_ID]) DESC) AS rn
    FROM [Uber Trip Details] U
    JOIN [Location Table] L 
        ON U.PULocationID = L.LocationID
    GROUP BY L.Location, U.Payment_type
)
SELECT 
    Location,
    Payment_type AS Most_Used_Payment_Type,
    Total_Bookings
FROM PaymentCounts
WHERE rn = 1 
ORDER BY Total_Bookings DESC;

--16. Total Booking Hours of Days 

SELECT 
    DATEPART(HOUR, Pickup_Time) AS Booking_Hour,
    COUNT([Trip_ID]) AS Total_Bookings
FROM [Uber Trip Details]
GROUP BY DATEPART(HOUR, Pickup_Time)
ORDER BY Booking_Hour;

--17. Total Bookings by Day of Week

SELECT 
    DATENAME(WEEKDAY, Pickup_Time) AS Booking_Day,
    COUNT([Trip_ID]) AS Total_Bookings
FROM [Uber Trip Details]
GROUP BY DATENAME(WEEKDAY, Pickup_Time), DATEPART(WEEKDAY, Pickup_Time)
ORDER BY DATEPART(WEEKDAY, Pickup_Time);

--18. Average Fare per K miles

SELECT 
    CAST(SUM(fare_amount) / SUM(Trip_Distance) AS DECIMAL(10,2)) AS Avg_Fare_Per_KM
FROM [Uber Trip Details];

--19. Trips with Surge Pricing

SELECT 
    COUNT(CASE WHEN Surge_Fee > 0 THEN 1 END) AS Trips_With_Surge,
    COUNT(*) AS Total_Trips,
    CAST(
        (COUNT(CASE WHEN Surge_Fee > 0 THEN 1 END) * 100.0 / COUNT(*)) 
        AS DECIMAL(5,2)
    ) AS Surge_Percentage
FROM [Uber Trip Details];

--20. Highest Surge Fee Paid in a Trip

SELECT CONCAT('$ ',CAST(MAX(Surge_Fee)AS decimal(5,1))) AS Highest_Surge_Fee_Paid
FROM [Uber Trip Details];

--21.Top 10 Longest Trips by Distance

SELECT TOP 10
    Trip_ID,
    trip_distance,
    fare_amount,
    (fare_amount + Surge_Fee) AS Total_Fare,
    CAST(Pickup_Time AS DATE) AS Pickup_Date,
    CAST(Pickup_Time AS TIME) AS Pickup_Time,
    CAST(Drop_Off_Time AS DATE) AS Drop_Date,
    CAST(Drop_Off_Time AS TIME) AS Drop_Time
FROM [Uber Trip Details]
ORDER BY trip_distance DESC;

--22. Top 10 Longest Trips by Time

SELECT TOP 10
    Trip_ID,
    FORMAT(DATEADD(MINUTE, 330, Pickup_Time), 'HH:mm:yyyy') AS Pickup_Date_IST,
    FORMAT(DATEADD(MINUTE, 330, Drop_Off_Time), 'HH:mm:yyyy') AS Drop_Date_IST,
    DATEDIFF(MINUTE, Pickup_Time, Drop_Off_Time) AS Trip_Duration_Minutes,
    CAST(trip_distance AS DECIMAL(10,1)) AS Trip_Distance_Miles,
    CAST((fare_amount + Surge_Fee) AS DECIMAL(10,1)) AS Total_Fare
FROM [Uber Trip Details]
ORDER BY DATEDIFF(MINUTE, Pickup_Time, Drop_Off_Time) DESC;

--23. Bookings Distribution by Weekday vs Weekend

SELECT  
    CASE 
        WHEN DATEPART(WEEKDAY, Pickup_Time) IN (1, 7) THEN 'Weekend'   -- Sunday(1) & Saturday(7)
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(Trip_ID) AS Total_Bookings,
    CONCAT(CAST(ROUND(COUNT(Trip_ID) * 100.0 / SUM(COUNT(Trip_ID)) OVER(), 1) AS DECIMAL(5,1)), '%') 
        AS Booking_Percentage
FROM [Uber Trip Details]
GROUP BY 
    CASE 
        WHEN DATEPART(WEEKDAY, Pickup_Time) IN (1, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END;

 --24. Weekday vs Weekend – Average Revenue per Trip:

SELECT  
   CASE 
       WHEN DATEPART(WEEKDAY, Pickup_Time) IN (1, 7) THEN 'Weekend'   -- Sunday(1), Saturday(7)
       ELSE 'Weekday'
    END AS Day_Type,
    COUNT(Trip_ID) AS Total_Trips,
    CONCAT('$ ',CAST(SUM(fare_amount + Surge_Fee) AS DECIMAL(10,2))) AS Total_Revenue,
    CAST(AVG(fare_amount + Surge_Fee) AS DECIMAL(10,2)) AS Avg_Revenue_Per_Trip
FROM [Uber Trip Details]
GROUP BY 
    CASE 
        WHEN DATEPART(WEEKDAY, Pickup_Time) IN (1, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END;

--25.  Bookings per Vehicle Type

SELECT Vehicle,
    COUNT(Trip_ID) AS Total_Bookings,
    ROUND(COUNT(Trip_ID) * 100 / SUM(COUNT(Trip_ID)) OVER(),1)AS Booking_Percentages
FROM [Uber Trip Details]
GROUP BY Vehicle
ORDER BY Total_Bookings DESC;

--26.  Total Trip Distance by Vehicle Type

SELECT  
    Vehicle,  
    CONCAT(CAST(SUM(trip_distance) AS DECIMAL(10,1)), ' K miles') AS Total_Trip_Distance  
FROM [Uber Trip Details]  
GROUP BY Vehicle 
ORDER BY SUM(trip_distance) DESC;

--27. Top 5 Locations Generating Highest Revenue

SELECT TOP 5 
    L.Location,
    CONCAT('$ ', CAST(SUM(U.fare_amount + U.Surge_Fee) AS DECIMAL(10,1))) AS Total_Revenues
FROM [Uber Trip Details] U
JOIN [Location Table] L
    ON U.PULocationID = L.LocationID
GROUP BY L.Location
ORDER BY SUM(U.fare_amount + U.Surge_Fee) DESC;

--28 Top 5 Peak Hours by Bookings Count.

SELECT TOP 5  
    DATEPART(HOUR, Pickup_Time) AS Pickup_Hour,  
    COUNT(Trip_ID) AS Total_Bookings  
FROM [Uber Trip Details]  
GROUP BY DATEPART(HOUR, Pickup_Time)  
ORDER BY Total_Bookings DESC;

--29. Calculate Average Speed per Trip (Distance / Time)

SELECT  
    Trip_ID,  
    CAST(trip_distance / NULLIF(DATEDIFF(MINUTE, Pickup_Time, Drop_Off_Time) / 60.0, 0) AS DECIMAL(10,2)) AS Avg_Speed_MPH  
FROM [Uber Trip Details]  
ORDER BY Avg_Speed_MPH DESC;

--30. Top 3 Cites Generating Highest Revenue

SELECT TOP 3
    L.City,
    CONCAT('$ ', CAST(SUM(U.fare_amount + U.Surge_Fee) AS DECIMAL(10,1))) AS Total_Revenues
FROM [Uber Trip Details] U
JOIN [Location Table] L
    ON U.PULocationID = L.LocationID
GROUP BY L.City
ORDER BY SUM(U.fare_amount + U.Surge_Fee) DESC;



SELECT *FROM [Uber Trip Details]
SELECT *FROM [Location Table]