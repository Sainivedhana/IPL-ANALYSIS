select * from ipl_stadium;
create view stadium as
select *, case
when city in ('Mumbai', 'Jaipur','Pune') then 'West_India'
when city in ('Hyderabad','Bengaluru','Chennai') then 'South_India'
when city in ('Delhi','Mohali','Indore') then 'North_India'
when city = 'Kolkata' then 'East_India' end as Sector from ipl_stadium;

select * from stadium;

select * from stadium s 
join ipl_match_schedule m using(stadium_id)
where status='Cancelled';

-- In the last 2 years(2017 and 2018) 2 times match has been cancelled. Mohali is the only city where the match has been scheduled and 
-- cancelled. Hence in future if match has to be scheduled in mohali city, precautionary measures has to be taken inorder to avoid
-- cancellation.

select (count(*)/(select count(*) from stadium s 
				join ipl_match_schedule m using(stadium_id)
				where city = 'Mohali' ))*100 Cancel_percentage from stadium s 
join ipl_match_schedule m using(stadium_id)
where city = 'Mohali' and  status='Cancelled';

-- 12% of the time there exists a chance of match cancellation when scheduled in mohali city

select sector, count(*) no_of_matches from stadium s 
join ipl_match_schedule m using(stadium_id)
group by sector;

-- In the last 2 years(2017 and 2018) highest number of matches has been scheduled in north india and least number of matches has been
-- scheduled in eastern part since there exists stadium only in kolkata in eastern part.

-- Percentage of winning of each team in each stadium
select x.stadium_id, team_id, (win_count/tot_match)*100 winning_percent from
(select stadium_id, if(match_winner=1, team_id1, team_id2) winning_team, count(*) win_count from stadium s 
join ipl_match_schedule m using(stadium_id)
join ipl_match using(match_id)
group by STADIUM_ID, if(match_winner=1, team_id1, team_id2)
order by stadium_id)x
join

(select a.STADIUM_ID, TEAM_ID1 team_id, t1+t2 tot_match  from
(select STADIUM_ID, TEAM_ID1, count(*) t2 from stadium s 
join ipl_match_schedule m using(stadium_id)
join ipl_match using(match_id)
group by STADIUM_ID, TEAM_ID1)a
join
(select STADIUM_ID, TEAM_ID2, count(*) t1 from stadium s 
join ipl_match_schedule m using(stadium_id)
join ipl_match using(match_id)
group by STADIUM_ID, TEAM_ID2)b
on a.stadium_id = b.stadium_id and a.team_id1=b.team_id2)y
on x.stadium_id=y.stadium_id and x.winning_team = y.team_id;

-- which team has played more matches in each sector?
select distinct * from
(select a.sector, TEAM_ID1 team_id, t1+t2 tot_match, dense_rank() over(partition by a.sector order by t1+t2 desc) drnk  from
(select sector, TEAM_ID1, count(*) t2 from stadium s 
join ipl_match_schedule m using(stadium_id)
join ipl_match using(match_id)
group by sector, TEAM_ID1)a
join
(select sector, TEAM_ID2, count(*) t1 from stadium s 
join ipl_match_schedule m using(stadium_id)
join ipl_match using(match_id)
group by sector, TEAM_ID2)b
on a.sector= b.sector and a.team_id1=b.team_id2)t
join ipl_team i
on t.team_id=i.TEAM_ID
where drnk=1;


