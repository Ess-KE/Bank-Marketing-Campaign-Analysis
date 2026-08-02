create table bank(age int, job varchar(100), marital varchar(100),
education varchar(100), default_status varchar(10), balance int, 
housing varchar(10), loan varchar(10), contact varchar(50), day int, 
month varchar(30), duration int, campaign int, pdays int, previous int,
poutcome varchar(50), deposit varchar(10));

--DATASET OVERVIEW

--dataset
select * from bank;

--number of rows
select count(*) from bank;

--number of columns
select count(column_name) from information_schema.columns
where table_name = 'bank';

--data type
select column_name, data_type from information_schema.columns
where table_name = 'bank'
order by ordinal_position;

--missing value assessment
SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_missing,
SUM(CASE WHEN job IS NULL THEN 1 ELSE 0 END) AS job_missing,
SUM(CASE WHEN marital IS NULL THEN 1 ELSE 0 END) AS marital_missing,
SUM(CASE WHEN education IS NULL THEN 1 ELSE 0 END) AS education_missing,
SUM(CASE WHEN default_status IS NULL THEN 1 ELSE 0 END) AS default_missing,
SUM(CASE WHEN balance IS NULL THEN 1 ELSE 0 END) AS balance_missing,
SUM(CASE WHEN housing IS NULL THEN 1 ELSE 0 END) AS housing_missing,
SUM(CASE WHEN loan IS NULL THEN 1 ELSE 0 END) AS loan_missing,
SUM(CASE WHEN contact IS NULL THEN 1 ELSE 0 END) AS contact_missing,
SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_missing,
SUM(CASE WHEN campaign IS NULL THEN 1 ELSE 0 END) AS campaign_missing,
SUM(CASE WHEN pdays IS NULL THEN 1 ELSE 0 END) AS pdays_missing,
SUM(CASE WHEN previous IS NULL THEN 1 ELSE 0 END) AS previous_missing,
SUM(CASE WHEN poutcome IS NULL THEN 1 ELSE 0 END) AS poutcome_missing,
SUM(CASE WHEN deposit IS NULL THEN 1 ELSE 0 END) AS deposit_missing
FROM bank;

--Summary statistics
SELECT
MIN(age) AS min_age,
MAX(age) AS max_age,
ROUND(AVG(age),2) AS avg_age,

MIN(balance) AS min_balance,
MAX(balance) AS max_balance,
ROUND(AVG(balance),2) AS avg_balance,

MIN(duration) AS min_duration,
MAX(duration) AS max_duration,
ROUND(AVG(duration),2) AS avg_duration,

MIN(campaign) AS min_campaign,
MAX(campaign) AS max_campaign,
ROUND(AVG(campaign),2) AS avg_campaign
FROM bank;
--Distribution of important variables
-----------------------------------------------------------------------------------------
--IDENTIFICATION OF TRENDS AND PATTERNS
--total customers
select count(*) as total_customers from bank;

--subscription distribution
select deposit, count(*) as total_subscription from bank
group by deposit;

--conversion rate
select deposit, round(count(*) * 100.0/(select count(*) from bank),2) as percentage
from bank
group by deposit;

----------------------------------------------------------------------------------------
--VISUALIZATION

--1. Are older customers more likely to invest in term deposits than younger customers?18-35,35-65,65+
select * from bank;
select min(age),max(age) from bank;

SELECT
    deposit,
    ROUND(AVG(age),2) AS avg_age
FROM bank
GROUP BY deposit;

select age,
case when age <= 35 then 'young'
     when age <= 65 then 'mid_age'
	 else 'old'
end as age_group from bank;


select deposit,
case when age <= 35 then 'young'
     when age <= 65 then 'mid_age'
	 else 'old'
end as age_group from bank;


with age_bands as (
select deposit,
case when age <= 35 then 'young'
     when age <= 65 then 'mid_age'
	 else 'old'
end as age_group from bank
)
select age_group, COUNT(*) AS total_customers,
    SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) AS subscribers,
    ROUND(
        SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END)*100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM age_bands
GROUP BY age_group
ORDER BY conversion_rate DESC;

----------------------------------------
--2. Which professions are most likely to subscribe?
select job from bank;

select job, count(*) as job_count from bank
group by job;

select deposit,job, count(*) as job_count from bank
group by deposit, job;

select job, COUNT(*) AS total_customers,
    SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) AS subscribers,
    ROUND(
        SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END)*100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM bank
GROUP BY job
ORDER BY conversion_rate DESC;

------------------------------------------------------------------
--3. Does education level influence subscription behavior?
select education from bank;

select deposit, education from bank;
4.
select education, count(*) as total_customers,
sum(case when deposit='yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit='yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by education
order by conversion_rate desc;

-----------------------------------------------------------
--4. Are customers with poor credit history less likely to subscribe?
select default_status from bank;

select deposit, default_status from bank;

select deposit, default_status from bank
where deposit = 'yes' and default_status = 'no' ;

select deposit, default_status from bank
where deposit = 'yes' and default_status = 'yes' ;

select deposit, default_status from bank
where deposit = 'no' and default_status = 'no' ;

select deposit, default_status from bank
where deposit = 'no' and default_status = 'yes' ;

select default_status, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
sum(case when deposit = 'no' then 1 else 0 end) as non_subscribers
from bank
where default_status = 'yes'

--correct query for this question
select default_status, count(*),
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by default_status
order by conversion_rate;


group by default_status;

select default_status, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
sum(case when deposit = 'no' then 1 else 0 end) as non_subscribers,
sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*) as defaulter_subscription_rate,
sum(case when deposit = 'no' then 1 else 0 end)*100.0/count(*) as defaulter_nonsubscription_rate
from bank
where default_status = 'yes'
group by default_status;

-----------------------------------------------------------------------------------------
--5. Do wealthier customers subscribe more?(balance)
select * from bank;
select min(balance), max(balance), avg(balance) from bank;
select * from bank where balance <0;
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY balance) AS q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY balance) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY balance) AS q3
FROM bank;


select deposit,
case when balance < 122 then 'low balance'
when balance < 1708 then 'medium balance'
else 'high balance'
end as balance_bands
from bank;

with balance_group as ( select deposit,
case when balance <= 122 then 'low balance'
when balance <= 1708 then 'medium balance'
else 'high balance'
end as balance_bands
from bank
)
select balance_bands, count(*) as total_customers,
sum(case when deposit ='yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from balance_group
group by balance_bands
order by conversion_rate desc;

--------------------------------------------------------------------------------------------------
--6. Does having a mortgage reduce the likelihood of investing?
select * from bank;

select deposit, housing from bank;

select housing, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by housing
order by conversion_rate desc;
-----------------------------------------------------------------------------------------
--7. Does personal loan debt affect subscription rates?
select * from bank;

select deposit, loan from bank;

select loan, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by loan
order by conversion_rate desc;

-----------------------------------------------------------------------------------------
--8. Which communication channel is most effective?
select contact from bank;

select deposit, contact from bank;

select contact, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by contact
order by conversion_rate desc;

--------------------------------------------------------------------------------------
--9. Does a longer conversation increase the chance of subscription
select duration from bank;
select min(duration), max(duration), avg(duration) from bank;

SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY duration) AS q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY duration) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY duration) AS q3
FROM bank;


select deposit,
case when duration < 138 then 'low duration'
when duration < 496 then 'medium duration'
else 'high duration'
end as duration_band
from bank;

with duration_group as ( select deposit,
case when duration <= 138 then 'low duration'
when duration <= 496 then 'medium duration'
else 'high duration'
end as duration_band
from bank
)
select duration_band, count(*) as total_customers,
sum(case when deposit ='yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from duration_group
group by duration_band
order by conversion_rate desc;
----------------------------------------------------------------------------------------------
--10. How many contacts produce the best results?

select campaign from bank;
select min(campaign), max(campaign), avg(campaign) from bank;

SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY campaign) AS q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY campaign) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY campaign) AS q3
FROM bank;


select deposit,
case when campaign <= 2 then 'low campaign'
when campaign <= 10 then 'medium campaign'
else 'high campaign'
end as campaign_band
from bank;

with campaign_group as ( select deposit,
case when campaign <= 2 then 'low campaign'
when campaign <= 10 then 'medium campaign'
else 'high campaign'
end as campaign_band
from bank
)
select campaign_band, count(*) as total_customers,
sum(case when deposit ='yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from campaign_group
group by campaign_band
order by conversion_rate desc;

---------------------------------------------------------------------------------------
--11. Are new prospects more responsive than previously contacted customers
--New Prospect: pdays = -1 and Previously Contacted: pdays > -1

select pdays from bank;
select min(pdays), max(pdays), avg(pdays) from bank;


SELECT
        deposit,
        CASE
            WHEN pdays = -1 THEN 'New Prospect'
            ELSE 'Previously Contacted'
        END AS customer_type
    FROM bank;
	

WITH contact_history AS (
    SELECT
        deposit,
        CASE
            WHEN pdays = -1 THEN 'New Prospect'
            ELSE 'Previously Contacted'
        END AS customer_type
    FROM bank
)

SELECT
    customer_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) AS subscribers,
    ROUND(
        SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM contact_history
GROUP BY customer_type
ORDER BY conversion_rate DESC;

--how does many previous days/pdays matter?
WITH pdays_group AS (
    SELECT
        deposit,
        CASE
            WHEN pdays = -1 THEN 'Never Contacted'
            WHEN pdays <= 30 THEN 'Recently Contacted'
            WHEN pdays <= 180 THEN 'Moderately Recent'
            ELSE 'Long Ago'
        END AS pdays_band
    FROM bank
)

SELECT
    pdays_band,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) AS subscribers,
    ROUND(
        SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END)*100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM pdays_group
GROUP BY pdays_band
ORDER BY conversion_rate DESC;

-----------------------------------------------------------------------------------
--12. Does previous engagement increase conversion?
select previous from bank;
select min(previous), max(previous), avg(previous) from bank;

WITH previous_group AS (
    SELECT
        deposit,
        CASE
            WHEN previous = 0 THEN 'No Previous Contact'
            ELSE 'Previously Engaged'
        END AS engagement_status
    FROM bank
)

SELECT
    engagement_status,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) AS subscribers,
    ROUND(
        SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM previous_group
GROUP BY engagement_status
ORDER BY conversion_rate DESC;

---check specific previous engagement
WITH engagement_group AS (
SELECT
    deposit,
    CASE
        WHEN previous = 0 THEN 'No Previous Contact'
        WHEN previous <= 2 THEN 'Low Engagement'
        WHEN previous <= 5 THEN 'Medium Engagement'
        ELSE 'High Engagement'
    END AS engagement_band
FROM bank
)

SELECT
    engagement_band,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) AS subscribers,
    ROUND(
        SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END)*100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM engagement_group
GROUP BY engagement_band
ORDER BY conversion_rate DESC;

--------------------------------------------------------------------------------------------
--13. Does previous campaign success predict future success?
select deposit, poutcome from bank;

select poutcome, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end),
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by poutcome
order by conversion_rate desc;
----------------------------------------------------------------------------
--VISUALS

create view previous_campaign_outcome as 
select poutcome, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end),
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by poutcome
order by conversion_rate desc;

---------------------------------------------------------------------------------------
create view Previous_Engagement as
WITH previous_group AS (
    SELECT
        deposit,
        CASE
            WHEN previous = 0 THEN 'No Previous Contact'
            ELSE 'Previously Engaged'
        END AS engagement_status
    FROM bank
)

SELECT
    engagement_status,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) AS subscribers,
    ROUND(
        SUM(CASE WHEN deposit='yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS conversion_rate
FROM previous_group
GROUP BY engagement_status
ORDER BY conversion_rate DESC;

---------------------------------------------------------------------------------
create view Balance_Status as 
with balance_group as ( select deposit,
case when balance <= 122 then 'low balance'
when balance <= 1708 then 'medium balance'
else 'high balance'
end as balance_bands
from bank
)
select balance_bands, count(*) as total_customers,
sum(case when deposit ='yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from balance_group
group by balance_bands
order by conversion_rate desc;

------------------------------------------------------------------------------------------------------
create view Housing_Loan_Status as 
select housing, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by housing
order by conversion_rate desc;
--------------------------------------------------------------------------------------
create view Contact_Method as
select contact, count(*) as total_customers,
sum(case when deposit = 'yes' then 1 else 0 end) as subscribers,
round(sum(case when deposit = 'yes' then 1 else 0 end)*100.0/count(*), 2) as conversion_rate
from bank
group by contact
order by conversion_rate desc;
---------------------------------------------------------------------------------------
create view Subscription_Distribution as
select deposit, count(*) as total_subscription from bank
group by deposit;

--------------------------------------------------------------------------------------------












