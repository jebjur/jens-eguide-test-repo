this example is to show how to compute a person's age. the IF stmt looks to see if the birthday has occured yet when the birth month is the same as the result of the TODAY function

data birth;
input name $ bday date9.;
cards;
joe 02sep1985
john 31jan1993
amy 16jan1984
susan 12feb1967
michael 14nov1975
lee 04jul1990
sally 27apr91
;

data age;
set birth;
current=today();
format current bday worddate20.;
age=int(intck('month',bday,current)/12);
if month(bday)=month(current) then age=age-(day(bday)>day(current));
run;