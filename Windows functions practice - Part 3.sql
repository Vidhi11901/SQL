 -- SQL Window Functions Practice Exercises: Online Movie Store
-- Dataset
-- The following exercises use the online movie store database, which contains six tables.

-- The customer table stores information on all registered customers. The columns are id, first_name, last_name, 
-- join_date, and country.

-- The movie table contains records of all movies available in the store. The columns are id, title, 
-- release_year, genre, and editor_ranking.

-- The review table stores customer ratings of the movies. The columns are id, rating, customer_id 
-- (references the customer table), and movie _id (references the movie table).

-- The single_rental table stores information about movies that were rented for a certain period of time by 
-- customers. The columns are id, rental_date, rental_period, platform, customer_id (references the customer table), 
-- movie _id (references the movie table), payment_date, and payment_amount.

-- The subscription table stores records for all customers who subscribed to the store. The columns are id, 
-- length (in days), start_date, platform, payment_date, payment_amount, and customer_id
-- (references the customer table).

-- The giftcard table contains information about purchased gift cards. The columns are id, amount_worth, 
-- customer_id (references the customer table), payment_date, and payment_amount.
 
 -- Ques1 Rank Rentals by Price
 -- For each single rental, show the rental_date, the title of the movie rented, its genre, the payment amount, 
 -- and the rank of the rental in terms of the price paid (the most expensive rental should have rank = 1). 
 -- The ranking should be created separately for each movie genre. Allow the same rank for multiple rows and 
 -- allow gaps in numbering.
 
 Select 
       rental_date,
       title,
       genre,
       payment_amount,
       rank()over(partition by genre order by price desc) as rantel_rank
 from single_rental s left join movie m on s.movie_id = m.id ;
 
 -- Ques 2: Find 2nd Giftcard-Purchasing Customer
 -- Show the first and last name of the customer who bought the second most-recent gift card, along with the date 
 -- when the payment took place. Assume that a unique rank is assigned for each gift card purchase.
 
 Select first_name,
 last_name,
 payment_date
 from
 (select first_name,
 last_name,
 payment_date,
 row_number()over(order by payment_date desc) as ranks
 from giftcard g join cutsomer c on g.customer_id=c.id)
 as ranking 
 where ranks = 2;
 
-- Ques3: Calculate Running Total for Payments
-- For each single rental, show the id, rental_date, payment_amount and the running total of payment_amounts of 
-- all rentals from the oldest one (in terms of rental_date) to the current row.
 
 Select id,
 rental_date,
 payment_amount,
 sum(payment_amount)over(order by rental_date)
 from single_rental
 order by rental_date;
 
 
 -- SQL Window Functions Practice Exercises: Health Clinic
 
 -- Dataset 2
-- The following exercises use a health clinic database that contains two tables.

-- The doctor table stores information about doctors. The columns are id, first_name, last_name, and age.

-- The procedure table contains information about procedures performed by doctors on patients. 
-- The columns are id, procedure_date, doctor_id (references the doctor table), patient_id, category,
-- name, price, and score.

-- Ques1 Calculate Moving Average for Scores
-- For each procedure, show the following information: procedure_date, doctor_id, category, name, score and the 
-- average score grom the procedures in the same category which are included in the following window frame: 
-- the two previous rows, the current row, and the three following rows in terms of the procedure date.

Select procedure_date,doctor_id,category,name,score,
avg(score) over (partition by category order by procedure_date rows between 2 preceding and 3 following) as Avg_score
from procedure_;

-- Ques2 Find the Difference Between Procedure Prices (2 solutions listed below)
-- For each procedure, show the following information: id, procedure_date, name, price, 
-- price of the previous procedure (in terms of the id) and the difference between these two values. 
-- Name the last two columns previous_price and difference.

with prev_price as (
select id, procedure_date, name, price,
lag(price) over(order by id) as previous_price
from procedure_)

select id,
procedure_date, 
name, 
price,
previous_price,
(price-previous_price) as difference
from prev_price;

-- or

select id,
procedure_date, 
name, 
price,
lag(price) over(order by id) as previous_price,
(price-previous_price) as difference
from procedure_;

-- Ques3 Find the Difference Between the Current and Best Prices
-- For each procedure, show the: procedure_date name price category
-- score
-- Price of the best procedure (in terms of the score) from the same category (column best_procedure).
-- Difference between this price and the best_procedure (column difference).

select procedure_date, name, category, score,
First_value(price) over(partition by category order by price desc) as best_procedure,
price- First_value(price) over(partition by category order by price desc) as difference
from procedure_;

-- Ques 7: Find the Best Doctor per Procedure
-- Find out which doctor is the best at each procedure. For each procedure, select the procedure name and the 
-- first and last name of all doctors who got high scores (higher than or equal to the average score for this 
-- procedure). Rank the doctors per procedure in terms of the number of times they performed this procedure. 
-- Then, show the best doctors for each procedure, i.e. those having a rank of 1.

with cte as (select name, 
first_name,
last_name,
count(*) as c,
rank()over(partition by name order by count(*) desc) as rank_
from procedure_ p join doctor d on p.doctor_id = d.id
where score>= (select avg(score)
               from procedure_ pl
               where pl.name = p.name)
)
select name, first_name, last_name
from cte 
where rank_ = 1;

-- SQL Window Functions Practice Exercises: Athletic Championships

-- Dataset
-- The following exercises use the athletic championships database that contains eight tables.

-- The competition table stores information about competitions. The columns are id, name, start_date, end_date, 
-- year, and location.

-- The discipline table stores information for all running disciplines (from the short-distance runs 
-- (e.g. the 100 meter) to the long-distance runs (e.g. the marathon)). The columns are id, name, is_men, and 
-- distance.

-- The event table stores information about the competition and discipline for each event. The columns are id, 
-- competition_id (references the competition table), and discipline_id (reference the discipline table).

-- The round table stores the rounds of each event. The columns are id, event_id (references the event table), 
-- round_name, round_number, and is_final.

-- The race table stores data for each race of each round. The columns are id, round_id (references the round table),
--  round_name (same as in the round table), race_number, race_date, is_final (same as in the round table), and wind.

-- The athlete table stores information about athletes participating in the competition. The columns are id, 
-- first_name, last_name, nationality_id (references the nationality table), and birth_date.

-- The nationality table stores information about athlete’s countries of origin. The columns are id, country_name, 
-- and country_abbr.

-- The result table stores information for all participants of a particular event. The columns are race_id 
-- (references the race table), athlete_id (references the athlete table), result, place, is_dsq, is_dns, and is_dnf.	
               
-- Ques 8: Calculate the Difference Between Daily Wind Speed Averages
-- For each date in which there was a race, display the race_date, the average wind on this date rounded to three 
-- decimal points, and the difference between the average wind speed  on this date and the average wind speed on 
-- the date before, also rounded to three decimal points. The columns should be named race_date, avg_wind, and 
-- avg_wind_delta.


select race_date,
avg(wind) over(order by race_date) as avg_wind,
lag (avg(wind) over(order by race_date)) over (order by race_date) as avg_wind_prev_day,
avg(wind) over(order by race_date) - lag (avg(wind) over(order by race_date)) over (order by race_date) as avg_wind_delta
from race;






