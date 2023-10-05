/*
NAME: AISHWARYA HEMANTKUMAR PATEL

Assigment-1

*/
---*query1*-----------------------------------------------------------------------------------------------------------------------



WITH Table1 as
(
	SELECT cust, min(quant) as MIN_Q, max(quant) as MAX_Q ,avg(quant) as AVG_Q
	FROM sales
	GROUP BY cust ORDER BY cust 
),
minimum as
(
	SELECT t1.cust, MIN_Q, s1.prod, s1.day, s1.month, s1.year, s1.state
	FROM Table1 t1, sales s1
	WHERE t1.cust = s1.cust and MIN_Q = s1.quant
),
maximum as
(
	SELECT t2.cust, MAX_Q, s2.prod, s2.day, s2.month, s2.year, s2.state
	FROM Table1 t2, sales s2
	WHERE t2.cust = s2.cust and MAX_Q = s2.quant
)
SELECT t3.cust as CUSTOMER, t3.MIN_Q, min.prod as MIN_PROD, 
concat(min.month,'/',min.day,'/',min.year) as MIN_DATE, min.state as ST, t3.MAX_Q, max.prod as MAX_PROD, 
concat(max.month,'/',max.day,'/',max.year) as MAX_DATE, max.state as ST, round(t3.AVG_Q) as Avg_Q
FROM minimum as min, maximum as max, Table1 as t3
WHERE min.cust = max.cust and min.cust = t3.cust and max.cust = t3.cust;




--*query2*--------------------------------------------------------------------------------------------------------------------------



WITH Table2 As (
	select year,month,day,sum(quant)as sum_q
	from sales 
	group by year,month,day order by year,month),

MAX_MIN As (
	SELECT min(sum_q) as SLOWEST_TOTAL_Q,max(sum_q)As BUSIEST_TOTAL_Q,year,month
	from Table2
	group by year,month order by year,month),

MAXIMUM As(
	SELECT MAX_MIN.year,MAX_MIN.month,MAX_MIN.SLOWEST_TOTAL_Q,MAX_MIN.BUSIEST_TOTAL_Q,Table2.day as BUSIEST_DAY
	from MAX_MIN, Table2
	where MAX_MIN.year=Table2.year and 	MAX_MIN.month=Table2.month and Table2.sum_q=MAX_MIN.BUSIEST_TOTAL_Q)

	SELECT  MAXIMUM.year,MAXIMUM.month,Table2.day as SLOWEST_DAY,MAXIMUM.SLOWEST_TOTAL_Q, MAXIMUM.BUSIEST_DAY,MAXIMUM.BUSIEST_TOTAL_Q
	from MAXIMUM, Table2
	where MAXIMUM.year=Table2.year and MAXIMUM.month=Table2.month and MAXIMUM.SLOWEST_TOTAL_Q=Table2.sum_q
	order by MAXIMUM.year,MAXIMUM.month;



---*query3*-----------------------------------------------------------------------------------------------------------------------------------



WITH T3 AS
		(SELECT cust,month,prod,SUM(quant)AS T_Sum_q
		FROM sales
		GROUP BY cust,month,prod ORDER BY cust,month,prod),
Q1 AS
	    (SELECT cust,month,MAX(T_Sum_q) AS MAX_F
		FROM T3
		GROUP BY cust,month ORDER by cust,month),
Q2 AS
		(SELECT cust,month,MIN(T_Sum_q) AS MIN_F
		FROM T3
		GROUP BY cust,month ORDER BY cust,month),
MOST_FAV AS
		(SELECT T3.cust,T3.month,T3.prod
		FROM T3
		JOIN Q1 AS A1 ON T3.cust = A1.cust
		AND T3.month = A1.month
		AND T3.T_Sum_q = A1.MAX_F),
LEAST_FAV AS
		(SELECT T3.cust,T3.month,T3.prod
		FROM T3
		JOIN Q2 AS A2 ON T3.cust = A2.cust
		AND T3.month = A2.month
		AND T3.T_Sum_q = A2.MIN_F)

		SELECT m1.cust AS CUSTOMER,
		m1.month,m1.prod AS MOST_FAV_PROD,
		l1.prod AS LEAST_FAV_PROD
		FROM MOST_FAV AS m1
		JOIN LEAST_FAV AS l1 ON m1.cust = l1.cust
		AND m1.month = l1.month;


---*query4*------------------------------------------------------------------------------------------------------------------------------------------



With Table4 AS
			(SELECT cust,prod, AVG(quant),COUNT(quant),SUM(quant) 
 			 FROM sales 
 			 GROUP BY cust, prod),

Q1 AS
			(SELECT cust,prod,AVG(quant) AS avg1 
			 FROM sales 
 			 WHERE month in ('1','2','3') GROUP BY cust, prod),

Q2 AS
			(SELECT cust,prod,AVG(quant) AS avg2
 			 FROM sales 
 			 WHERE month in ('4','5','6') GROUP BY cust, prod),

Q3 AS
			(SELECT cust,prod,AVG(quant) AS avg3
			 FROM sales 
 			 WHERE month in ('7','8','9') GROUP BY cust, prod),

Q4 AS
			(SELECT cust,prod,AVG(quant) AS avg4
 			 FROM sales 
 			 WHERE month in ('10','11','12') GROUP BY cust, prod)

      		SELECT Table4.cust AS CUSTOMER,Table4.prod AS PRODUCT,
	   		Round(Q1.avg1,0) AS Q1_AVG,Round(Q2.avg2,0) AS Q2_AVG,
	   		Round(Q3.avg3,0) AS Q3_AVG,Round(Q4.avg4,0) AS Q4_AVG,
	   		Round(Table4.avg,0) AS AVERAGE,Table4.sum AS TOTAL,
	   		Table4.count AS COUNT
			
	  		 FROM Table4 left join Q1 on Q1.cust=Table4.cust AND Q1.prod=Table4.prod
	   		 left join Q2 on Q2.cust=Table4.cust AND Q2.prod=Table4.prod
	   		 left join Q3 on Q3.cust=Table4.cust AND Q3.prod=Table4.prod
	   		 left join Q4 on Q4.cust=Table4.cust AND Q4.prod=Table4.prod





----*query5-------------------------------------------------------------------------------------------------------------------------------------------------



WITH Q1 AS (
        SELECT prod,date,quant
        FROM sales
        WHERE month between 1 and 3
),
Q1_maximum_q AS (
        SELECT prod,max(quant) AS Q1_MAX
        FROM Q1
        GROUP BY prod ORDER BY prod
),
Q2 AS (
        SELECT prod,date,quant
        FROM sales
        WHERE month between 4 and 5
),
Q2_maximum_q AS (
        SELECT prod,max(quant) AS Q2_MAX
        FROM Q2
        GROUP BY prod ORDER BY prod
),
Q3 AS (
        SELECT prod,date,quant
        FROM sales
        WHERE month between 6 and 9
),
Q3_maximum_q AS (
        SELECT prod,max(quant) AS Q3_MAX
        FROM Q3
        GROUP BY prod ORDER BY prod
),
Q4 AS (
        SELECT prod,date,quant
        FROM sales
        WHERE month between 10 and 12
),
Q4_maximum_q AS (
        SELECT prod,max(quant) AS Q4_MAX
        FROM Q4
        GROUP BY prod ORDER BY prod
),
Temp1 AS (
        SELECT Q1_maximum_q.prod,Q1_maximum_q.Q1_MAX,Q1.date
        FROM Q1_maximum_q
        JOIN Q1 ON Q1_maximum_q.prod = Q1.prod
        AND Q1_maximum_q.Q1_MAX = Q1.quant
),
Temp2 AS (
        SELECT Q2_maximum_q.prod,Q2_maximum_q.Q2_MAX,Q2.date
        FROM Q2_maximum_q
        JOIN Q2 ON Q2_maximum_q.prod = Q2.prod
		AND Q2_maximum_q.Q2_MAX = Q2.quant
),
Temp3 AS (
        SELECT Q3_maximum_q.prod,Q3_maximum_q.Q3_MAX,Q3.date
        FROM Q3_maximum_q
        JOIN Q3 ON Q3_maximum_q.prod = Q3.prod
		AND Q3_maximum_q.Q3_MAX = Q3.quant
),
Temp4 AS (
        SELECT Q4_maximum_q.prod,Q4_maximum_q.Q4_MAX,Q4.date
        FROM Q4_maximum_q
        JOIN Q4 ON Q4_maximum_q.prod = Q4.prod
		AND Q4_maximum_q.Q4_MAX = Q4.quant
)
SELECT Temp4.prod,Temp1.Q1_MAX,Temp1.date,Temp2.Q2_MAX,Temp2.date,Temp3.Q3_MAX,Temp3.date,Temp4.Q4_MAX,Temp4.date
FROM Temp4
JOIN Temp3 ON Temp4.prod = Temp3.prod
JOIN Temp2 ON Temp4.prod = Temp2.prod
JOIN Temp1 ON Temp4.prod = Temp1.prod
ORDER BY prod;