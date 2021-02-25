filename fred pipe 'dir c:\"temp"';

/* this reads in the information for every file in the directory */

data temp1;
infile fred truncover;
length var1 $ 150;
input var1 $ 1-150;
run; 

/* this strips out the headers found in the data */;

data temp2;
set temp1;
if _n_ > 7;
ordervar=_n_;
run; 

/* We then sort the results descending to get put the trailer data on the top */

proc sort out=temp3;
by descending ordervar;
run;

/* Then we strip out the trailer data  */;

data temp3; set temp3;
if _n_ > 2;
run;

/* then re-sort it back */;

proc sort data=temp3;
by ordervar;
run;

/* then we subset the data to find only the .sas program files */

data preset (drop=ordervar); 
set temp3;
fname=reverse(scan(reverse(left(var1)),1,' '));
ext=scan(fname,2,'.');
if ext='sas' then output;
run;
