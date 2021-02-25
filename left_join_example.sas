data small;
input key ;
cards;
1
2
4
;

data large;
input key ;
cards;
1
3
4
5
;

proc sql;
create table new as
select small.key,case when 
small.key=large.key then 'yes'
else 'no'
end as flagvar
from small left join large
on small.key=large.key;

proc print data=new;
run;
