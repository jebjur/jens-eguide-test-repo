This code will query varnames of a particular data set and put them into a macro variable.

proc sql;
select NAME into :list separated by ' ' from dictionary.columns where libname='LIBREF' and memname='DSETNAME';
quit;

data new;
set old;
LABEL &list=' ';
run;



The code below creates two macro vars: the first is a list of the var names, and the second is the number of vars.


proc sql noprint;
select NAME, count(*) into :list separated by ' ' , :cnt from dictionary.columns 
where libname='C' and memname='ZIPCODE';
quit;