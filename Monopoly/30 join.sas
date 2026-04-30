proc sql;
 create table work.compare
 as select b.field, 
           a.percent/100 as sim_pct format=percent8.3,
           b.percent/100 as stat_pct format=percent8.3,
           (a.percent/100 - b.percent/100)*100 as diff format = 8.3,
		   abs(calculated diff) as Abs_diff
	from work.simprob as a, work.statprob as b
	where a.value = b.field
    order by  5 descending
;
quit;