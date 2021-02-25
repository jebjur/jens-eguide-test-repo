/*Start Sample*/

/*path= location of your Excel files */

%let path=J:\temp;

/*run the dir command to find the modified dates of the files*/
 filename dlist pipe "dir &path";

 data dirlist;
   infile dlist truncover;
   input string $200.;
   format date date9.;
      * find the date;
      date=input(left(scan(string,1,' ')), ?? mmddyy10.);
      if date = . then delete;
          * find file information;
          filename=scan(substr(string,40),1,'.');
          filetype=scan(substr(string,40),-1,'.');
   if filetype="xlsx";          
   drop string;
 run;

/*Sort the data set by descending date*/
 proc sort data=dirlist;
 by descending date;
 run;


/*Find the first one in the data set and put that value into a macro */
 data _null_;
set dirlist;
 if _n_=1 then do;
 file_to_import="&path"||'\'||trim(filename)||'.'||trim(filetype);
 call symput("file",file_to_import);
 end;
run;
%put &file;
 
/*** End Sample ***/