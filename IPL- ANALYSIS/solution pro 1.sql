# 1.Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select bidder_id, ceil((win_cnt/tot)*100) percentage_of_wins  from 
(select bidder_id, count(bid_status) tot from ipl_bidding_details group by bidder_id) a join
(select BIDDER_ID, count(*) win_cnt from ipl_bidding_details
where bid_status = 'won'
group by BIDDER_ID) b using(bidder_id)
order by percentage_of_wins desc;

# 2. Display the number of matches conducted at each stadium with the stadium name and city.
select ims.STADIUM_ID, stadium_name, count(match_id) no_of_matches_conducted, city  from ipl_stadium iplstad
join ipl_match_schedule ims using(stadium_id)
group by STADIUM_ID;

# 3. In a given stadium, what is the percentage of wins by a team which has won the toss?
select a.STADIUM_ID, ceil((a.win_cnt/tot_cnt)*100) percentage_of_win from
(select STADIUM_ID, count(*) win_cnt from ipl_match im
join ipl_match_schedule ims using(match_id)
where (TOSS_WINNER = 1 and MATCH_WINNER = 1) or (TOSS_WINNER = 2 and MATCH_WINNER = 2)
group by stadium_id
order by STADIUM_ID) a
join
(select STADIUM_ID, count(*) tot_cnt from ipl_match im
join ipl_match_schedule ims using(match_id)
group by stadium_id) b
using (stadium_id);

# 4.Show the total bids along with the bid team and team name.
select  BIDDER_ID, bid_team, TEAM_NAME, count(*) tot_bids from ipl_bidding_details ib
join ipl_team it on ib.BID_TEAM = it.TEAM_id
group by BIDDER_ID, bid_team
order by BIDDER_ID, bid_team; 

# 5. Show the team id who won the match as per the win details
select MATCH_ID, if(match_winner = 1, team_id1, team_id2) win_team_id from ipl_match;

# 6.Display total matches played, total matches won and total matches lost by the team along with its team name.
select team_name, sum(MATCHES_PLAYED) total_matches_played, sum(MATCHES_WON) total_matches_won, sum(MATCHES_LOST) total_matches_lost from ipl_team_standings it
join ipl_team ipt using(team_id)
group by it.TEAM_ID;

# 7.Display the bowlers for the Mumbai Indians team.
select player_name from ipl_player p
join ipl_team_players it using(player_id)
join ipl_team ite using(team_id)
where team_name like '%mumbai indians%' and player_role = 'Bowler';

# 8.How many all-rounders are there in each team, Display the teams with more than 4 
-- all-rounders in descending order.
select team_name, count(player_id) no_all_rounders from ipl_team_players
join ipl_team using(team_id)
where PLAYER_ROLE like '%All%'
group by TEAM_ID
having count(player_id)> 4
order by count(player_id) desc;

# 9. Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the 
-- match in M. Chinnaswamy Stadium bidding year-wise.
-- Note the total bidders’ points in descending order and the year is bidding year.
-- Display columns: bidding status, bid date as year, total bidder’s points
select BID_STATUS, BID_DATE, TOTAL_POINTS from
(select BID_STATUS, BID_DATE, TOTAL_POINTS, if(match_winner = 1, team_id1, team_id2) win_team_id from ipl_bidder_points poi
join ipl_bidding_details bid using(bidder_id)
join ipl_match_schedule sched using(schedule_id)
join ipl_stadium using(stadium_id)
join ipl_team on ipl_team.TEAM_ID = bid.BID_TEAM
join ipl_match using(MATCH_ID)
where STADIUM_NAME like '%M. chinn%' and BID_STATUS = 'bid'  and team_name like '%chennai%') t
where win_team_id = (select team_id from ipl_team where team_name like '%chennai%' );

# 10.Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
-- Note 
-- 1. use the performance_dtls column from ipl_player to get the total number of wickets
-- 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3. Do not use joins in any cases.
-- Display the following columns teamn_name, player_name, and player_role.
select * from (
select team_name, player_name, player_role, substr(performance_dtls, instr(performance_dtls, 'Wkt')+4, instr(performance_dtls, 'Dot')-(instr(performance_dtls, 'Wkt')+4)) wickets,
dense_rank() over(order by substr(performance_dtls, instr(performance_dtls, 'Wkt')+4, instr(performance_dtls, 'Dot')-(instr(performance_dtls, 'Wkt')+4)) desc) rnk 
from ipl_player 
join ipl_team_players using(player_id) 
join ipl_team using(team_id)
where player_role in ('bowler', 'all-rounder')
order by wickets desc)t
where rnk <6;

# 11.show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
select bidder_id, (cnt_of_win/tot)*100 percentage_of_toss_win from
(select bidder_id, count(*) cnt_of_win from
(select match_id, bidder_id, bid_team, bid_status, toss_winner from ipl_bidding_details bd
join ipl_match_schedule ms using(schedule_id)
join ipl_match m using(match_id)) x
join 
(select if(toss_winner = 1, team_id1, team_id2) win_team_id, match_id from ipl_match) y using(match_id)
where bid_team = win_team_id 
group by bidder_id) a
join 
(select bidder_id, count(*) tot from ipl_bidding_details bd
group by bidder_id
order by tot desc) b using (bidder_id)
order by percentage_of_toss_win desc;

# 12.find the IPL season which has min duration and max duration.
-- Output columns should be like the below:
-- Tournment_ID, Tourment_name, Duration column, Duration
select * from 
(select tournmt_id, tournmt_name, datediff(to_date, from_date) duration, case 
when datediff(to_date, from_date) = (select min(datediff(to_date, from_date)) from ipl_tournament) then 'Minimum duration'
when datediff(to_date, from_date) = (select max(datediff(to_date, from_date)) from ipl_tournament)then 'Maximum duration'
end as duration_column
from ipl_tournament) a
where duration_column is not null;

# 13.Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
-- Only use joins for the above query queries.
select distinct bidder_id, bidder_name, year(`BID_DATE`)bid_date_as_Year, month(`BID_DATE`) bid_date_as_month, total_points from ipl_bidder_details bd
join ipl_bidder_points bp using(bidder_id)
join ipl_bidding_details de using(bidder_id)
where year(`BID_DATE`) = 2017
order by total_points desc, bid_date_as_month;

# 14.Write a query for the above question using sub queries by having the same constraints as the above question.
select distinct * from (
select bidder_id, 
(select bidder_name from ipl_bidder_details where ipl_bidder_details.bidder_id = ipl_bidding_details.bidder_id) bidder_name,
year(bid_date) year_of_bid , month(bid_date) month_of_bid ,
(select total_points from ipl_bidder_points where ipl_bidder_points.bidder_id = ipl_bidding_details.bidder_id) total_points from ipl_bidding_details
where year(bid_date) = 2017
order by total_points desc, month_of_bid) t;  

select bidder_id, count(total_points) from ipl_bidder_points
group by bidder_id;  -- month and year cannot be extracted from subquery since it provides more than one value for each primary key
                     -- (for each bidder id there exists more than 1 month row or year row and hence throws error)

# 15.Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be like:
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, 
-- Lowest_3_Bidders  --> columns contains name of bidder;
select * from (
select *, case
when rnk1 between 1 and 3 then 'Highest_3_Bidders' 
when rnk2 between 1 and 3 then 'Lowest_3_Bidders' end as 'Highest/lowest'from
(select distinct bidder_name, bidder_id, total_points,
dense_rank() over(order by total_points ) rnk2,
dense_rank() over(order by total_points desc) rnk1
from ipl_bidder_points bp 
join ipl_bidder_details using(bidder_id)
join ipl_bidding_details using(bidder_id)
where year(`BID_DATE`) = 2018) t ) u
where `Highest/lowest` is not null
;



