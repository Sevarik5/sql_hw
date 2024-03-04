--1
select distinct brand from public."transaction" t
where standard_cost > 1500;

--2
select * from public."transaction" t
where order_status = 'Approved'
and transaction_date between '2017-04-01' and '2017-04-09' ;

--3
select distinct job_title from public.customer c
where job_industry_category in ('IT', 'Financial Services')
and job_title like 'Senior%';

--4
select distinct brand  from public."transaction" t
	left join public.customer c on c.customer_id  = t.customer_id 
where job_industry_category = 'Financial Services';

--5
select first_name, last_name from public."transaction" t
	left join public.customer c on c.customer_id  = t.customer_id 
where brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
and online_order = True
group by 1, 2
having COUNT(distinct brand) = 3
limit 10;

--6
select c.customer_id, first_name, last_name from public.customer c
	left join public."transaction" t on c.customer_id  = t.customer_id 
where transaction_id is null;

--7
select c.customer_id, first_name, last_name from public.customer c
	left join public."transaction" t on c.customer_id  = t.customer_id 
where standard_cost = (select MAX(standard_cost) from public."transaction")
and job_industry_category = 'IT';

--8
select c.customer_id, first_name, last_name from public.customer c
	left join public."transaction" t on c.customer_id  = t.customer_id 
where job_industry_category in ('IT', 'Health')
and order_status = 'Approved' and transaction_date between '2017-07-07' and  '2017-07-17';

