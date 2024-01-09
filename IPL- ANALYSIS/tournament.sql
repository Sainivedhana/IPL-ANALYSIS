select * from ipl_tournament;

select * from (
select *, lead(remarks, 1) over(order by tournmt_id) nxt_yr_champ, lead(remarks, 2) over(order by tournmt_id) nxt_2nd_yr_champ 
from ipl_tournament)t
where remarks = nxt_yr_champ;

-- CSK is the only team that has won the championship fro 2 consecutive years 2010 and 2011