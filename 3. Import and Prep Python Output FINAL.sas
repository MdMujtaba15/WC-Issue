/************************************************************************************/
/* This program takes shap output from Python and summarizes for model adjustments	*/
/* to WPC workload targets								 							*/
/* based on property code from:														*/
/* "A:\Modeling\Claims\Resource Capacity\Property Adjuster\Report\Score Code\		*/
/*	6 Import and Prep Python Output v2 Superfile Fixes.sas"							*/
/************************************************************************************/

/* UPDATE DATES */
/*%let date=05292024;*/
/*%let date2=2024-05-29;*/

/* working directory for detail */
/*libname WC '/ere/local/shared/actuarial/Share/Claims/WPC/Workers Comp/2026/02-18-2026';*/
/*/*"A:\Share\Claims\WPC\Workers Comp\2026\02-18-2026\WC_WPC_for_scoring.csv"*/*/
/*%let flag=0;*/
/*%let output_path_csv=/ere/local/shared/actuarial/Share/Claims/WPC/Workers Comp/2026/02-18-2026;*/
/*'/ere/local/shared/actuarial/Modeling/Claims/Resource Capacity/Workers Comp Adjuster/Data';*/
	
/* IMPORT THE SHAP VALUES SCORED BY THE CATBOOST MODEL */
/* get rid of invalid values when importing- ex: changes (InjuryLevelIncident,) to __InjuryLevelIncident___ */
options validvarname=v7;


%macro ImportCustom();

%if &flag. = 1 %then %do;
	PROC IMPORT DATAFILE="/ere/local/shared/actuarial/Share/Claims/WPC/Workers Comp/executable/Output/model_shap.csv"
	DBMS=csv
	REPLACE
	OUT=PYTHONRAW;
RUN;
%end;
%else %do;
	PROC IMPORT DATAFILE="&output_path_csv/model_shap.csv"
	DBMS=csv
	REPLACE
	OUT=PYTHONRAW;
RUN;
%end;

%mend ImportCustom;

%ImportCustom();


/* now get rid of the underscores */
data PYTHONRAW;
	set PYTHONRAW;

	rename __AGE_CURR___=AGE_CURR;
	rename __BMI___=BMI;
	rename __FRTH_TRTMT_REQR___=FRTH_TRTMT_REQR;
	rename __INCID_RPT_ONLY___=INCID_RPT_ONLY;
	rename __INJ_PRMIS___=INJ_PRMIS;
	rename __INJ_REG_JOB___=INJ_REG_JOB;
	rename __ISS_INVOLVE___=ISS_INVOLVE;
	rename __JURIS_STATE_PA___=JURIS_STATE_PA;
	rename __JURIS_STATE_VA___=JURIS_STATE_VA;
	rename __JURIS_STATE_MD___=JURIS_STATE_MD;
	rename __JURIS_STATE_NY___=JURIS_STATE_NY;
	rename __JURIS_STATE_WV___=JURIS_STATE_WV;
	rename __JURIS_STATE_WI___=JURIS_STATE_WI;
	rename __JURIS_STATE_NC___=JURIS_STATE_NC;
	rename __JURIS_STATE_TN___=JURIS_STATE_TN;
	rename __JURIS_STATE_IL___=JURIS_STATE_IL;
	rename __JURIS_STATE_IN___=JURIS_STATE_IN;
	rename __JURIS_STATE_WASHDC___=JURIS_STATE_WASHDC;
	rename __LEGAL_IND___=LEGAL_IND;
	rename __LOSS_CAUSE_FALLSLIPTRIP___=LOSS_CAUSE_FALLSLIPTRIP;
	rename __LOSS_CAUSE_CUTSCRAPE___=LOSS_CAUSE_CUTSCRAPE;
	rename __LOSS_CAUSE_STRAIN___=LOSS_CAUSE_STRAIN;
	rename __LOSS_CAUSE_VEH___=LOSS_CAUSE_VEH;
	rename __CORP_REFL_PRLYS___=CORP_REFL_PRLYS;
	rename __INSD_PNL_EXST___=INSD_PNL_EXST;
	rename __PRIOR_TRTMT_EXST___=PRIOR_TRTMT_EXST;
	rename __NCCI_INJ_TYP_MEDONLY___=NCCI_INJ_TYP_MEDONLY;
	rename __NCCI_INJ_TYP_TEMPORARYINJ___=NCCI_INJ_TYP_TEMPORARYINJ;
	rename __NCCI_INJ_TYP_PERMPARTIAL___=NCCI_INJ_TYP_PERMPARTIAL;
	rename __NCCI_INJ_TYP_PERMTOTAL___=NCCI_INJ_TYP_PERMTOTAL;
	rename __NCCI_LOSS_TYP_TRAUMA___=NCCI_LOSS_TYP_TRAUMA;
	rename __NCCI_LOSS_TYP_CUMULATIVE___=NCCI_LOSS_TYP_CUMULATIVE;
	rename __VCTNL_RHAB_INCL_INDEM___=VCTNL_RHAB_INCL_INDEM;
	rename __MECH_DFCT_INVLV___=MECH_DFCT_INVLV;
	rename __PHYS_RSTRC___=PHYS_RSTRC;
	rename __PRIM_BODY_PART_TRUNK___=PRIM_BODY_PART_TRUNK;
	rename __PRIM_BODY_PART_MULTIPLE___=PRIM_BODY_PART_MULTIPLE;
	rename __PRIM_BODY_PART_NECKHEAD___=PRIM_BODY_PART_NECKHEAD;
	rename __MIDDLE_MARKET___=MIDDLE_MARKET;
	rename __baseline_mean___=baseline_mean;
run;


/* check all modeled times make sense with shap, and create variable groupings */
data python2;
	set pythonraw (drop=var1);

	Claim =			sum(INCID_RPT_ONLY,
					INSD_PNL_EXST,
					VCTNL_RHAB_INCL_INDEM,
					MECH_DFCT_INVLV,
					MIDDLE_MARKET,
					FRTH_TRTMT_REQR,
					INJ_PRMIS,
					INJ_REG_JOB,
					LOSS_CAUSE_FALLSLIPTRIP,
					LOSS_CAUSE_CUTSCRAPE,
					LOSS_CAUSE_STRAIN,
					LOSS_CAUSE_VEH,
					PRIOR_TRTMT_EXST);

	Territory =	 	sum(JURIS_STATE_PA,
					JURIS_STATE_VA,
					JURIS_STATE_MD,
					JURIS_STATE_NY,
					JURIS_STATE_WV,
					JURIS_STATE_WI,
					JURIS_STATE_NC,
					JURIS_STATE_TN,
					JURIS_STATE_IL,
					JURIS_STATE_IN,
					JURIS_STATE_WASHDC);

	Medical = 		sum(NCCI_INJ_TYP_MEDONLY,
					NCCI_INJ_TYP_TEMPORARYINJ,
					NCCI_INJ_TYP_PERMPARTIAL,
					NCCI_INJ_TYP_PERMTOTAL,
					NCCI_LOSS_TYP_TRAUMA,
					NCCI_LOSS_TYP_CUMULATIVE,
					PHYS_RSTRC,
					BMI,
					CORP_REFL_PRLYS,
					PRIM_BODY_PART_TRUNK,
					PRIM_BODY_PART_MULTIPLE,
					PRIM_BODY_PART_NECKHEAD,
					AGE_CURR);

	Investigation = sum(ISS_INVOLVE,
					LEGAL_IND);

	shap_pred = 	sum(baseline_mean,
					Claim,
					Territory,
					Medical,
					Investigation);

	check = round(shap_pred - pred,.001);

run;
/* all zeros- no errors! */
proc means data = python2 nway noprint missing;
	class check;
	var AGE_CURR;
	output out = test (drop = _type_) sum=;
run;

/* in case we would ever get a historical open file- probably not needed for scoring because we place so little weight on open exposures  */
/*PROC IMPORT DATAFILE='/ere/ho/actuarial/Share/Claims/WPC/Liability/Workload SAS programs/history Liability Open Exposures.xlsx'*/
/*	DBMS=XLSX*/
/*	REPLACE*/
/*	OUT=Exposures_Open;*/
/*	GETNAMES=YES;*/
/*RUN;*/

/* stack - 528,258*/
/* UPDATE */
data WC_Claims1; set WC.WC_WPC_for_scoring;

	/* create a key field to mmerge on */
	format drpno $100.;
	drpno=strip(CLM_NR)||"-"||strip(AdjNu)||"-"||strip(Adj_Team)||"-"||strip(Status)||"-"||strip(PayPeriodEnd);

	/* create a standard pay period to merge on */
	format PayPeriodString $8.;
	PayPeriodString = put(PayPeriodEnd,8.);

	format payperioddate MMDDYY10.;
	payperioddate = mdy(substr(PayPeriodString,5,2),substr(PayPeriodString,7,2),substr(PayPeriodString,1,4));
run;

/* merge on shap values- 528,258 */
PROC SQL;
	CREATE TABLE for_report As
		Select a.drpno,
				A.Status,
				A.AdjNu as ADJUSTERNR,	
				A.Adjuster_Work_Group as ADJPOSITIONTITLE,
				A.Adj_Team,
				a.payperioddate,
				max(B.pred,0) as model_elaps, /* some of the model predictions are negative- cap at a min of zero */
				b.Claim,
				b.Territory,
				b.Medical,
				b.Investigation

		From WC_Claims1 as A left join python2 as B
		on compress(a.drpno) = compress(b.drpno)
		;
QUIT;
/* see how many predictions are blank- about 1%- nice */
proc means data = for_report nway noprint missing;
	class model_elaps;
	var payperioddate;
	output out = test (drop = _type_) sum=;
run;

/*************************/
/* probably need to merge on branch and adjuster position from other file */
/*************************/
/* merge adjuster info on from the main template file- adjuster names and positions are not consistent on these files */
PROC IMPORT DATAFILE='/ere/local/shared/actuarial/Share/Claims/WPC/Adj Prod by WComp_Template.xlsx'
	DBMS=XLSX
	REPLACE
	OUT=WC_Template;
	GETNAMES=YES;
RUN;

data wc_template; set wc_template;
	format PayPeriodString $8.;
	PayPeriodString = put(PayPeriod_Ending,8.);

	format PayPeriodEnd_1 MMDDYY10.;
	PayPeriodEnd_1 = mdy(substr(PayPeriodString,5,2),substr(PayPeriodString,7,2),substr(PayPeriodString,1,4));

run;
/* 528,258 */
/*proc sql;*/
/*	create table for_report as*/
/*	select a.*, b.AdjusterRegion, b.AdjusterTeamBranch, b.AdjPosition*/
/*	from for_report as a left join wc_template as b*/
/*	on a.ADJUSTERNR = b.AdjNumber and a.payperioddate = b.PayPeriodEnd_1;*/
/*quit;*/

/* DROP MISSING INFO */
/* the template file has the main count of exposures */
/* the new and completed file has the detail of the exposures that we need to score the model on */
/* drop records where we are missing the main data needed for model adjustments (adjuster position, pay period, or model scores) */
/* 162,596- need payperiod on new exposures- this should drastically increase the records we keep */
/*data for_report;*/
/*	set for_report;*/
/*    if AdjPosition='' then delete;*/
/*	if payperioddate=. then delete;*/
/*	if Claim=. then delete;*/
/*run;*/

/* ADJUSTER AVERAGES- 18,479*/
proc means data= for_report noprint nway missing;
	class ADJUSTERNR ADJPOSITIONTITLE Adj_Team payperioddate;
	var model_elaps Claim Territory Medical Investigation;
	output out= avg_adj (drop = _type_ ) mean= ;
	where not missing(ADJUSTERNR);
run;

/* OVERALL AVERAGE BY POSITION ACROSS ALL PAY PERIODS */
proc means data= for_report noprint nway missing;
	class ADJPOSITIONTITLE;
	var model_elaps Claim Territory Medical Investigation;
	output out= avg_adjposition (drop = _type_ ) mean= ;
	where not missing(ADJUSTERNR);
run;

/* 18,372 */
PROC SQL;
	CREATE TABLE ind_report As
		Select a.ADJUSTERNR,
			a.ADJPOSITIONTITLE, 
			a.Adj_Team,
			a.payperioddate,
			year(a.payperioddate) as year,
			a.model_elaps as adj_avg,
			a._freq_ as records,
			a.Claim,
			a.Territory,
			a.Medical,
			a.Investigation,
			b.model_elaps as model_elaps_roll, 
			a.model_elaps/b.model_elaps as adj_to_cw
		From avg_adj as A left join avg_adjposition as B
		on A.ADJPOSITIONTITLE = B.ADJPOSITIONTITLE
/*		and a.payperiod = b.payperiod*/  /* not using rolling payperiods- just using all time average from all periods- we don't have full rolling history available */
		;
QUIT;

/* force adjustments to be normal- removed "year" from by field since we are not using rolling 12 months */
proc sort data=ind_report;
	by ADJPOSITIONTITLE /*year*/;
run;
/* each adjustment is given a rank from 0 to 99 */
proc rank data=ind_report out=ind_report groups=100;
   var adj_to_cw;
   by ADJPOSITIONTITLE /*year*/;
   ranks adj_to_cw_n;
run;

/* this limits the max/mins based on the standard deviation selection- same calc as what we use for other WPC reports  */
data ind_report;
	set ind_report;
	z_score = max(min((adj_to_cw_n)/100,99),.01); /* 0 and 1 cannot be quantiles */
	norm = quantile('NORMAL',z_score);
	norm_adj = round(1+norm*.05,.01);
run;

/* rank the four flags in groups from 0 to 3 */
proc rank data=ind_report out=ind_report groups=4;
   var Claim;
   by ADJPOSITIONTITLE;
   ranks Claim_r;
run;
proc rank data=ind_report out=ind_report groups=4;
   var Territory;
   by ADJPOSITIONTITLE;
   ranks Territory_r;
run;
proc rank data=ind_report out=ind_report groups=4;
   var Medical;
   by ADJPOSITIONTITLE;
   ranks Medical_r;
run;
proc rank data=ind_report out=ind_report groups=4;
   var Investigation;
   by ADJPOSITIONTITLE;
   ranks Investigation_r;
run;

/* merge to main template file */

data ind_report; set ind_report;
	if ADJPOSITIONTITLE in ('Workers Comp Specialist') then AdjPosition = 'Workers Compensation Spct';
		else AdjPosition = ADJPOSITIONTITLE;
run;

/* MERGE ON THE ADJUSTER MODEL ADJUSTMENTS- 18,404 */
proc sql;
	create table ind_all as
	select a.*, b.*
	from WC_Template as a left join ind_report as b
	on a.Adj_Number = b.ADJUSTERNR and a.PayPeriodEnd_1 = b.payperioddate and a.Adj_Position=b.AdjPosition;
quit;

/* UPDATE */
data ind_all; set ind_all;
		where payperiodend_1 ge mdy(01,01,2021);
run;

/* OUTPUT FOR EXCEL- 18,404 */
data ind_out(keep=
				Adj_Number	
				Adj_Position
				Adjuster_Team_Branch
				payperiodend_1	
				norm_adj
				Claim_r
				Territory_r
				Medical_r
				Investigation_r);

			retain 	Adj_Number	
					Adj_Position
					Adjuster_Team_Branch
					payperiodend_1	
					norm_adj
					Claim_r
					Territory_r
					Medical_r
					Investigation_r;
	set ind_all;
	if norm_adj = . then norm_adj = 1;

	/* 1 defaults to medium complexity claim or no adjustment to targets */
	/* claims analytics (MaryBeth) requested that we did not leave blanks */
	if Claim_r = . then Claim_r = 1;
	if Territory_r = . then Territory_r = 1;
	if Medical_r = . then Medical_r = 1;
	if Investigation_r = . then Investigation_r = 1;

run;

/* TEAM */
/* roll up to branch using hours as weight */
proc means data= ind_all noprint nway missing;
	class AdjPosition Adj_Team PayPeriodEnd_1;
	var norm_adj;
	wgt Total_Hours;
	output out= teambr_adjs (drop = _freq_ _type_) mean=;
run;
/* OUTPUT */
data teambr_adjs;
	set teambr_adjs;
	where AdjPosition ne "";
	norm_adj=round(norm_adj,0.01);
	if norm_adj = . then norm_adj = 1;
run;

/* region */
/* roll up to branch using hours as weight */
proc means data= ind_all noprint nway missing;
	class AdjPosition Adjuster_Region PayPeriodEnd_1;
	var norm_adj;
	wgt Total_Hours;
	output out= regn_adjs (drop = _freq_ _type_) mean=;
run;
/* OUTPUT */
data regn_adjs;
	set regn_adjs;
	where adjposition is not null;
	norm_adj=round(norm_adj,0.01);
	if norm_adj = . then norm_adj = 1;
run;

/*****************************************
	QLIK FILES
*****************************************/
/* 1. QlikSuperfile_wc.xlsx */

/* basically just have to merge on model scores */


/*data wc_template; set wc_template;*/
/*	EmpID = "MB";*/
/*run;*/

/* 9,861 */
PROC SQL;
CREATE TABLE qlik_final As
	Select 

		A.Adjuster_Region as AdjusterRegion
		,a.Adjuster_Team_Branch as AdjusterTeamBranch
		,a.Adj_Position as AdjPosition
		,a.Adj_Nm as AdjNm
		,a.Adj_Number as AdjNumber
		,a.SupvNam
		,a.Supv_ as SupvNum
		,a.PayPeriodEnd_1 as payperioddate
		,Year(a.PayPeriodEnd_1) as year
		,Month(a.PayPeriodEnd_1) as month
		,strip(a.Adj_Number)||strip(put(a.PayPeriodEnd_1, yymmddn8.)) as EmpID_PP 
		/*	counts*/
		,a.Assigned as AssignedClaim
		,a.Open 	
		,a.Completed	

		/*hours*/
		,a.Total_Hours as TotalHours
		,a.Total_Regular_Hours_Paid as TotalRegHours
		,a.Total_Overtime_Hours_Paid as TotalOTHoursPaid


		/* model- injuries */
		,b.norm_adj
		,b.Claim_r
		,b.Territory_r
		,b.Medical_r
		,b.Investigation_r
		,c.norm_adj as adj_br
		,d.norm_adj as adj_rgn
	
	From wc_template as A 

	left join ind_out as B
		on a.Adj_Number = b.Adj_Number
		and a.Adj_Position = b.Adj_Position
		and a.Adjuster_Team_Branch = b.Adjuster_Team_Branch
		and a.PayPeriodEnd_1 = b.PayPeriodEnd_1

	left join teambr_adjs as C
		on a.Adj_Position = c.AdjPosition 
		and a.Adjuster_Team_Branch = c.Adj_Team
		and a.PayPeriodEnd_1 = c.PayPeriodEnd_1

	left join regn_adjs as D
		on a.Adj_Position = d.AdjPosition 
		and a.Adjuster_Region = d.Adjuster_Region
		and a.PayPeriodEnd_1 = d.PayPeriodEnd_1

;
QUIT;

/* fill in 1.0s - ok to leave categories as blanks */
data qlik_final (drop=i);
	set qlik_final;

	/* file in 1.00 for missing factors */
	array N[*] Norm_adj adj_br adj_rgn;
		
	do i=1 to hbound(N);
		if N[i]=. then N[i]=1;
	end;

	if Claim_r = . then Claim_r = 1;
	if Territory_r = . then Territory_r = 1;
	if Medical_r = . then Medical_r = 1;
	if Investigation_r = . then Investigation_r = 1;
run;

data qlik_final; set qlik_final;
	if AdjPosition in ('Workers Comp Adjuster I', 'Workers Comp Adjuster II')
		then AdjPosition = 'Workers Comp Adjuster';
		else AdjPosition = AdjPosition;
run;

/* excel output */
/* UPDATE */
/*proc export data=qlik_final */
/*	outfile="/ere/local/shared/actuarial/Share/Claims/WPC/TESTING 2/Workers Comp/2024/05-29-2024/QlikSuperfile.xlsx"*/
/*	dbms=xlsx*/
/*	replace;*/
/*run;*/
/*"/ere/local/shared/actuarial/Share/Claims/WPC/Workers Comp/Data/&date2/QlikSuperfile.xlsx"*/

/* 2. QlikAdjustments_wc.xlsx */

/* again start with the template file and transpose */
/* 9,861 */
PROC SQL;
	CREATE TABLE qa_completed As
		Select a.Adj_Number as AdjNumber
				,a.Adjuster_Region
				,a.Adjuster_Team_Branch as AdjusterTeamBranch
				,a.Adj_Position as AdjPosition
/*				,a.EmpID_PP*/
				,a.PayPeriodEnd_1 as payperioddate
				,a.Assigned as AssignedClaim
				,a.Open	as OpenClaim
				,a.Completed as CompletedClaim
		From wc_template as a
	;
QUIT;
proc sort data= qa_completed; 
	by AdjNumber Adjuster_Region AdjusterTeamBranch payperioddate AdjPosition;
run;

/* transpose wide to long- basically creating a record for the 6 exposure types (file increases x6) */
/* 59,166 */
proc transpose data=qa_completed out=qa_completed_w /*prefix=adj*/;
	by AdjNumber Adjuster_Region AdjusterTeamBranch payperioddate AdjPosition;
    var AssignedClaim -- CompletedClaim;
run;

data qa_completed_w; set qa_completed_w;
	drop _LABEL_;
	rename _name_ = WL_STS_TYP_DC;
	rename COL1 = WorkCount;
run;

/* summarize */
/*proc means data = qa_completed_w nway noprint missing;*/
/*	class AdjPosition AdjNumber Adjuster_Region AdjusterTeamBranch payperioddate;*/
/*	var WL_STS_TYP_DC;*/
/*	output out = qa_completed_sum (drop = _type_) sum=;*/
/*run;*/

/* merge */
/* 59,166 */
PROC SQL;
	CREATE TABLE qlik_adj1 As
		Select  a.WL_STS_TYP_DC,
				a.AdjNumber,
				a.AdjusterTeamBranch,
				a.AdjPosition,
				a.payperioddate as payperiod,
				strip(a.AdjNumber)||strip(put(a.payperioddate, yymmddn8.)) as EmpID_PP, /*"MB" as EmpID_PP MB will fill */
				a.WorkCount,

				/* model */
				b.Norm_adj,
				b.Claim_r,
				b.Territory_r,
				b.Medical_r,
				b.Investigation_r				

		From qa_completed_w as a

		left join ind_out as b

		on 	a.AdjNumber = b.Adj_Number
		and	a.AdjusterTeamBranch = b.Adjuster_Team_Branch
		and a.AdjPosition = b.Adj_Position
		and a.payperioddate = b.PayPeriodEnd_1
	;
QUIT;
data qlik_adj1;
	set qlik_adj1;
	if norm_adj = . then norm_adj = 1;
	if Claim_r = . then Claim_r = 1;
	if Territory_r = . then Territory_r = 1;
	if Medical_r = . then Medical_r = 1;
	if Investigation_r = . then Investigation_r = 1;
run;	

data qlik_adj1; set qlik_adj1;
	if AdjPosition in ('Workers Comp Adjuster I', 'Workers Comp Adjuster II')
		then AdjPosition = 'Workers Comp Adjuster';
		else AdjPosition = AdjPosition;
run;

/* excel output */
/* UPDATE */
/*proc export data=qlik_adj1 */
/*	outfile="/ere/local/shared/actuarial/Share/Claims/WPC/TESTING 2/Workers Comp/2024/05-29-2024/QlikAdjustments.xlsx"*/
/*	dbms=xlsx*/
/*	replace;*/
/*run;*/
/* excel output */


%macro ExportCustom();

%if &flag. = 1 %then %do;
	/* excel output */
	proc export data=qlik_final 
		outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Zones/executable/Output/QlikSuperfile.xlsx"
		dbms=xlsx
		replace;
run;


	proc export data=qlik_adj1 
		outfile="/ere/local/shared/actuarial/Share/Claims/WPC/Zones/executable/Output/QlikAdjustments.xlsx"
		dbms=xlsx
	replace;
run;
%end;
%else %do;

	/* excel output */
	proc export data=qlik_final 
		outfile="&output_path_csv/QlikSuperfile.xlsx"
		dbms=xlsx
		replace;
run;




	proc export data=qlik_adj1 
		outfile="&output_path_csv/QlikAdjustments.xlsx"
		dbms=xlsx
	replace;
run;
%end;

%mend ExportCustom;

%ExportCustom();