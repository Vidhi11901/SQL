use hr_data;

 -- [1] WRITE A QUERY TO RETRIEVE THE DETAILS OF THE EMPLOYEES WHO WORK IN THE SALES DEPARTMENT
-- (USE TABLES- EMPLOYEES AND DEPARTMENTS)

Select * 
from employees
where department_id = (
Select department_id from departments where department_name = 'SALES');

-- or
Select e.employee_id,
       e.first_name,
       e.salary,
       d.department_name
from employees e inner join departments d using (department_id)
where department_name = 'SALES';

-- [2] WRITE A QUERY TO RETRIEVE WHICH DEPARTMENTS HAVE LESS THAN 10 EMPLOYEES.
--  GROUP THE RESULT SET ON CITY. RETURN CITY AND NUMBER OF DEPARTMENTS IN THAT CITY
-- (USE TABLES- DEPARTMENTS, LOCATIONS, EMPLOYEES)

select department_id
from employees
group by 1
having count(employee_id)<10;



Select l.city,
       count(d.department_id) as Count_of_dept
from locations l join departments d using(location_id)
where department_id in (select department_id
from employees
group by 1
having count(employee_id)<10)
group by 1;

 -- [3] WRITE SQL QUERY TO FETCH DETAILS OF EMPLOYEES WHOSE SALARY FALLS WITHIN THE 
-- RANGE OF AVERAGE SALARY AND 15000
-- (USE TABLE- EMPLOYEES)

Select * 
from employees 
where salary between (Select avg(salary) from employees) and 15000;

-- [4] 	FETCH THE DETAILS OF EMPLOYEES WHO GET SECOND HIGHEST SALARY
-- (USE TABLE - EMPLOYEES)

Select max(salary) as Highest_salary
from employees;

Select max(salary) as Second_highest
from employees
where salary < (Select max(salary) as Highest_salary
from employees);

Select * from employees where salary = (Select max(salary) as Second_highest
from employees
where salary < (Select max(salary) as Highest_salary
from employees));

-- [5] WRITE A QUERY TO DISPLAY THE NUMBER OF EMPLOYEES IN EACH SALARY BRACKET,
--     SHOW SALARY BRACKET OF EMPLOYEES AS PER BELOW CONDITIONS:
--           i) IF EMPLOYEE SALARY IS GREATER THAN OR EQUAL TO 15000 THEN 'TIER 1'
-- 			ii) IF EMPLOYEE SALARY IS BETWEEN 6500 AND 15000 THEN 'TIER 2'
--         iii) IF EMPLOYEE SALARY IS LESSER THAN OR EQUAL TO 6500 THEN 'TIER 3'

Select Salary_bracket,
       count(employee_id)
       from (
Select employee_id,
       salary,
       case when SALARY >= 15000 THEN 'TIER 1'
            when SALARY BETWEEN 6500 AND 15000 THEN 'TIER 2'
            when SALARY <=6500 THEN 'TIER 3'
            else salary
            end as Salary_bracket
from employees) as salary_data
group by 1;            

-- [6] WRITE A QUERY TO FIND THE DETAILS OF ALL THE MANAGERS BY RETURNING MANAGER_ID, MANAGER_NAME, SALARY 
-- AND THE SALARY BRACKET IN ACCORDANCE WITH THE CONDITIONS BELOW:
--           i) IF EMPLOYEE SALARY IS GREATER THAN OR EQUAL TO 15000 THEN 'TIER 1'
-- 			ii) IF EMPLOYEE SALARY IS BETWEEN 6500 AND 15000 THEN 'TIER 2'
--         iii) IF EMPLOYEE SALARY IS LESSER THAN OR EQUAL TO 6500 THEN 'TIER 3'

Select distinct manager_id
from employees;

Select manager_id,
       manager_name,
       manager_salary,
       case when manager_salary >= 15000 then 'Tier1'
            when manager_salary between 6500 and 15000 then 'Tier2'
            when manager_salary <= 6500 then 'Tier3'
            else manager_salary end as Salary_bracket
from (
Select employee_id as manager_id,
       concat(first_name," ",last_name) as Manager_name,
       salary as manager_salary
from employees
where employee_id in (Select distinct manager_id
from employees )) as MD;    

-- USING CTE

With MD as (Select employee_id as manager_id,
       concat(first_name," ",last_name) as Manager_name,
       salary as manager_salary
from employees
where employee_id in (Select distinct manager_id
from employees )) 
,
SB as (Select employee_id,
              Salary,
			case when salary >= 15000 then 'Tier1'
            when salary between 6500 and 15000 then 'Tier2'
            when salary <= 6500 then 'Tier3'
            else salary end as Salary_bracket
            from employees)
 Select MD.manager_id,
        MD.manager_name,
        MD.manager_salary,
        SB.Salary_bracket
from MD join SB on MD.manager_id = SB.employee_id;        