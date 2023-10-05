/*NAME: AISHWARYA PATEL
Assignment-2
561-B 
*/

--QUERY 1--------------------------------------------------------------------------------------------------------------------------------------------------


with Table1 as
			(select cust,prod,month
 			from sales
 			group by cust,prod,month
 			order by cust,prod,month),

 Table2 as
 		(select t2.cust,t2.prod,t2.month, round(avg(quant)) as next
 		 from Table1 as t2, sales as s1
 		 where t2.prod=s1.prod
 		 and t2.month=s1.month+1
 		 and t2.cust=s1.cust
 		 group by t2.cust,t2.prod,t2.month
 		 order by t2.cust,t2.prod,t2.month),

 Table3 as
 		(select t3.cust,t3.prod,t3.month, round(avg(quant)) as previous
 		from Table1 as t3, sales as s2
  		where t3.prod=s2.prod
  		and t3.month=s2.month-1
  		and t3.cust=s2.cust
  		group by t3.cust,t3.prod,t3.month
  		order by t3.cust,t3.prod,t3.month),

Table4 as(
	  	select Table2.cust,Table2.prod,Table2.month,previous,next
	  	from Table2 natural join Table3
),

Table5 as
	(select s3.cust as customer,s3.prod as product, s3.month, count(quant) as sales_count
	from Table4,sales s3
	where ((s3.quant between previous and next) or (s3.quant between next and previous) )
	and Table4.cust=s3.cust and Table4.prod=s3.prod and Table4.month=s3.month
	group by s3.cust,s3.prod,s3.month
	order by s3.cust,s3.prod,s3.month)

select Table1.cust as "CUSTOMER",Table1.prod as "PRODUCT", Table1.month as "MONTH", sales_count AS "SALES_COUNT_BETWEEN_AVGS"
from Table1 left join Table5 on
Table5.customer=Table1.cust and Table5.product=Table1.prod and Table5.month=Table1.month
order by Table1.cust,Table1.prod,Table1.month







--Query 2-------------------------------------------------------------------------------------------------------------------------------------------------




WITH Table1 AS
(
	SELECT cust, prod, month, round(avg(quant),0) AS AVG
	FROM sales
	GROUP BY cust, prod, month
	Order BY cust, prod, month

), 

Table2 AS 
(
	SELECT t1.cust, t1.prod, t2.month, t1.AVG AS BEFORE_AVG
	FROM Table1 t1, Table1 t2
	WHERE t1.cust = t2.cust AND t1.prod = t2.prod AND t1.month = t2.month-1
	
),

Table3 AS 
(
	SELECT t1.cust, t1.prod, t2.month, t1.AVG AS DURING_AVG
	FROM Table1 t1, Table1 t2
	WHERE t1.cust = t2.cust AND t1.prod = t2.prod AND t1.month = t2.month
	
), 
Table4 AS 
(
	SELECT t1.cust, t1.prod, t2.month, t1.AVG AS AFTER_AVG
	FROM Table1 t1, Table1 t2
	WHERE t1.cust = t2.cust AND t1.prod = t2.prod AND t1.month = t2.month+1

), 

bresult AS 
(
	SELECT TA1.cust, TA1.prod, TA1.month, BEFORE_AVG
	FROM Table1 TA1 LEFT JOIN Table2 B
	ON TA1.cust = B.cust AND TA1.prod = B.prod AND TA1.month = B.month
), 

dresult AS 
(
	SELECT TA1.cust, TA1.prod, TA1.month, DURING_AVG
	FROM Table1 TA1 LEFT JOIN Table3 D
	ON TA1.cust = D.cust AND TA1.prod = D.prod AND TA1.month = D.month
),

aresult AS 
(
	SELECT TA1.cust, TA1.prod, TA1.month, AFTER_AVG
	FROM Table1 TA1 LEFT JOIN Table4 A
	ON TA1.cust = A.cust AND TA1.prod = A.prod AND TA1.month = A.month
)


SELECT B.cust AS "CUSTOMER", B.prod AS "PRODUCT", B.month AS "MONTH", BEFORE_AVG AS "BEFORE_AVG", DURING_AVG AS "DURING_AVG", AFTER_AVG AS "AFTER_AVG"
FROM bresult B, aresult A, dresult D
WHERE B.cust = A.cust AND B.prod = A.prod AND B.month = A.month
AND B.cust = D.cust AND B.prod = D.prod AND B.month = D.MONTH





--QUERY3--------------------------------------------------------------------------------------------------------------------------------------------------







with TABLE1 as
    	(select cust, prod, st.state, round(
        (select avg(s1.quant)
        from sales s1
        where s1.cust=s.cust and s1.prod=s.prod and s1.state=st.state),0) as prod_avg
        from sales s, (select distinct state
        from sales) st
        group by cust, prod, st.state
    ),

TABLE2 as
    (
        select t1.cust, t1.prod, t1.state, t1.prod_avg, round(avg(s.quant),0) as  other_cust_avg
        from TABLE1 as t1, sales as s
        where t1.cust != s.cust and t1.prod = s.prod and t1.state = s.state
        group by t1.cust, t1.prod, t1.state, t1.prod_avg
    ),

TABLE3 as
    (
        select t1.cust, t1.prod, t1.state, t1.prod_avg, round(avg(s.quant),0) as other_prod_avg
        from TABLE1 as t1, sales as s
        where t1.cust = s.cust and t1.state = s.state and t1.prod != s.prod
        group by t1.cust, t1.prod, t1.state, t1.prod_avg
    ),
TABLE4 as
	(select t1.cust,t1.prod,t1.state,t1.prod_avg,round(avg(s.quant),0) as other_state_avg
	 from TABLE1 as t1,sales as s
	 where t1.cust=s.cust and t1.prod=s.prod and t1.state!=s.state
	 group by t1.cust, t1.prod, t1.state, t1.prod_avg
	)

select t1.cust as "CUSTOMER", t1.prod as "PRODUCT", t1.state as "STATE", t1.prod_avg as "PROD_AVG", t2.other_cust_avg as "OTHER_CUST_AVG", t3.other_prod_avg as "OTHER_PROD_AVG", t4.other_state_avg
from (TABLE1 as t1 full outer join TABLE2 as t2 on t1.cust=t2.cust and t1.prod=t2.prod and t1.state=t2.state) 
full outer join TABLE3 as t3 on t1.cust=t3.cust and t1.prod=t3.prod and t1.state=t3.state full outer join TABLE4 as t4 on t1.cust=t4.cust and t1.prod=t4.prod and t1.state=t4.state
order by t1.cust,t1.prod,t1.state


							



--QUERY 4---------------------------------------------------------------------------------------------------------------------------------------------------



WITH NJState AS (
	SELECT cust,quant,prod,date
	FROM sales
	WHERE state = 'NJ'
)
	SELECT *
	FROM
	NJState AS n
	WHERE (cust, quant) IN (SELECT cust,quant
	FROM NJState
	WHERE cust = n.cust
	GROUP BY cust,quant
	ORDER BY cust,quant DESC
	LIMIT 3)
ORDER BY
	cust,
	quant DESC;



--QUERY 5----------------------------------------------------------------------------------------------------------------------------------------


WITH
	TABLE1
	AS
	(
		SELECT cust, prod, month, sum(quant) as monthly
		FROM sales
		GROUP BY cust, prod, month

	),
	TOTAL_SALES
	AS
	(
		SELECT t1.cust, t1.prod, t1.month, sum(t2.monthly) as total
		FROM TABLE1 t1, TABLE1 t2
		WHERE t1.cust = t2.cust AND t1.prod = t2.prod AND t1.month >= t2.month
		GROUP BY t1.cust, t1.prod, t1.month

	),
	ONE_THIRD
	AS
	(
		SELECT cust, prod, round(sum(monthly)/3,0) as onethird
		FROM TABLE1
		GROUP BY cust, prod
	)

SELECT t1.cust as "CUSTOMER", t1.prod as "PRODUCT", min(t1.month) as "1/3 PURCHASED BY MONTH"
FROM TOTAL_SALES t1, ONE_THIRD t2
WHERE t1.cust = t2.cust AND t1.prod = t2.prod AND total >= onethird
GROUP BY t1.cust, t1.prod