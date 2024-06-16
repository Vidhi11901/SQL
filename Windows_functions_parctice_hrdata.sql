use hr_data;

-- [1] IDENTIFY THE DETAILS OF EMPLOYEES WHO ARE PART OF DEPARTMENTS WITH MORE THAN 10 MEMBERS
--  (USE TABLES- EMPLOYEES AND DEPARTMENTS)
Select * 
from
     (
       Select e.employee_id,
       e.first_name,
       e.last_name,
       d.department_name,
	   count(*) over(partition by e.department_id) as total_count_department
from employees e inner join departments d using(department_id)) as Total_count
where total_count_department > 10;

-- [2] FIND THE DETAILS OF EMPLOYEES AND THE THEIR DEPARTMENT NAMES WHOSE COMBINED SALARY OF THE DEPARTMENT 
-- IS LESS THAN 100000
-- (USE TABLES- EMPLOYEES AND DEPARTMENTS)
Select * 
from
(Select e.employee_id,
	e.first_name,
    d.department_name,
    e.salary,
    sum(salary) over (partition by e.department_id) as Total_dept_salary
from employees e inner join departments d using(department_id)) as Total_salary
where Total_dept_salary<100000;

-- [3] FIND THE DETAILS OF EMPLOYEES AND THEIR DEPARTMENT NAMES WHOSE AVERAGE SALARY OF THE 
-- DEPARTMENT RANGES BETWEEN  5000 AND 8000.
--     (USE TABLES- EMPLOYEES AND DEPARTMENTS)

Select *    
from
(Select e.employee_id,
	e.first_name,
    d.department_name,
    e.salary,
    avg(salary) over (partition by e.department_id) as Avg_dept_salary
from employees e inner join departments d using(department_id)) as Avg_salary
where Avg_dept_salary between 5000 and 8000;

-- [4] CREATE NEW EMPLOYEE ID'S STARTING WITH DEPARTMENT ID FOLLOWED BY NEW NUMBER 
--  (USE TABLES- EMPLOYEES)

Select employee_id as old_id,
       first_name,
       department_name,
       department_id,
       concat(department_id,'-',id) as new_id from
(Select e.employee_id,
       e.first_name,
       d.department_id,
       d.department_name,
       row_number() over (partition by e.department_id) as id
from employees e inner join departments d using(department_id)) as temp;

-- [5]  FIND THE DETAILS OF TOP 3 SALARIES OF ALL THE EMPLOYEES IN EACH DEPARTMENT
--  (USE TABLES- EMPLOYEES & DEPARTMENTS) 

Select * from (
Select e.employee_id,
	e.first_name,
    e.salary,
    d.department_name,
    rank() over(partition by d.department_id order by e.salary desc) as rnk
from employees e inner join departments d using(department_id)) as Salary_rank
where rnk<=3;

Select * from (
Select e.employee_id,
	e.first_name,
    e.salary,
    d.department_name,
    dense_rank() over(partition by d.department_id order by e.salary desc) as rnk
from employees e inner join departments d using(department_id)) as Salary_rank
where rnk<=3;

-- [6] ASSIGN ALL THE EMPLOYEES WORKING IN THE SHIPPING DEPARTMENT TO THREE DIFFERENT TEAMS 
-- (USE TABLE- EMPLOYEES, DEPARTMENTS)

Select employee_id,
       first_name,
       department_name,
       ntile(3) over (order by employee_id) as teams
from       
(Select e.employee_id,
        e.first_name,
        d.department_name
from employees e inner join departments d using(department_id)    
where d.department_name = 'SHIPPING') as Shipping_dept;
    
-- [7] FIND THE NUMBER OF EMPLOYEES HIRED AND THE NUMBER OF EMPLOYEES FIRED EVERY MONTH
-- (USE TABLE- COMPANY_STRENGTH)

Select * from company_strength;

Select month_year as date,
       count_current_month,
       count_previous_month,
       case when hired > 0 then Hired else 0 end as Count_of_Hired,
       case when hired< 0 then Hired * -1 else 0 end as Count_of_Fired
from (       
Select month_year,
       employees as count_current_month,
       lag(employees) over (order by month_year) as count_previous_month,
       employees - (lag(employees) over (order by month_year)) as Hired
from company_strength) as cs;       
       
 -- [8]  FETCH THE EMPLOYEE ID , FULL NAME, SALARY, DEPARTMENT NAME AND MINIMUM SALARY IN THEIR DEPARTMENT
-- (USING TABLE- EMPLOYEES, DEPARTMENTS)

Select e.employee_id,
       concat(e.first_name," ",e.last_name) as Full_name,
       e.salary,
       d.department_name,
       First_value(salary) over (partition by d.department_name order by e.salary) as Min_salary
from employees e inner join departments d using(department_id);