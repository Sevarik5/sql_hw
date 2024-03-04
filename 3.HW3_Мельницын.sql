-- 1
select 
case when job_industry_category = 'n/a' then null else job_industry_category end as job_industry_category, 
count(customer_id) from public.customer
group by 1
order by 2 desc;

--2/ Исходим из того, что Null воспринимаем как отдельную сферу 
select 
extract(month from transaction_date) as month_transaction,
case when job_industry_category = 'n/a' then null else job_industry_category end as job_industry_category,
SUM(list_price) as sum_transaction
from public."transaction" t
	left join public.customer c on c.customer_id = t.customer_id 
group by 1, 2
order by 1 asc, 2 ASC
;

--3 | опять же исходим из того, что Null не убираем
select 
case when brand = '' then null else brand end as brand, 
COUNT(distinct transaction_id) count_trans from public."transaction" t
	left join public.customer c on c.customer_id = t.customer_id 
where job_industry_category = 'IT'
and order_status = 'Approved'
and online_order = 'True'
group by 1 
order by 2 desc;

--4.1/ надеюсь, что опечатка и сортировка по кол-ву транзакций
select customer_id,
sum(list_price) as sum_trans,
min(list_price) as min_trans,
max(list_price) as max_trans,
count(transaction_id) as count_trans

from public."transaction" t
group by 1
order by 2 desc, 5 desc;

-- 4.2 | Надеюсь, что идея была в том, что при окнах не надо далее уникализировать записи
select customer_id,
sum(list_price) over w as sum_trans,
min(list_price) over w  as min_trans,
max(list_price) over w as max_trans,
count(transaction_id) over w as count_trans

from public."transaction" t
window w as(partition by customer_id)
order by 2 desc, 5 desc;

--5.1
with t_max as
(select customer_id, SUM(list_price) as max_price from public."transaction" t
group by 1 
order by 2 desc
limit 1)

select first_name, last_name from public."transaction" t
	left join public.customer c on c.customer_id = t.customer_id 
group by 1, 2
having SUM(list_price) = (select max_price from t_max);

--5.2
with t_min as
(select customer_id, SUM(list_price) as min_price from public."transaction" t
group by 1 
order by 2 ASC
limit 1)

select first_name, last_name from public."transaction" t
	left join public.customer c on c.customer_id = t.customer_id 
group by 1, 2
having SUM(list_price) = (select min_price from t_min);

--6
with t1 AS(
select customer_id, transaction_date, 
dense_rank () over (partition by customer_id order by customer_id, transaction_date) as trans_number,
transaction_id 
from public."transaction")

select customer_id, transaction_id from t1
where trans_number = 1;

-- 7 
with t1 AS(
select customer_id , transaction_date,
LAG(transaction_date) over (partition by customer_id order by customer_id, transaction_date) as lag_trans,
transaction_date - LAG(transaction_date) over (partition by customer_id order by customer_id, transaction_date) as delta_lag
from public."transaction" t
order by 1, 2),

t2 AS(
select MAX(delta_lag) from t1)

select first_name, last_name, job_industry_category from t1
	left join public.customer c on c.customer_id = t1.customer_id
where delta_lag = (select * from t2)
