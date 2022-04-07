select COUNT(*)
from athlete_events

select top 100 *
from athlete_events

--Identify the sport which was played in all summer olympics.

with t1 as
	(select count(distinct Games) as Total_summer_games
	from athlete_events
	where Season = 'Summer'
	),
t2 as
	(select  distinct Sport, Games
	from athlete_events
	where Season = 'Summer'
	
	),
t3 as
	(select Sport, COUNT(Games) as no_of_games
	from t2
	group by Sport)
Select  *
from t3
join t1 on t1.Total_summer_games = t3.no_of_games

--Fetch top five athletes who won gold medals

with t1 as
	(select name, COUNT(1) as total_medals
	from athlete_events
	where Medal = 'Gold'
	group by Name),
t2 as
	(select *,dense_RANK() over(order by total_medals desc) as rnk
	from t1)
select *
from t2
where rnk <= 5
order by rnk

--List down total gold, silver, bronze medals won by each countries.

Select country, coalesce([gold],0) as Gold,  coalesce([silver],0) as Silver,  coalesce([bronze],0) as Bronze
from(
	select nr.region as country, Medal, COUNT(Medal) as total_medals
	from athlete_events as ae
	join noc_regions as nr on nr.NOC = ae.NOC
	where Medal <> 'NA'
	group by nr.region, Medal)as p
PIVOT (sum(total_medals)
for Medal IN ([gold], [silver], [bronze]) )as pvt
order by gold desc, silver desc, bronze desc

--Identify which country won the most gold, silver and bronze medals in each olympic games.

Select games,country, coalesce([gold],0) as Gold,  coalesce([silver],0) as Silver,  coalesce([bronze],0) as Bronze
from(
	select games,nr.region as country, Medal, COUNT(Medal) as total_medals
	from athlete_events as ae
	join noc_regions as nr on nr.NOC = ae.NOC
	where Medal <> 'NA'
	group by games,nr.region, Medal)as p
PIVOT (sum(total_medals)
for Medal IN ([gold], [silver], [bronze]) )as pvt
order by Games, country

--How many olympics games have been held?
select  COUNT(distinct games) as total_olympic_games
from athlete_events

--List down all Olympics games held so far.
select  distinct Year, Season, City
from athlete_events
order by Year

--Mention the total no of nations who participated in each olympics game?
select distinct(Games), COUNT(distinct region) as total_countries
from athlete_events ae
join noc_regions nr ON nr.NOC = ae.NOC
group by games


--Which year saw the highest and lowest no of countries participating in olympics
select MIN(total_countries) as lowest_country, MAX(total_countries) as highest_country
from(
	select distinct(Games), COUNT(distinct region) as total_countries
	from athlete_events ae
	join noc_regions nr ON nr.NOC = ae.NOC
	group by games
	) p

--Which nation has participated in all of the olympic games	
with t1 as(
		select distinct(region), COUNT(distinct Games) as total_countries
		from athlete_events ae
		join noc_regions nr ON nr.NOC = ae.NOC
		group by region
	),
t2 as
	( select COUNT(distinct games) as t_games
	  from athlete_events)

select distinct(region), total_countries as total_countries
from t1
join t2 ON t2.t_games = t1.total_countries


--Which Sports were just played only once in the olympics.

with t1 as
(
	select distinct games, sport
	from athlete_events
),
t2 as
(
	select sport, COUNT(sport) as total_games
	from t1
	group by Sport
)

select t2.*, t1.games as games
from t1
join t2 on t1.Sport = t2.Sport
where t2.total_games = 1
order by t2.Sport

--Fetch the total no of sports played in each olympic games.
select games , COUNT(distinct sport) as no_of_sports
from athlete_events
group by Games
order by no_of_sports desc

--Fetch oldest athletes to win a gold medal
with t1 as(
	select *, RANK() over(order by age desc) rnk
	from athlete_events
	where medal = 'gold')
select Name, Sex, cast(case when age is null then '0' else age end as int) as age, Team, Games,City, Sport, Event, Medal
from t1
where rnk = 1

-- Find the Ratio of male and female athletes participated in all olympic games.

with t1 as(
	select sex, COUNT(1) as no_of_participants
	from athlete_events
	group by Sex),
	t2 as(
	select *, Row_number() over(order by no_of_participants) as cnt
	from t1), 
	min_cnt as(
				select cnt from t2 where cnt = '1'),
	max_cnt as(
				select cnt from t2 where cnt = '2')
select concat('1 : ', round(cast(max_cnt.cnt as decimal)/cast(min_cnt.cnt as decimal), 2)) as ratio
    from min_cnt, max_cnt;

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

with t1 as
(
	select  Name,team, COUNT(Medal) as mdl
	from athlete_events
	where Medal <> 'NA'
	group by Name, Team),
	t2 as(
	select Name, Team, mdl, DENSE_RANK() over(order by mdl desc) as total_medals
	from t1)
select * 
from t2
where total_medals <= 5
order by mdl desc

--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with t1 as(
	select region, COUNT(Medal) as cnt
	from athlete_events as ae
	left join noc_regions as nr on ae.NOC = nr.NOC 
	where medal <> 'NA'
	group by region
	),
	t2 as(
select *, RANK() over(order by cnt desc) rnk
from t1)
select *
from t2
where rnk <=5
order by rnk
