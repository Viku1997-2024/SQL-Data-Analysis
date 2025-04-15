create database CustomerAnalytics;

use CustomerAnalytics;

create table Customers (
	CustomerID int PRIMARY KEY,
	FirstName Varchar(255),
	LastName  Varchar(255),
	Email Varchar(255),
	PhoneNumber varchar(20),
	JoinDate date,
	Status varchar(20),
	Region Varchar(50)
);

-- Create Subscriptions Table
CREATE TABLE Subscriptions (
    SubscriptionID INT PRIMARY KEY,
    CustomerID INT,
    StartDate DATE,
    EndDate DATE,
    PlanType VARCHAR(50), -- Monthly, Annual, etc.
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create Transactions Table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    CustomerID INT,
    TransactionDate DATE,
    Amount DECIMAL(10, 2),
    TransactionType VARCHAR(50), -- Purchase, Renewal, etc.
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create Churn Table
CREATE TABLE Churn (
    ChurnID INT PRIMARY KEY,
    CustomerID INT,
    ChurnDate DATE,
    Reason VARCHAR(255), -- Optional
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

select * from Customers;
drop table Customers;
select * from Subscriptions;
drop table Subscriptions;
select * from Transactions;
drop table Transactions;
select * from churn;
drop table churn;

-- 1.)Total number of active and inactive customers
select status, count(*) as TotalCustomers
from Customers
group by status;

-- 2.)Top 5 regions with the highest number of customers
select Region, count(*) TotalCustomers
from Customers
group by Region
order by TotalCustomers desc
limit 5;

-- 3.)Customers who have never made a transaction
select C.CustomerID, C.FirstName, C.LastName
from Customers C
left join Transactions T
on C.CustomerID = T.CustomerID
where t.CustomerID is null;

-- 4.)Customers who have churned but still have an active subscription
select distinct(C.CustomerID), C.FirstName, C.LastName
from Customers C
Join Churn Ch on C.CustomerID = Ch.CustomerID
join Subscriptions S on C.CustomerID = S.CustomerID
where C.status = "Active";

-- 5.)Customers who made a purchase but never requested a refund
select distinct(T.CustomerID), C.FirstName, C.LastName
from Transactions T
join Customers C 
on C.CustomerID = T.CustomerID
where T.TransactionType = "Purchase" and 
T.CustomerID not in (select CustomerID from Transactions where TransactionType = "Refund");

-- 6.)Top 10 customers with the highest revenue
select T.CustomerID, C.FirstName, C.LastName, sum(T.Amount) as TotalSpent
from Transactions T
join Customers C on T.CustomerID = C.CustomerID
group by T.CustomerID
order by TotalSpent desc
limit 10;

-- 7.)Average subscription duration (in months) for each plan type
select PlanType, avg(timestampdiff(month,StartDate,EndDate)) as AvgDuration
from Subscriptions
group by PlanType;

-- 8.)Number of transactions per customer and their total spend
select C.CustomerID, C.FirstName, C.LastName,
		count(T.TransactionID) as TotalTransactions,
        sum(T.Amount) as TotalSpent
from Customers C
join Transactions T on C.CustomerID = T.CustomerID
group by CustomerID
order by TotalSpent desc;

-- 9.)Customers who have both an Annual and a Monthly subscription
select CustomerID
from Subscriptions
group by CustomerID
having count(distinct PlanType) = 2;

-- 10.)Customers who have subscribed but never made a transaction
select distinct(S.customerID), C.FirstName, C.LastName
from Subscriptions S
left join Transactions T on S.CustomerID = T.CustomerID
join Customers C on S.CustomerID = C.CustomerID
where T.CustomerID is null;

-- 11.)Customers who churned within 3 months of joining
select C.CustomerID, C.FirstName, C.LastName, C.JoinDate, Ch.ChurnDate
from Customers C
join  Churn Ch on Ch.CustomerID = C.CustomerID
where timestampdiff(month, C.JoinDate, Ch.ChurnDate) <= 3;

-- 12.)Month with the highest number of new subscriptions
select month(StartDate) as month, count(*) as SubscriptionCount
from Subscriptions
group by month
order by SubscriptionCount desc
Limit 1;

-- 13.)Customers who had an active subscription in 2023 but churned in 2024
select distinct C.CustomerID, C.FirstName, C.LastName
from Customers C
join Churn Ch on C.CustomerID = Ch.CustomerID
join Subscriptions S on S.CustomerID = C.CustomerID
where year(S.EndDate) = 2023 and year(Ch.ChurnDate) = 2024
order by C.CustomerID;

-- 14.)Average time between a customer’s first transaction and their churn date
select T.CustomerID, avg(timestampdiff(day, min(T.TransactionDate), Ch.ChurnDate)) as AvgTimeToChurn
from Transactions T
join Churn Ch on T.CustomerID = Ch.CustomerID
group by T.CustomerID;

-- 15.)Total revenue generated each month for the past 12 months
select date_format(TransactionDate, "%Y-%m") as month, sum(Amount) as TotalRevenue
from Transactions
where TransactionDate >= date_sub(curdate(),interval 12 month)
group by month
order by month desc;

-- 16.)Percentage of churned customers per region
select C.Region, count(distinct Ch.CustomerID)/count(distinct C.CustomerID)*100 as ChurnRate
from Customers C
left join Churn Ch on C.CustomerID = Ch.CustomerID
group by C.Region;

-- 17.)Customers who renewed their subscription at least once
select CustomerID
from Subscriptions
group by CustomerID
having count(*) > 1;

-- 18.)Customers who made a transaction in the last 30 days but have an inactive status
select C.CustomerID, C.FirstName, C.LastName
from Customers C
join Transactions T on C.CustomerID = T.CustomerID
where C.status = "Inactive" and T.TransactionDate >= date_sub(curdate(), Interval 30 day);

-- 19.)Rank of customers total amount spent in subscription according to region
with CustTransTotal as (
select T.CustomerID, C.FirstName, C.LastName, C.Region, sum(T.Amount) as TotalAmount
from Transactions T
join Customers C
on C.CustomerID = T.CustomerID
group by T.TransactionID, c.FirstName, C.LastName, C.Region
)
select *, Rank() over(partition by Region order by TotalAmount desc) as RankCustAmount
from CustTransTotal;

-- 20.)Customers who have churned before the Enddate of Subscriptions
select Ch.CustomerID, C.FirstName, C.LastName, Ch.ChurnDate, S.StartDate, S.EndDate
from Customers C
join  Churn Ch on Ch.CustomerID = C.CustomerID
join Subscriptions S on S.CustomerID = C.CustomerID
where Ch.ChurnDate between S.StartDate and S.EndDate;

-- 21.)% of Customers who have churned region wise
with RegionChurn as (
select C.Region,
			count(C.CustomerID) as TotalCustomers,
            count(Ch.CustomerID) as ChurnedCustomers
from Customers C left join Churn Ch
on C.CustomerID = Ch.CustomerID
group by C.Region
having count(C.CustomerID) > 20
)
select *, round((cast(ChurnedCustomers as float)/TotalCustomers) * 100,2) as ChurnRate
from RegionChurn;

