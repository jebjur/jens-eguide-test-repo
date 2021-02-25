%GLOBAL prodCat supplierCntry supplierCntry1 supplierCntry_Count
		  /* Declare global macro variables */
		  selectStat statistic;

%macro GetData;
	%local i;
	%if &supplierCntry_Count=1 %then
		%let supplierCntry1=&supplierCntry;

	/* Library assignment */
	LIBNAME OSDMSTAR META LIBRARY='Orion Star Library';

	PROC SQL;
		CREATE TABLE WORK.Cat_Web_Orders AS 
			SELECT t2.Supplier_ID, t2.Supplier_Name, 
				t1.Order_Type, t2.Product_Name,
				(t1.Delivery_Date - t1.Order_Date) FORMAT=comma10. 
              LABEL="Days to Delivery" AS DaysToDeliver,
				t2.Supplier_Country, t1.Quantity, 
				(t1.Quantity * t1.CostPrice_Per_Unit) 
              FORMAT=dollar15.2 LABEL="Payments" AS Payments,
				put(year(t1.Order_Date),4.) 
              FORMAT=$4. LABEL='Year' as Year_ID
			FROM OSDMSTAR.ORDER_FACT t1, OSDMSTAR.PRODUCT_DIM t2
				WHERE (t1.Product_ID = t2.Product_ID) 
					and Order_Type in (2,3)
					and Product_Category="&prodCat"
					and Supplier_Country in (
						%do i=1 %to &supplierCntry_Count;
							"&&supplierCntry&i"
						%end;
					);
	QUIT;
%mend GetData;

%macro CreateReport;
	%local i;

	/* Add code to set default statistic */
	%if &selectStat=No %then %let statistic=mean;

	%do i=1 %to &supplierCntry_Count;
		/* Convert country code parameter into country name */
		%let CountryName=%qsysfunc(putc(&&supplierCntry&i,$Country.));
		%let CountryName=%qtrim(&CountryName);

		TITLE;
		TITLE1 "Days to Deliver by Order Type and Supplier";
		TITLE2 "For Product Category: &prodCat";
		TITLE3 "for &CountryName";
		FOOTNOTE;

		PROC TABULATE DATA=WORK.Cat_Web_Orders (FIRSTOBS=1)
					/* Optionally format values */
					  format=comma12.;
			WHERE Supplier_Country="&&supplierCntry&i";
			VAR DaysToDeliver;
			CLASS Supplier_Name /	ORDER=UNFORMATTED MISSING;
			CLASS Order_Type /	ORDER=UNFORMATTED MISSING;
			TABLE Supplier_Name*Order_Type, 
					/* Use the selected statistic */
					DaysToDeliver*&statistic;
		RUN;
	%end;
%mend CreateReport;

/* Execute macros */
%GetData
%stpbegin;
%CreateReport
%stpend;