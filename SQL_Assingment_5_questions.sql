-- Database: SQL_Assingment

-- DROP DATABASE IF EXISTS "SQL_Assingment";

-- 1. Given two tables below, write a query to display the comparison result (higher/lower/same) of the average salary of employees in a department to the company’s average salary.
create table salary (
id integer,
employee_id integer,
amount integer,
pay_date varchar (50))

drop table salary
show datestyle
set datestyle to ymd


select * from salary

insert into salary (id, employee_id, amount, pay_date)
values (1, 1, 9000, '2017-03-31'),
        (2, 2, 6000, '2017-03-31'),
		(3, 2, 10000, '2017-03-31'),
		(4, 1, 7000, '2017-02-28'),
		(5, 2, 6000, '2017-02-28'),
		(6, 2, 8000, '2017-02-28');
		
create table employee(employee_id integer, department_id integer)	

insert into employee(employee_id, department_id)
values (1, 1),
        (2,2),
		(3,2)
		
select * from employee		

--Explanation
--In March, the company's average salary is (9000+6000+10000)/3 = 8333.33...
--The average salary for department '1' is 9000, which is the salary of employee_id '1' since there is only one employee in this department. So the comparison result is 'higher' since 9000 > 8333.33 obviously.
--The average salary of department '2' is (6000 + 10000)/2 = 8000, which is the average of employee_id '2' and '3'. So the comparison result is 'lower' since 8000 < 8333.33.
--With he same formula for the average salary comparison in February, the result is 'same' since both the department '1' and '2' have the same average salary with the company, which is 7000.

		
SELECT d1.pay_month, d1.department_id,
CASE WHEN d1.department_avg > c1.company_avg THEN 'higher'
     WHEN d1.department_avg < c1.company_avg THEN 'lower'
     ELSE 'same'
END AS "comparison"
FROM ((SELECT LEFT(s1.pay_date, 7) pay_month, e1.department_id, AVG(s1.amount) department_avg
FROM salary s1
JOIN employee e1 ON s1.employee_id = e1.employee_id
GROUP BY pay_month, e1.department_id) d1
LEFT JOIN (SELECT LEFT(pay_date, 7) pay_month, AVG(amount) company_avg
FROM salary
GROUP BY pay_month) c1 ON d1.pay_month = c1.pay_month)
ORDER BY pay_month DESC, department_id;		


--2. Write an SQL query to report the students (student_id, student_name) being “quiet” in ALL exams. A “quiet” student is the one who took at least one exam and didn’t score neither the high score nor the low score.

create table student(student_id integer, student_name varchar (80))
insert into student(student_id,student_name)
values (1,'Daniel'),
        (2,'Jade'),
		(3,'Stella'),
		(4,'Jonathan'),
		(5,'Will')
		
select * from student	

create table Exam(examt_id integer, student_id integer, score integer) 
insert into Exam (examt_id , student_id , score)
values (10, 1, 70),
        (10, 2, 80),
		(10, 3, 90),
		(20, 1, 80),
		(30, 1, 70),
		(30, 3, 80),
        (30, 4, 90),
		(40, 1, 60),
		(40, 2, 70),
		(40, 4, 80);
		
select * from Exam	

select distinct Student.*
from Student inner join Exam
on Student.student_id = Exam.student_id
where student.student_id not in 
    (select e1.student_id
    from Exam as e1 inner join
        (select examt_id, min(score) as min_score, max(score) as max_score
        from Exam
        group by examt_id) as e2
    on e1.examt_id = e2.examt_id
    where e1.score = e2.min_score or e1.score = e2.max_score)
order by student_id


--3. Write a query to display the records which have 3 or
--more consecutive rows and the number of people more than 100(inclusive).
create table stadium(id integer, visit_date varchar (50), people integer)

insert into stadium (id,visit_date, people)
values (1,'2017-01-01',10),
        (2,'2017-01-02',109),
		(3,'2017-01-03',150),
		(4,'2017-01-04',99),
		(5,'2017-01-05',145),
		(6,'2017-01-06',1455),
		(7,'2017-01-07',199),
		(8,'2017-01-08',188);
		
select * from stadium		

select distinct day1.* 
from 
stadium day1, stadium day2, stadium day3
where 
day1.people >= 100 and day2.people >= 100 
and day3.people >= 100 and
((day1.id + 1 =  day2.id and day1.id + 2 = day3.id) or 
(day1.id - 1 = day2.id and day1.id + 1 = day3.id) or 
(day1.id - 2 = day2.id and day1.id - 1 = day3.id)) 
order by day1.id; 


--4. Write an SQL query to find how many users visited the bank and didn’t do any transactions, how many visited the bank and did one transaction and so on.
create table Visits (user_id integer, visit_date varchar (50))
insert into Visits(user_id,visit_date)
values (1,'2020-01-01'),
       (2,'2020-01-02'),
	   (12,'2020-01-01'),
	   (19,'2020-01-03'),
	   (1,'2020-01-02'),
	   (2,'2020-01-03'),
       (1,'2020-01-04'),
	   (7,'2020-01-11'),
	   (9,'2020-01-25'),
	   (8,'2020-01-28');
	   
select * from Visits	

create table Transactions(user_id integer, transaction_date varchar (50), amount integer)
insert into Transactions(user_id , transaction_date , amount)
values (1,'2020-01-02', 120),
       (2,'2020-01-03', 22),
	   (7,'2020-01-11', 232),
	   (1,'2020-01-04', 7),
	   (9,'2020-01-25', 33),
	   (9,'2020-01-25', 66),
	   (8,'2020-01-28', 1),
	   (9,'2020-01-25', 99);
	   
select * from Transactions	  

select *
from (select cast(t4.id as SIGNED) transactions_count, 
    case when t1.visits_count is null then 0 else t1.visits_count end as visits_count
from (select t.transactions_count, count(1) as visits_count
    from (
        select sum(case when transaction_date is null then 0 else 1 end) as transactions_count, count(1) as visits_count
        from Visits left join Transactions
        on Visits.user_id = Transactions.user_id
        and visit_date = transaction_date
        group by Visits.user_id, Visits.visit_date) as t
    group by t.transactions_count) as t1
        right join
        (select (@cnt1 := @cnt1+1) as id
        from Transactions cross join (select @cnt1 := -1) as dummy
         union select 0
            ) as t4
on t1.transactions_count = t4.id) as t5
where t5.transactions_count <= 
    (select 0 as cnt
     union 
     select count(1) as cnt
    from Transactions
    group by user_id, transaction_date
    order by cnt desc
    limit 1)
	
	
--5. Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019–01–01 to 2019–12–31.	
create table Failed(fail_date varchar (50))
insert into Failed (fail_date)
values ('2018-12-28'),
       ('2018-12-29'),
	   ('2019-01-04'),
	   ('2019-01-05');
	   
select * from Failed

create table Succeeded(succeeded_date varchar (50))
insert into Succeeded(succeeded_date)
values ('2018-12-30'),
       ('2018-12-31'),
	   ('2019-01-01'),
	   ('2019-01-02'),
	   ('2019-01-03'),
	   ('2019-01-06');
	   
select * from Succeeded

with cte as (select fail_date as cal_date, 'failed' as state
from Failed
union all
select succeeded_date as cal_date, 'succeeded' as state
from Succeeded)
select state as period_state,
       min(cal_date) as start_date,
       max(cal_date) as end_date
from
(select state, cal_date, rank() over (partition by state order by cal_date) as ranking, rank() over (order by cal_date) as id
from cte 
where cal_date between '2019-01-01' and '2019-12-31') t
group by state, (id - ranking)
order by 2

