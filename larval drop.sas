PROC IMPORT OUT= WORK.drop
DATAFILE= "C:\Users\tmcavoy\Documents\Excel 2\HWA\Feeding ovi study\Larvae Drop 2019.xlsx"
     DBMS=XLSX REPLACE;
     SHEET="input"; 
     

* variables: 
Site	date_collected	rep	n_hwa	date_larvae_collected	n_larvae
;


data drop;
set drop;


proc sort;
by Site date_collected;
proc print;

proc means noprint data = drop;
var n_hwa n_larvae;
output out = drop_sum
mean = n_hwa n_larvae
sum = sum_n_hwa sum_n_larvae
by Site date_collected;

data drop2;
set drop_sum;


ln_hwa_ratio = sum_n_larvae / n_hwa;
ln_hwa_perc = ln_hwa_ratio * 100;

proc print;

PROC EXPORT DATA= WORK.drop2
OUTFILE= "C:\Users\tmcavoy\Documents\Excel 2\HWA\Feeding ovi study\Larvae Drop 2019.xlsx"
     DBMS=XLSX REPLACE;
SHEET="ln_per_hwa output";		
RUN;
