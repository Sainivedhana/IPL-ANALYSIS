-- Teams
-- Total no of players in each category in each team
select TEAM_NAME, count_of_players, player_role from(
select *, dense_rank() over(partition by player_role order by count_of_players desc) dns_rnk from(
select team_id, player_role, count(*) count_of_players from ipl_team_players
group by team_id, player_role)t
join ipl_team using(team_id)) a
where dns_rnk=1
;

-- losing rate with a team having least no of bowlers
create view least_bowlers as
select *, if(match_winner=1, team_id1, team_id2) Winning_team from
(select * from
(select *, dense_rank() over(partition by least_player_role order by count_of_players) dns_rnk from(
select team_id, player_role least_player_role, count(*) count_of_players from ipl_team_players
group by team_id, player_role)t)u
where dns_rnk=1 )v 
join ipl_match i on v.team_id=i.team_id1 or v.team_id=i.team_id2
where least_player_role = 'Bowler' ;

select (count(*)/(select count(*) from least_bowlers))*100 loose_rate from least_bowlers
where team_id <> winning_team;

-- There is 50% chance that team with least bowlers loose the match

-- losing rate with a team having least no of batsman
create view least_batsman as
select *, if(match_winner=1, team_id1, team_id2) Winning_team from
(select * from
(select *, dense_rank() over(partition by least_player_role order by count_of_players) dns_rnk from(
select team_id, player_role least_player_role, count(*) count_of_players from ipl_team_players
group by team_id, player_role)t)u
where dns_rnk=1 )v 
join ipl_match i on v.team_id=i.team_id1 or v.team_id=i.team_id2
where least_player_role='Batsman';

select (count(*)/(select count(*) from least_bowlers))*100 as `%_of_losing` from least_batsman
where team_id <> winning_team;

-- There is 57% chance of loosing with least number of batsman

-- losing rate with a team having least no of All-rounders
create view least_all_rounder as
select *, if(match_winner=1, team_id1, team_id2) Winning_team from
(select * from
(select *, dense_rank() over(partition by least_player_role order by count_of_players) dns_rnk from(
select team_id, player_role least_player_role, count(*) count_of_players from ipl_team_players
group by team_id, player_role)t)u
where dns_rnk=1 )v 
join ipl_match i on v.team_id=i.team_id1 or v.team_id=i.team_id2
where least_player_role='All-Rounder';

select (count(*)/(select count(*) from least_bowlers))*100 from least_all_rounder
where team_id <> winning_team;

-- There is 57% chance of loosing with least number of all_rounders

-- losing rate with a team having least no of wicket_keepers
create view least_wicket_keeper as
select *, if(match_winner=1, team_id1, team_id2) Winning_team from
(select * from
(select *, dense_rank() over(partition by least_player_role order by count_of_players) dns_rnk from(
select team_id, player_role least_player_role, count(*) count_of_players from ipl_team_players
group by team_id, player_role)t)u
where dns_rnk=1 )v 
join ipl_match i on v.team_id=i.team_id1 or v.team_id=i.team_id2
where least_player_role='Wicket Keeper';

select (count(*)/(select count(*) from least_bowlers))*100 from least_wicket_keeper
where team_id <> winning_team;

-- There is 57% chance of loosing with least number of wicket_keeper

select * from ipl_match;

-- What is the probability of each team winning the toss

select team_name,team_id, (no_of_times_toss_won/total_participation)*100 toss_win_percentage from (
select if(toss_winner=1, team_id1, team_id2) toss_win_decoded, count(*) no_of_times_toss_won from ipl_match
group by if(toss_winner=1, team_id1, team_id2))g      -- Gives the no.of times each team has won the toss

join 
(select team_id, c1+c2 total_participation from
(select team_id1 team_id, count(*) c1 from ipl_match
group by team_id1 )x                                  -- Gives the count of each team played as team_id1
join
(select team_id2 team_id, count(*) c2 from ipl_match
group by team_id2)y                                   -- Gives the count of each team played as team_id2
using(team_id))h
on g.toss_win_decoded = h.team_id
join ipl_team i using(team_id);

-- Team 7 has the highest toss winning percentage and team 1 has the lowest toss winning percentage in overall 

-- What is the probability of winning for each team for the certain opponent?
create view v2 as
select x.team_id1 team1, x.team_id2 team2, if(match_winner=1, i.team_id1, i.team_id2) winning_team from
(select * from (
select TEAM_ID1 from ipl_match 
group by TEAM_ID1)a
cross join
(select TEAM_ID2 from ipl_match 
group by TEAM_ID2)b
where team_id1<team_id2
order by team_id1)x
join ipl_match i on ((x.team_id1 = i.team_id1) and (x.team_id2 = i.team_id1)) or ((x.team_id1 = i.team_id2) and (x.team_id2 = i.team_id1))
;

select a.team1, b.team2, winning_team, match_won/tot_match winning_percentage from 
(select team1, team2, count(*) tot_match from v2
group by team1, team2
order by team1, team2)a
join
(select team1, team2, winning_team, count(*) match_won from v2
group by team1, team2, winning_team
order by team1, team2)b
on a.team1=b.team1 and a.team2=b.team2
where match_won/tot_match =1;
