use hr_data;

-- FIRST, LET'S LOOK AT THE TABLES FOR EMPLOYEES AND DEPARTMENTS TO DETERMINE WHAT DATA WE NEED TO RETRIEVE
-- CHECK FOR ANY DUPLICATES

Select * from employees;
Select count(employee_id) from employees group by employee_id having count(employee_id)>1;

 -- Finding THE DETAILS OF EMPLOYEES WORKING IN THE IT & SHIPPING DEPARTMENT.
 
 Select e.employee_id,
        upper(e.first_name) as first_name,
        upper(e.last_name) as last_name,
        e.department_id,
        e.salary,
        d.department_name
from employees e inner join departments d using(department_id)
where d.department_name in ('IT', 'SHIPPING')
order by e.employee_id;

-- 2.) FIND THE NUMBER OF EMPLOYEES WORKING IN EACH DEPARTMENT, AS WELL AS THEIR AVERAGE SALARY.
-- (USE TABLES - EMPLOYEES, DEPARTMENTS)

Select d.department_id,
       d.department_name,
       count(e.employee_id) as number_of_employees,
       avg(e.salary) as average_salary
from departments d left join employees e using(department_id)
group by 1,2;

-- 3.) WRITE A SQL QUERY TO FIND ALL DEPARTMENTS, INCLUDING THOSE WITHOUT EMPLOYEES RETURN EMPLOYEE ID, 
-- FULLNAME, DEPARTMENT ID, DEPARTMENT NAME
-- (USE TABLES - EMPLOYEES, DEPARTMENTS)

Select e.employee_id,
       concat(e.first_name," ",e.last_name) as Full_name,
       d.department_id,
       d.department_name
from employees e right join departments d using(department_id)
where e.employee_id is null;

 -- 4.) FIND THE DETAILS OF EMPLOYEES WITH SALARY GREATER THAN 10000 ALONG WITH THEIR MANAGER'S FULLNAME   
-- (USE TABLE EMPLOYEES)

Select e.employee_id,
       concat(e.first_name," ",e.last_name) as employee_name,
       e.salary as employee_salary,
       concat(m.first_name," ",m.last_name) as Manager_name
from employees e join employees m on e.manager_id = m.employee_id
where e.salary > 10000;

-- 5.)  FIND ALL THE COLUMNS AND ROWS FROM BOTH EMPLOYEES AND DEPARTMENTS.

Select * from employees E left join departments d using(department_id)

UNION

Select * from employees E right join departments d using(department_id);


-- [6] FIND THE DETAILS OF EMPLOYEES IN SEATTLE WITH THEIR DEPARTMENT NAME ALONG WITH THE TOTAL AMOUNT
-- OF SALARY IN THAT DEPARTMENT 
-- JOINING MORE THAN 2 TABLES (USE TABLES- EMPLOYEES, DEPARTMENTS, LOCATIONS)
Select e.employee_id,
       concat(e.first_name," ",e.last_name) as Full_name,
       d.department_name,
       e.salary,
       l.city,
       l.state_province,
       ds.total_department_salary
from employees e inner join departments d using(department_id)
                 inner join locations l using(location_id)
                 inner join (SELECT 
            d.DEPARTMENT_ID,
            SUM(e.SALARY) AS TOTAL_DEPARTMENT_SALARY
        FROM 
            EMPLOYEES e
        JOIN 
            DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
        WHERE 
            d.LOCATION_ID = (SELECT LOCATION_ID FROM LOCATIONS WHERE CITY = 'Seattle')
        GROUP BY 
            d.DEPARTMENT_ID
    ) ds ON e.DEPARTMENT_ID = ds.DEPARTMENT_ID
where l.city = 'SEATTLE'
group by d.department_name,1
order by  sum(e.salary) desc;	                

