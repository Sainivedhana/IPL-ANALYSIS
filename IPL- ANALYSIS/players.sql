# Data cleaning
select * from ipl_player;
create view v1 as
select player_id, PLAYER_NAME, remarks, cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, 's-')+2, instr(PERFORMANCE_DTLS, 'M')-instr(PERFORMANCE_DTLS, 's-')+2) as float) as pts,
cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, 'Mat-')+4, instr(PERFORMANCE_DTLS, 'W')-instr(PERFORMANCE_DTLS, 'Mat-')+4) as float) as Mat,
cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, 'Wkt-')+4, instr(PERFORMANCE_DTLS, 'D')-instr(PERFORMANCE_DTLS, 'Wkt-')+4) as float) as Wkt,
cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, 'Dot-')+4, instr(PERFORMANCE_DTLS, '4s')-instr(PERFORMANCE_DTLS, 'Dot-')+4) as float) as Dot,
cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, '4s-')+3, instr(PERFORMANCE_DTLS, '6s')-instr(PERFORMANCE_DTLS, '4s-')+3) as float) as `4s`,
cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, '6s-')+3, instr(PERFORMANCE_DTLS, 'Cat')-instr(PERFORMANCE_DTLS, '6s-')+3) as float) as `6s`,
cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, 'Cat-')+4, instr(PERFORMANCE_DTLS, 'Stmp')-instr(PERFORMANCE_DTLS, 'Cat-')+4) as float) as `Cat`,
cast(substr(PERFORMANCE_DTLS,instr(PERFORMANCE_DTLS, 'mp-')+3) as float) as stmp from ipl_player;

-- Performance details contains scores for all the categories in a same column which would be difficult for analysis. Hence each 
-- category is seperated as single column and viewed.

-- Best Perfroming Players in each category is displayed
select * from v1;
create view best as
select *, 
case when pts/Mat = (select max(pts) from v1)/Mat then 1 end as 'All_rounder',
case when (Dot/Mat = (select max(Dot) from v1)/Mat) or (Wkt/Mat= (select max(Wkt) from v1)/Mat) then 1 end as 'Bowler',
case when (`4s`/Mat = (select max(`4s`) from v1)/Mat) or (`6s`/Mat = (select max(`6s`) from v1)/Mat) then 1 end as 'Batsman',
case when stmp/Mat = (select max(stmp) from v1)/Mat then 1 end as 'Keeper',
case when (Cat/Mat = (select max(Cat) from v1)/Mat) then 1 end as 'Fielder' from v1;

select player_name, 'Best_bowlers' `type` from best 
where Bowler=1
union
select player_name, 'Best_batsman' `type`from best 
where Batsman=1
union
select player_name, 'Best_keeper' `type` from best 
where Keeper=1
union
select player_name, 'Best_Allrounder' `type` from best 
where All_rounder=1
union
select player_name, 'Best_Fielder' `type` from best 
where Fielder=1;

-- Top 5 best perfroming players in each category
create view top5 as
select team_id,PLAYER_ID, player_name, pts, dot, mat, cat, stmp, wkt,
dense_rank() over(order by pts/Mat desc) All_rounder_drnk,
dense_rank() over(order by Dot/Mat desc) Dot_drnk,
dense_rank() over(order by Wkt/Mat desc) Wkt_drnk,
dense_rank() over(order by 4s/Mat desc) 4s_drnk,
dense_rank() over(order by 6s/Mat desc) 6s_drnk,
dense_rank() over(order by Cat/Mat desc) Cat_drnk,
dense_rank() over(order by stmp/Mat desc) stmp_drnk from v1
join ipl_team_players using(player_id)
join ipl_team using(team_id);

select * from top5;

select player_name top5_batsman,team_id,4s_drnk, 6s_drnk from top5
where 4s_drnk<=5 or 6s_drnk<=5
order by 4s_drnk, 6s_drnk;
select player_name top5_bowler, team_id, dot_drnk, wkt_drnk from top5
where dot_drnk<=5 or wkt_drnk<=5
order by dot_drnk, wkt_drnk;
select player_name top5_allrounder, team_id, all_rounder_drnk from top5
where all_rounder_drnk<=5
order by all_rounder_drnk;
select player_name top5_keeper, team_id, stmp_drnk from top5
where stmp_drnk<=5
order by stmp_drnk;
select player_name top5_fielder, team_id,cat_drnk from top5
where cat_drnk<=5
order by cat_drnk;
