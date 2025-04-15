-- Using Common Table Expressions (CTE)
-- A CTE allows you to define a subquery block that can be referenced within the main query. 
-- It is particularly useful for recursive queries or queries that require referencing a higher level.

-- Practice Question - 1
CREATE TABLE famous (user_id INT, follower_id INT);

INSERT INTO famous VALUES
(1, 2), 
(1, 3), 
(2, 4), 
(5, 1), 
(5, 3), 
(11, 7), 
(12, 8), 
(13, 5), 
(13, 10), 
(14, 12), 
(14, 3), 
(15, 14), 
(15, 13);

-- find the famous percentage of each user. 
-- Famous Percentage = number of followers a user has / total number of users on the platform.

with distinct_users as
(
select user_id as users from famous
union
select follower_id as users from famous
),
followers_count as
(
select user_id, count(follower_id) as followers
from famous
group by user_id
)
select f.user_id, (f.followers * 100) / (select count(*) from distinct_users) as followers_percentage
from followers_count as f;


-- Practice Question - 2
CREATE TABLE sf_transactions(id INT, created_at date, value INT, purchase_id INT);
drop table sf_transactions;
INSERT INTO sf_transactions VALUES
(1, '2019-01-01',  172692, 43), 
(2, '2019-01-05',  177194, 36),
(3, '2019-01-09 00:00:00',  109513, 30),
(4, '2019-01-13 00:00:00',  164911, 30),
(5, '2019-01-17 00:00:00',  198872, 39),
(6, '2019-01-21 00:00:00',  184853, 31),
(7, '2019-01-25 00:00:00',  186817, 26), 
(8, '2019-01-29 00:00:00',  137784, 22),
(9, '2019-02-02 00:00:00',  140032, 25), 
(10, '2019-02-06 00:00:00', 116948, 43), 
(11, '2019-02-10 00:00:00', 162515, 25), 
(12, '2019-02-14 00:00:00', 114256, 12), 
(13, '2019-02-18 00:00:00', 197465, 48), 
(14, '2019-02-22 00:00:00', 120741, 20), 
(15, '2019-02-26 00:00:00', 100074, 49), 
(16, '2019-03-02 00:00:00', 157548, 19), 
(17, '2019-03-06 00:00:00', 105506, 16), 
(18, '2019-03-10 00:00:00', 189351, 46), 
(19, '2019-03-14 00:00:00', 191231, 29), 
(20, '2019-03-18 00:00:00', 120575, 44), 
(21, '2019-03-22 00:00:00', 151688, 47), 
(22, '2019-03-26 00:00:00', 102327, 18), 
(23, '2019-03-30 00:00:00', 156147, 25);
select * from sf_transactions;

-- The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, 
-- and sorted from the beginning of the year to the end of the year. The percentage change column will be populated 
-- from the 2nd month forward and calculated as ((this month’s revenue — last month’s revenue) / last month’s revenue)*100.
with Monthly_Revenue as
(
select 
	   date_format(created_at, '%Y-%m') as year_months,
	   sum(value) as total_revenue
from 
	   sf_transactions
group by 
	   date_format(created_at, '%Y-%m')
),
RevenueChange as
(
select 
	   year_months, 
	   total_revenue,
       lag(total_revenue) over(order by year_months) as previous_revenue
from
	   Monthly_Revenue
)
select 
	   year_months, 
	   total_revenue,
       round(
			case
				when previous_revenue is null then null
                else ((total_revenue - previous_revenue) / cast(previous_revenue as float)) * 100
			end, 2
            ) as percentage_change
from
	   RevenueChange
order by
	   year_months;


-- Practice Question - 3
CREATE TABLE users(user_id INT, user_name varchar(30));
INSERT INTO users VALUES 
(1, 'Karl'), 
(2, 'Hans'), 
(3, 'Emma'), 
(4, 'Emma'), 
(5, 'Mike'), 
(6, 'Lucas'), 
(7, 'Sarah'), 
(8, 'Lucas'), 
(9, 'Anna'), 
(10, 'John');

CREATE TABLE friends(user_id INT, friend_id INT);
INSERT INTO friends VALUES 
(1,3),
(1,5),
(2,3),
(2,4),
(3,1),
(3,2),
(3,6),
(4,7),
(5,8),
(6,9),
(7,10),
(8,6),
(9,10),
(10,7),
(10,9);

-- find mutual friends between two users, Karl and Hans.There is only one user named Karl and one named Hans in the dataset.
with karl_friends as
(
 select friend_id
 from friends
 where user_id = (select user_id from users where user_name = "Karl")
),
Hans_friends as
(
 select friend_id
 from friends
 where user_id = (select user_id from users where user_name = "Hans")
)
select user_id, user_name
from users u
join karl_friends kf on u.user_id = kf.friend_id
join Hans_friends hf on u.user_id = hf.friend_id;


-- Question Practice - 4
CREATE TABLE uber_request_logs(
		request_id int, 
        request_date datetime, 
        request_status varchar(10), 
        distance_to_travel float, 
        monetary_cost float, 
        driver_to_client_distance float
);

INSERT INTO uber_request_logs VALUES 
(1,'2020-01-09','success', 70.59, 6.56,14.36), 
(2,'2020-01-24','success', 93.36, 22.68,19.9), 
(3,'2020-02-08','fail', 51.24, 11.39,21.32), 
(4,'2020-02-23','success', 61.58,8.04,44.26), 
(5,'2020-03-09','success', 25.04,7.19,1.74), 
(6,'2020-03-24','fail', 45.57, 4.68,24.19), 
(7,'2020-04-08','success', 24.45,12.69,15.91), 
(8,'2020-04-23','success', 48.22,11.2,48.82), 
(9,'2020-05-08','success', 56.63,4.04,16.08), 
(10,'2020-05-23','fail', 19.03,16.65,11.22), 
(11,'2020-06-07','fail', 81,6.56,26.6), 
(12,'2020-06-22','fail', 21.32,8.86,28.57), 
(13,'2020-07-07','fail', 14.74,17.76,19.33), 
(14,'2020-07-22','success',66.73,13.68,14.07), 
(15,'2020-08-06','success',32.98,16.17,25.34), 
(16,'2020-08-21','success',46.49,1.84,41.9), 
(17,'2020-09-05','fail', 45.98,12.2,2.46), 
(18,'2020-09-20','success',3.14,24.8,36.6), 
(19,'2020-10-05','success',75.33,23.04,29.99), 
(20,'2020-10-20','success', 53.76,22.94,18.74);

select * from uber_request_logs;

-- Some forecasting methods are extremely simple and surprisingly effective. Naïve forecast is one of them. 
-- To create a naïve forecast for "distance per dollar" (defined as distance_to_travel/monetary_cost), 
-- first sum the "distance to travel" and "monetary cost" values monthly. This gives the actual value for the current month. 
-- For the forecasted value, use the previous month's value. After obtaining both actual and forecasted values, 
-- calculate the root mean squared error (RMSE) using the formula RMSE = sqrt(mean(square(actual - forecast))). 
-- Report the RMSE rounded to two decimal places.

with monthly_aggregates as
(
select 
	  date_format(request_date, "%Y-%m") as month_year,
	  sum(distance_to_travel) as total_distance,
	  sum(monetary_cost) as total_cost
from 
	  uber_request_logs
group by
	  date_format(request_date, "%Y-%m")
),
distance_per_dollar as
(
select 
	  month_year,
      total_distance / total_cost as distance_per_dollar
from
	  monthly_aggregates
),
naive_forcast as
(
select
	  month_year,
      distance_per_dollar,
      lag(distance_per_dollar,1) over(order by month_year) as forcasted_value
from
	  distance_per_dollar
)
select 
	  round(sqrt(avg(power((distance_per_dollar - forcasted_value), 2))),2) as rmse
from
	  naive_forcast
where
	  forcasted_value is not null;
      

-- Question Practice - 5
CREATE TABLE user_purchases(user_id int, date date, amount_spent float, day_name varchar(15));

INSERT INTO user_purchases VALUES
(1047,'2023-01-01',288,'Sunday'),
(1099,'2023-01-04',803,'Wednesday'),
(1055,'2023-01-07',546,'Saturday'),
(1040,'2023-01-10',680,'Tuesday'),
(1052,'2023-01-13',889,'Friday'),
(1052,'2023-01-13',596,'Friday'),
(1016,'2023-01-16',960,'Monday'),
(1023,'2023-01-17',861,'Tuesday'),
(1010,'2023-01-19',758,'Thursday'),
(1013,'2023-01-19',346,'Thursday'),
(1069,'2023-01-21',541,'Saturday'),
(1030,'2023-01-22',175,'Sunday'),
(1034,'2023-01-23',707,'Monday'),
(1019,'2023-01-25',253,'Wednesday'),
(1052,'2023-01-25',868,'Wednesday'),
(1095,'2023-01-27',424,'Friday'),
(1017,'2023-01-28',755,'Saturday'),
(1010,'2023-01-29',615,'Sunday'),
(1063,'2023-01-31',534,'Tuesday'),
(1019,'2023-02-03',185,'Friday'),
(1019,'2023-02-03',995,'Friday'),
(1092,'2023-02-06',796,'Monday'),
(1058,'2023-02-09',384,'Thursday'),
(1055,'2023-02-12',319,'Sunday'),
(1090,'2023-02-15',168,'Wednesday'),
(1090,'2023-02-18',146,'Saturday'),
(1062,'2023-02-21',193,'Tuesday'),
(1023,'2023-02-24',259,'Friday');

-- IBM is working on a new feature to analyze user purchasing behavior for all Fridays in the first quarter of the year. 
-- For each Friday separately, calculate the average amount users have spent per order. 
-- The output should contain the week number of that Friday and average amount spent.

with q1_fridays as
(
select
	   user_id,
       date,
       amount_spent,
       week(date) as week_number,
       day_name
from
	   user_purchases
where  day_name = "Friday" and month(date) in (1,2,3)
)
select
	  week_number,
      round(avg(amount_spent),2) as avg_amount_spent
from
	  q1_fridays
group by
	  week_number
order by
	  week_number;
	   

-- Question Practice - 6
CREATE TABLE car_launches(year int, company_name varchar(15), product_name varchar(30));

INSERT INTO car_launches VALUES
(2019,'Toyota','Avalon'),
(2019,'Toyota','Camry'),
(2020,'Toyota','Corolla'),
(2019,'Honda','Accord'),
(2019,'Honda','Passport'),
(2019,'Honda','CR-V'),
(2020,'Honda','Pilot'),
(2019,'Honda','Civic'),
(2020,'Chevrolet','Trailblazer'),
(2020,'Chevrolet','Trax'),
(2019,'Chevrolet','Traverse'),
(2020,'Chevrolet','Blazer'),
(2019,'Ford','Figo'),
(2020,'Ford','Aspire'),
(2019,'Ford','Endeavour'),
(2020,'Jeep','Wrangler');

-- You are given a table of product launches by company by year. Write a query to count the net difference between 
-- the number of products companies launched in 2020 with the number of products companies launched in the previous year. 
-- Output the name of the companies and a net difference of net products released for 2020 compared to the previous year.

with product_counts as
(
select
	   company_name,
	   sum(case when year = 2019 then 1 else 0 end) as products_2020,
       sum(case when year = 2020 then 1 else 0 end) as products_2019
from 
	   car_launches
where
	   year in (2019, 2020)
group by
	   company_name
)
select
	   company_name,
       (products_2020 - products_2019) as net_difference
from 
	   product_counts
order by
	   net_difference DESC;
       

-- Question Practice - 7
CREATE TABLE nominee_information(name varchar(20), amg_person_id varchar(10), top_genre varchar(10), birthday datetime, id int);

INSERT INTO nominee_information VALUES
('Jennifer Lawrence','P562566','Drama','1990-08-15',755),
('Jonah Hill','P418718','Comedy','1983-12-20',747),
('Anne Hathaway', 'P292630','Drama', '1982-11-12',744),
('Jennifer Hudson','P454405','Drama', '1981-09-12',742),
('Rinko Kikuchi', 'P475244','Drama', '1981-01-06', 739);

CREATE TABLE oscar_nominees(year int, category varchar(30), nominee varchar(20), movie varchar(30), winner int, id int);

INSERT INTO oscar_nominees VALUES
(2008,'actress in a leading role','Anne Hathaway','Rachel Getting Married',0,77),
(2012,'actress in a supporting role','Anne HathawayLes','Mis_rables',1,78),
(2006,'actress in a supporting role','Jennifer Hudson','Dreamgirls',1,711),
(2010,'actress in a leading role','Jennifer Lawrence','Winters Bone',1,717),
(2012,'actress in a leading role','Jennifer Lawrence','Silver Linings Playbook',1,718),
(2011,'actor in a supporting role','Jonah Hill','Moneyball',0,799),
(2006,'actress in a supporting role','Rinko Kikuchi','Babel',0,1253);

-- Find the genre of the person with the most number of oscar winnings. If there are more than one person with the same number 
-- of oscar wins, return the first one in alphabetic order based on their name. Use the names as keys when joining the tables.

with winners_count as
(
select
	   nominee,
       count(*) as total_wins
from
	   oscar_nominees
where
	   winner = 1
group by
	   nominee
)
select
	   ni.top_genre
from
	   nominee_information as ni
join
	   winners_count as wc
on
	   ni.name = wc.nominee
order by
	   wc.total_wins desc,
       ni.name asc
limit 1;