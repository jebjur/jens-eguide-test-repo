/********************************************************************
   		Prog name:   	Lettura_SPS_IOV.sas     
		Description: 	Legge i file inviati da IOV in excel  
						secondo tracciato regionale 
   		Creation:    	Apr2020 AB 
   		Update:      	Mag2020 AB
		Note:	


********************************************************************/

*LIBNAME prest_3  '\\sharenas2\shrdw\dati_sas\ulss2\Prestazioni'; 
*libname TABELLE '\\sharenas2\shrdw\tab_SAS';

*definizione formati;
*LIBNAME FMTGEN '\\sharenas2\shrdw\fmt_SAS\Generici';
*options fmtsearch=(FMTGEN ) fullstimer;

%LET anno=2019;
%LET mese=12;

*options MPRINT MACROGEN SYMBOLGEN fullstimer validvarname=any;



	* leggo SPSS;
	PROC IMPORT OUT=appoggio 
	     DATAFILE= "J:\excel files\Castelfranco_specialistica_2019.xls" 
	     DBMS=EXCELCS REPLACE;
	     SHEET="890002_progr_99"; 
	RUN;

	data sps_s;
	  	length 	azienda   $3.
		        sts       $6.
		        discambu  $3.
		        numrice   $16.
		        idfonte   $20.
		        numriga    8.
		        regime    $2.
				dataimpe  8.
		        datacont  8.
		        dataprim  8.
		        datapren  8.
		        dataesa   8.
		        regime    $2.
		        temperog  $1.
		        priorita  $3.
		        posiztk   $2.
		        tipoerog  $2.
		        codesen   $6.
		        icd9      $7.
		        codprest  $15.
		        qta        8.
		        tot_ticket 8.
		        tot_importo 8.
		        branca    $2.
		        dataref   8.
				garantita $1.
				noesenz   $1.
				ripete    $2.
				prosegue  $2. 
				tipoacc   $1.  
		;
	  	set appoggio;
		keep azienda sts discambu numrice idfonte numriga regime dataimpe datacont dataprim datapren dataesa regime temperog priorita posiztk 
			tipoerog codesen icd9 codprest qta tot_ticket tot_importo branca dataref garantita noesenz ripete prosegue tipoacc  annoinv meseinv
		;

			sts=STRUTTURA_EROGATRICE ;
			discambu=DISCIPLINA ;
			numrice=NUM_RICETTA ;
			idfonte=ID_RICETTA ;
			numriga=PROGRESSIVO_RICETTA;
			regime=REGIME_EROGAZIONE;
			dataimpe=input(DATA_PRESCRIZIONE, ddmmyy8.); 
			datacont=input(DATA_CONTATTO, ddmmyy8.); 
			dataprim=input(PRIMA_DATA_DISPO, ddmmyy8.); 
			datapren=input(DATA_PRENOTATA, ddmmyy8.);
			dataesa=input(DATA_EROGAZIONE, ddmmyy8.);
			temperog=TEMPISTICA_EROGAZIONE;
			priorita=CLASSE_PRIORITA; 
			posiztk=POSIZIONE_UTENTE;
			tipoerog=TIPOLOGIA_EROGAZIONE ;
			codesen=CODICE_ESENZIONE;
			icd9=CODICE_PRESTAZIONE_NT; 
			codprest=CODICE_PRESTAZIONE_CUP; 
			qta=QUANTITA;
			tot_ticket=IMPORTO_TICKET; 
			tot_importo=IMPORTO_PRESTAZIONE;
			branca=CODICE_BRANCA;
			dataref=input(DATA_REFERTO, ddmmyy8.);
			noesenz=NON_ESENTE;
			ripete=RIPETITIVITA; 
			prosegue=PROSECUZIONE_IMPEGNATIVA;

			format dataimpe datacont datapren dataesa dataprim dataref ddmmyy10. qta commax12. tot_ticket tot_importo commax12.2;
			annoinv=&anno.;
			meseinv=&mese.;
	run;

	proc sort data=sps_s; 
		by azienda idfonte numriga;
	run;

	data sps_u;
		set sps_s ;
		by azienda idfonte;
		
		if first.idfonte then ultdataesa=dataesa;
		if dataesa>ultdataesa then ultdataesa=dataesa;
		if last.idfonte and dataesa eq . then dataesa=ultdataesa;

		*distretto=put(sts, $stsdistretto.);
		
		length CDC $10.;

		if discambu eq "" then cdc="";
		if sts eq "" then cdc="";

		CDRRAGGR=put(trim(left(year(dataesa)))||trim(left(CDC)),$CDCCODCDRBUDGET.);
		if CDRRAGGR eq "" and put(CDC,$REPCDRRAGGRBREVE.) ne CDC then CDRRAGGR=put(CDC,$REPCDRRAGGRBREVE.);
		CDRRAGGR_Des=put(CDRRAGGR,$CDR.);

		if put(icd9,$PRESTTRACC.) eq "S" then Tracciante=1;

		if numriga ne 99 then Attesa=dataEsa-datacont;

		if  Garantita eq "1" then do;
			* per priorità A-->10gg;
			if priorita eq 'A' then RispettoTempi1=(Attesa<=10); 
			* per priorità B-->30gg ;
			if priorita eq 'B' then RispettoTempi1=(Attesa<=30);
			* per priorità C-->90gg;
			/*
			14.09.2018 AB su indicazione mail di Domenico per adeguarsi a calcolo della regione
			if priorita eq 'C' then RispettoTempi1=(Attesa<=90);
			*/
			if priorita in ('' 'C') then RispettoTempi1=(Attesa<=90);
		end;
		if  Garantita in ("1" "2") then do;;
			* per priorità A-->20gg;
			if priorita eq 'A' then RispettoTempi2=(Attesa<=20); 
			* per priorità B-->60gg ;
			if priorita eq 'B' then RispettoTempi2=(Attesa<=60);
			* per priorità C-->120gg;
			if priorita in ('' 'C') then RispettoTempi2=(Attesa<=120);
		end;

		Flag_ExDRG=put(icd9, $PRESTEXDRG.);
		Flag_Visita=put(icd9, $PRESTVISITA.);
		Flag_Controllo=put(icd9, $PRESTCONTROLLO.);
		if Flag_Visita not in ('S' 'N') then Flag_Visita='';
		if Flag_Controllo not in ('S' 'N') then Flag_Controllo='';
		ANNOESA=year(dataesa);
		MESEESA=month(dataesa);

		format ultdataesa ddmmyy10. tot_ticket tot_importo numx25.2;

	run;

	proc sort data=sps_u; 
		by azienda idfonte descending numriga;
	run;
	* 18.04.2019 faccio il giro dalla riga 99 alla 1 per riportare ultima data esame, codice esenzione e posizione tk su tutte le righe
	 valutare se aggiiungere anche la priorità;
	data sps(drop=app_ultdataesa app_codesen app_posiztk);
		set sps_u;
		by azienda idfonte descending numriga;
		if first.idfonte then do;
			app_ultdataesa=ultdataesa;
			app_codesen=codesen;
			app_posiztk=posiztk;
			retain app_ultdataesa app_codesen app_posiztk;
		end;
		ultdataesa=app_ultdataesa;
		codesen=app_codesen;
		posiztk=app_posiztk;
	run;

	proc sort data=sps out=sps_IOV_&anno; 
by azienda idfonte numriga; run;

	
	TITLE1 "Numero SPS IOV - Anno &anno.";
	PROC FREQ DATA=SPS_IOV_&anno 	;
		tables sts*meseesa / missing nocum norow nocol nopercent;
	RUN;



