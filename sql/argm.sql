/*
 * FUNCTIONAL TESTS
 */
begin;

create extension argm;

create table tbl as 
select d,
	i,
	grp::text || '-' || d || '-' || repeat(i::text, 10) txt,
	grp
from (
	select date'2011-11-11' - generate_series(1, 8) d,
		generate_series(1, 9) i
	order by random()
) _
cross join (values
	(1),
	(2),
	(3)
) grp (grp);

analyze tbl;

select grp, argmax(txt, i, d), argmin(array[txt], (i, d)) from tbl group by grp order by grp;

rollback;
