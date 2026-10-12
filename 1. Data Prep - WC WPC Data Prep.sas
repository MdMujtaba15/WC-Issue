/*******************************************************************************************************************************************

Project: Workers Comp WPC
Date: March 2023
Author: Matt Walkowiak
Description:
	- this program builds the modeling dataset for the Workers Comp WPC model
	- gathers WC claims with closed dates from 1/1/2018 to 12/31/2022
 	- each record in the data represents one claim
	- the main query below uses the CLM table in CCDS as the starting point,
		and then appends on other tables as needed
	- the y variable I am trying to predict is "number of touches", defined as:
		number of touches = activities + documents + notes
	- the only external data I append is a Middle Market indicator,
		all other data is confined to CCDS
	- WC adjusters work remotely and do not travel (unless to meet with agents), 
		so I don't have to incorporate drive time in the model


*******************************************************************************************************************************************/
/* UPDATE - month, day, year */
/*%let date=05292024;*/

/*INITIALIZE ACCESS TO CCDS*/
LIBNAME CCDS ORACLE PATH=CDEP1 SCHEMA=BRFADM Authdomain=Oracle_Auth_CCDS;
libname WCWH '/ere/warehouse/workerscompensation';

/*%let flag=0;*/
/*%let output_path_csv=/ere/local/shared/actuarial/Share/Claims/WPC/Workers Comp/2026/02-18-2026;*/


/* Project library to save data */
/*libname WC '/ere/local/shared/actuarial/Share/Claims/WPC/TESTING 2/Workers Comp/2024/07-26-2024';*/

/* Dates for closed claims */
/*%LET from_dt = '01JANUARY2019';*/
/*%LET to_dt = '31DECEMBER2022';*/

/* Import Middle Market accounts */
/*proc import out=mm_acct*/
/*    datafile="/ere/local/shared/actuarial/Modeling/Claims/Resource Capacity/Workers Comp Adjuster/Data/WC MM Accounts - Reformatted.xlsx"*/
/*    dbms=xlsx*/
/*    replace;*/
/*    getnames=YES;*/
/*run;*/

PROC SQL;
   CREATE TABLE mm_acct AS 
   SELECT
		DISTINCT(t1.PolicyNumber) AS Attribute_Name,
		t1.MiddleMarketIndicator AS Attribute_Description
   FROM WCWH.WC t1;
QUIT;





/******* Step 1: Main query ***************/

/* There are 134,273 distinct claim numbers  */
Proc SQL;
CONNECT USING CCDS;
Create table clm as
Select * from connection to CCDS
(
    Select Distinct

	/* Claim table */
	C.CLM_NTRL_ID,
	C.POL_NTRL_ID,
	C.WRK_CMPNST_NTRL_ID,
	C.CATS_NTRL_ID,
	C.CLMT_ID,
	C.RPT_DT,
	C.CLS_DT,
	C.EMPT_INJ_IN,
	C.LOSS_DT,
	C.PRG_DT,
	C.DEAD_DT,
	C.CLM_NR,
	C.EXAM_DT,
	C.ACCDNT_TYP_CD,
	C.BNFT_STT_DECSN_IN,
	C.CLMT_RPT_DT,
	C.TIER_TYP_CD,
	C.CMPT_SECR_INVLV_IN,
	C.COV_IN_QUES_IN,
	C.CMPNST_DECSN_DUE_DT,
	C.CMPNST_DECSN_MADE_DT,
	C.WRK_CMPNST_FRM_GVN_DT,
	C.EMPR_RPT_DT,
	C.INSD_RPT_DT,
	C.CLM_DC,
	C.DGSTC_CNST_IN,
	C.EMPR_VLDTY_RSN_DC,
	C.EXPSR_STRT_DT,
	C.EXPSR_END_DT,
	C.FIRE_DEPT_INFO_DC,
	C.FRST_NOTIC_SUIT_IN,
	C.FLG_DT,
	C.FLG_RSN_DC,
	C.FLG_TYP_CD,
	C.FLG_TYP_DC,
	C.FRTH_TRTMT_REQR_IN,
	C.HAZ_WST_INVLV_IN,
	C.HSPTL_DT,
	C.INCID_RPT_ONLY_IN,
	C.INJ_PRMIS_IN,
	C.INJ_REG_JOB_IN,
	C.INJ_WRK_MPN_DT,
	C.INCID_INSD_PRMIS_IN,
	C.INSD_MPN_NOTFN_DT,
	C.ISO_ENBLE_IN,
	C.ISO_KNW_IN,
	C.LARGE_LOSS_NOTFN_STT_CD,
	C.LTGTN_STT_CD,
	C.THFT_LOC_CD,
	C.LOSS_CAUS_CD,
	C.LOSS_TYP_CD,
	C.MAIN_CNTC_TYP_DC,
	C.MNFST_DT,
	C.MAX_MED_IMPRV_REA_DT,
	C.MOD_DUTY_AVLB_WRK_IN,
	C.CLM_INVLV_MOLD_IN,
	C.OTHR_RCVRY_STT_DC,
	C.PRMSN_REQR_DC,
	C.POLIC_DEPT_INFO_DC,
	C.PRE_EXST_DSBLTY_IN,
	C.PRGRS_DC,
	C.PRIM_PHYS_MED_PRVD_NTWRK_IN,
	C.REINS_FLG_STT_DC,
	C.REINS_RPT_IN,
	C.REOPN_DT,
	C.REOPN_RSN_DC,
	C.RPT_BY_DC,
	C.SF_EQP_PRVD_IN,
	C.SF_EQP_USD_IN,
	C.SLVG_STT_DC,
	C.SGMNT_DC,
	C.SPCL_INVSTN_UNT_ESCL_DT,
	C.SPCL_INVSTN_UNT_STATE_DC,
	C.SPCL_INVSTN_UNT_STT_DC,
	C.CLM_STATE_DC,
	C.STATUTE_LMT_EXPR_DT,
	C.STRG_CAT_DC,
	C.STRG_DT,
	C.STRG_LOC_STATE_DC,
	C.STRG_TYP_DC,
	C.CLM_STRTG_DC,
	C.PTNT_TRTMT_BFR_IN,
	C.CLM_VLD_LVL_DC,
	C.ACCDNT_WTHR_COND_DC,
	C.WTHR_REL_ACCDNT_IN,
	C.WRKLD_UPD_DT,
	C.ACCDNT_TYP_DC,
	C.ASGN_STT_TYP_DC,
	C.CLS_OUTCM_TYP_DC,
	C.FLG_TYP_DC,
	C.INSD_FLT_TYP_DC,
	C.ISO_STT_DC,
	C.JURIS_STATE_DC,
	C.LARGE_LOSS_NOTFN_STT_DC,
	C.LTGTN_STT_DC,
	C.LOSS_CAUS_DC,
	C.LOSS_TYP_DC,
	C.TIER_TYP_DC,
	C.THFT_LOC_DC,
	C.ASGN_DT,
	C.SRC_TYP_DC,
	C.CRNT_COND_IN,
	C.AGNT_RPT_DT,
	C.LOSS_DC,
	C.EMPR_MPN_NOTIC_DT,
	C.CRT_DT,
	C.LST_UPD_DT,
	C.REC_EFF_DT,
	C.CRNT_REC_IN,
	C.DEL_REC_IN,
	C.ETL_REC_EFF_DT,
	C.REC_RET_IN,
	C.CONCR_EMPT_DC,
	C.DRG_INVLV_DC,
	C.RPT_TYP_DC,
	C.MED_INFO_SHOW_DC,
	C.LOB_DC,
	C.EMPR_QUES_VLDTY_DC,
	C.SPCL_INVSTN_UNT_ESCL_DC,
	C.APXMT_LOSS_DT_IN,
	C.BAD_FAITH_CLM_IN,
	C.CLM_TYP_DC,
	C.CORP_REFL_AMPT_PERM_LOSS_IN,
	C.CORP_REFL_DG_BRN_IN,
	C.CORP_REFL_EMPR_LIAB_EXPSR_IN,
	C.CORP_REFL_FTLY_IN,
	C.CORP_REFL_FRAUD_SUSPCT_IN,
	C.CORP_REFL_HD_INJ_IN,
	C.INCUR_LOSS_EXCD_250K_IN,
	C.CORP_REFL_OCCP_DS_IN,
	C.CORP_REFL_OTHR_IN,
	C.CORP_REFL_PRLYS_IN,
	C.CORP_REFL_RSN_DC,
	C.CORP_REFL_SCR_IN,
	C.CORP_REFL_SGHT_LOSS_IN,
	C.CORP_REFL_STT_DC,
	C.CORP_REFL_TM_LOSS_18_MTH_IN,
	C.CORP_REFL_WHL_BODY_IN,
	C.DED_ACCT_IN,
	C.INIT_TRTMT_DC,
	C.ISS_RESP_TYP_DC,
	C.OTHR_CARR_INVLV_IN,
	C.INSD_PNL_EXST_IN,
	C.PRE_EXST_COND_IN,
	C.PRE_EXST_COND_DC,
	C.PRIOR_MED_DTL_DC,
	C.PRIOR_MED_EXST_IN,
	C.PRIOR_TRTMT_DC,
	C.PRIOR_TRTMT_EXST_IN,
	C.CLM_SUMY_DC,
	C.WRK_TRT_BY_PHYS_PNL_IN,
	C.WAIT_PRD_MEET_IN,
	C.CON_CLM_ORIG_CRT_DT,
	C.NCCI_INJ_TYP_DC,
	C.NCCI_COV_TYP_DC,
	C.NCCI_RCVRY_TYP_DC,
	C.NCCI_STLMNT_TYP_DC,
	C.NCCI_MED_CR_ORG_TYP_DC,
	C.NCCI_FRDLNT_CLM_DC,
	C.NCCI_LOSS_TYP_DC,
	C.VCTNL_RHAB_INCL_INDEM_IN,
	C.CLM_STLD_BY_LMP_SUM_IN,
	C.MECH_DFCT_INVLV_IN,
	C.USF_ACT_INVLV_IN,
	C.AGNT_CNCRN_IN,
	C.BT_LOSS_OCCUR_LOC_DC,
	C.EXPRS_CLM_IN,
	C.PHYS_CLM_IN,
	C.VNDR_CLM_IN,
	C.JDG_UNSTSFD_IN,
	C.DOC_ATCH_IN,
	C.ADT_HLD_IN,
	C.BUS_HLD_IN,
	C.LTGTN_HLD_IN,
	C.CATS_SVRTY_TYP_DC,
	C.ASGN_ERR_LOG_NTRL_ID,
	C.BT_LOSS_CAT_TYP_DC,
	C.NCCI_LOSS_COV_ACT_TYP_DC,
	C.CLM_ASGN_TYP_DC,
	C.REPR_IN,
	C.REPR_EST_CST_TYP_DC,
	C.EST_RECV_IN,
	C.HM_LVBL_IN,
	C.FMLY_MBRS_QT,
	C.NR_OF_PETS_TYP_DC,
	C.SPCL_NED_DC,
	C.SYMBLTY_CLM_IN,
	C.EMPT_IN,
	C.ENVR_CLM_TYP_DC,
	C.REINS_IN,
	C.WTR_DMG_SRC_TYP_DC,
	C.CMPNION_DEFNS_FILE_IN,
	C.EST_CMPL_DT,
	C.ITEL_CMPL_DT,
	C.INSP_CMPL_DT,
	C.HSHLD_RSDNT_QT,
	C.PRP_ELIG_IN,
	C.INSP_STLMNT_IN,
	C.SLVG_NTRL_ID,
	C.FIRE_DMG_SRC_TYP_DC,
	C.BRGLRY_SRC_TYP_DC,
	C.CVRT_SYMBLTY_CLM_IN,
	C.FNOL_SRVY_IN,
	C.LOSS_CAUS_CAT_TYP_DC,
	C.POL_SPLT_CLM_IN,
	C.SBMT_USR_ROL_TYP_DC,
	C.SF_EEQP_PRVD_TYP_DC,
	C.SF_EEQP_USD_TYP_DC,
	C.SUBRO_IDNTFR_NTRL_ID,
	C.ACQR_CLM_TYP_DC,
	C.CLM_ACQR_DT,
	C.DTL_LOSS_CAUS_DC,
	C.EXPRS_DRP_IN,
	C.EXPRS_PA_IN,

	/* Incident table */
	INCID.*,
	/* CRT_DT is also in the CLM table, so had to rename */
	INCID.CRT_DT 					as Incident_CreateDate,

	/* Contact table */
	CNTC.CNTC_NTRL_ID,
	CNTC.OCCP_DC,
	CNTC.BRTH_DT,
	CNTC.FAX_CNTRY_DC,
	CNTC.HM_PHN_CNTRY_DC,
	CNTC.ORG_TYP_DC,
	CNTC.PREF_VNDR_IN,
	CNTC.PREF_CRNCY_DC,
	CNTC.PRIM_LANG_DC,
	CNTC.PRIM_LOC_DC,
	CNTC.PRIM_PHN_DC,
	CNTC.PHYS_SPCL_TYP_DC,
	CNTC.TX_STT_DC,
	CNTC.VLD_LVL_DC,
	CNTC.VNDR_TYP_DC,
	CNTC.W9_RECV_IN,
	CNTC.W9_RECV_DT,
	CNTC.W9_VLD_STRT_DT,
	CNTC.W9_VLD_END_DT,
	CNTC.LST_UPD_DT,
	CNTC.CRT_DT,
	CNTC.REC_EFF_DT,
	CNTC.CRNT_REC_IN,
	CNTC.DEL_REC_IN,
	CNTC.ETL_REC_EFF_DT,
	CNTC.ETL_BEAN_VRSN_NR,
	CNTC.ADJDCT_DMN_DC,
	CNTC.ATTNY_SPCL_TYP_DC,
	CNTC.CELL_PHN_CNTRY_DC,
	CNTC.GNDR_DC,
	CNTC.LAW_FRM_SPCL_DC,
	CNTC.LIC_STATE_DC,
	CNTC.LOAD_REL_CNTC_IN,
	CNTC.MRTL_STT_DC,
	CNTC.MED_ORG_SPCL_DC,
	CNTC.NM_DC,
	CNTC.VNU_TYP_DC,
	CNTC.SBTYP_DC,
	CNTC.SPCL_TYP_DC,
	CNTC.TX_FLNG_STT_DC,
	CNTC.AUTO_SYNC_DC,
	CNTC.PREF_CNTC_TYP_DC,
	CNTC.PREF_LANG_TYP_DC,
	CNTC.OTHR_PREF_LANG_DC,
	CNTC.CLMT_NR,
	CNTC.ENT_TYP_DC,
	CNTC.PRMCY_IN,
	CNTC.BCKUP_WHLD_IN,
	CNTC.NY_SRCHG_IN,
	CNTC.CNTC_MGR_CNTC_LNK_PEND_IN,
	CNTC.MED_PRVD_IN,
	CNTC.NY_SRCHG_EFF_DT,
	CNTC.LVY_DT,
	CNTC.IRS1099_RPT_IN,
	CNTC.LOC_1099_RPT_IN,
	CNTC.CO_TYP_DC,
	CNTC.LAW_FRM_IN,
	CNTC.IRS_TIN_NM_MTCH_IN,
	CNTC.ADD_CNTC_WTH_TX_ID_IN,
	CNTC.PREF_PMT_METH_DC,
	CNTC.DEAD_DT,
	CNTC.ELCTR_PMT_HLD_IN,
	CNTC.CNFDL_CNTC_IN,
	CNTC.EDU_LVL,
	CNTC.CLMT_ID_TYP_DC,
	CNTC.EFT_STT_DC,
	CNTC.EFT_LST_ACCPT_DT,

	/* Policy table */
	POL.POL_NR

    From
        BRFADM.CLM C

	/* INCIDENT TABLE */
	LEFT JOIN BRFADM.INCID ON C.CLM_NTRL_ID = INCID.CLM_NTRL_ID
		/* 	CRNT_REC_IN = current record indicator:
			Per Chuck Ghastin, each time an adjuster updates the claim,
			the old version of it is changed to crnt_rec_in = 'N' and the current record is = 'Y'
			REC_RET_IN = record retired indicator - we don't want retired values */
		AND INCID.REC_RET_IN = 'N' 
		AND INCID.CRNT_REC_IN = 'Y'

		/* CLAIMANT DATA- new- no dups using this data- expand */
	LEFT JOIN BRFADM.CNTC ON C.CLMT_ID = CNTC.CNTC_NTRL_ID
	    AND CNTC.REC_RET_IN = 'N' 
	    AND CNTC.CRNT_REC_IN = 'Y'

		/* POL TABLE */
		/* Need this to join on MM indicator in Step 5 */
	LEFT JOIN BRFADM.POL ON C.POL_NTRL_ID = POL.POL_NTRL_ID

	    AND POL.REC_RET_IN = 'N' 
	    AND POL.CRNT_REC_IN = 'Y'

/* RESTRICTIONS */
    Where
        C.CRNT_REC_IN = 'Y'
        and C.REC_RET_IN = 'N'
		and C.LOB_DC = 'WorkersCompensationLine'

    Order By
        C.CLM_NR
);
DISCONNECT FROM CCDS;
Quit;

/* In ccds, Employers Liability is considered a separate incident, which causes duplicates, this sas statement removes dups */
data clm; set clm;
	where gnrl_inj_typ_cd ne .;
run;


/*proc sql;*/
/*	create table matt_check as*/
/*	select distinct clm_nr*/
/*	from clm;*/
/*quit;*/

Proc SQL;
CONNECT USING CCDS;
Create table body_part as
Select * from connection to CCDS
(
    Select distinct 
		C.LOB_DC
		,C.CLM_NR
		,INCID.CLM_NTRL_ID
		,INCID.INCID_NTRL_ID
		,INCID.gnrl_inj_typ_cd
		,BODY_PART_DTL.PRIM_BODY_PART_TYP_DC

    From BRFADM.CLM C

	LEFT JOIN BRFADM.INCID ON C.CLM_NTRL_ID = INCID.CLM_NTRL_ID
		AND INCID.REC_RET_IN = 'N' 
		AND INCID.CRNT_REC_IN = 'Y'

	LEFT JOIN BRFADM.BODY_PART_DTL ON INCID.INCID_NTRL_ID = BODY_PART_DTL.INCID_NTRL_ID
	    AND BODY_PART_DTL.REC_RET_IN = 'N' 
	    AND BODY_PART_DTL.CRNT_REC_IN = 'Y'	

    Where
        C.CRNT_REC_IN = 'Y'
        and C.REC_RET_IN = 'N'
		and C.LOB_DC = 'WorkersCompensationLine'
    Order By
        C.CLM_NR
);
DISCONNECT FROM CCDS;
Quit;

data body_part; set body_part;
	where gnrl_inj_typ_cd ne .;
run;

proc sql;
	create table body_part_count as
	select distinct clm_nr, count(PRIM_BODY_PART_TYP_DC) as body_part_count from body_part
	group by clm_nr;
quit;

/*data body_part_count; set body_part_count;*/
/*	where body_part_count gt 1;*/
/*run;*/


proc sql;
	create table body_part_count1 as
	select a.*, b.body_part_count
	from body_part as a left join body_part_count as b
	on a.clm_nr = b.clm_nr;
quit;

data body_part_count2; set body_part_count1;
	if body_part_count gt 1
		then PRIM_BODY_PART = 'MultipleBodyParts';
			else PRIM_BODY_PART = PRIM_BODY_PART_TYP_DC;
run;

proc sql;
	create table body_part_count3 as
	select distinct clm_nr, PRIM_BODY_PART
	from body_part_count2;
quit;

proc sql;
	create table clm as 
	select a.*, b.PRIM_BODY_PART
	from clm as a left join body_part_count3 as b
	on a.clm_nr = b.clm_nr;
quit;



	 



/******* Step 2: Count number of notes associated with each claim ***************/

Proc SQL;
CONNECT USING CCDS;
Create table Notes_Test as
Select * from connection to CCDS
(
    Select
		C.LOB_DC
		,C.CLM_NR
		,C.CRT_DT
		,C.CLS_DT
        ,N.NOTE_DC
    From
        BRFADM.CLM C
        Left Join BRFADM.NOTE N on C.CLM_NTRL_ID = N.CLM_NTRL_ID and N.CRNT_REC_IN = 'Y' and N.REC_RET_IN = 'N'
    Where
        C.CRNT_REC_IN = 'Y'
        and C.REC_RET_IN = 'N'
		and C.LOB_DC = 'WorkersCompensationLine'
    Order By
        C.CLM_NR
);
DISCONNECT FROM CCDS;
Quit;

proc sql;
	create table note_count as
	select clm_nr, count(NOTE_DC) as note_count
	from notes_test
	group by clm_nr;
quit;

/******* Step 3: Count number of documents associated with each claim ***************/

Proc SQL;
CONNECT USING CCDS;
Create table doc_Test as
Select * from connection to CCDS
(
    Select
		C.LOB_DC
		,C.CLM_NR
		,C.CRT_DT
		,C.CLS_DT
        ,D.DOC_DC
    From
        BRFADM.CLM C
        Left Join BRFADM.DOC D on C.CLM_NTRL_ID = D.CLM_NTRL_ID and D.CRNT_REC_IN = 'Y' and D.REC_RET_IN = 'N'
    Where
        C.CRNT_REC_IN = 'Y'
        and C.REC_RET_IN = 'N'
		and C.LOB_DC = 'WorkersCompensationLine'
    Order By
        C.CLM_NR
);
DISCONNECT FROM CCDS;
Quit;

proc sql;
	create table doc_count as
	select clm_nr, count(doc_DC) as doc_count
	from doc_test
	group by clm_nr;
quit;

/******* Step 4: Count number of activities associated with each claim ***************/

Proc SQL;
CONNECT USING CCDS;
Create table act as
Select * from connection to CCDS
(
    Select Distinct
		C.LOB_DC
		,C.CLM_NR
		,C.CRT_DT
		,C.CLS_DT
		,A.ACT_NTRL_ID
		,A.ASGN_USR_ID
		,A.ASGN_BY_USR_ID
        ,A.ASGN_DT
        ,A.TRGT_DT
        ,A.ACT_CLS_DT
        ,A.ACT_STT_DC
		,A.ACT_SUBJ_DC
        ,A.ACT_TYP_DC
        ,A.ACT_CLASS_DC
        ,A.ACT_DC
        ,A.SBTYP_DC
		,UTT.USR_TTL as Asgn_To_Ttl
        ,G.GRP_NM as Team
        ,AP.ACT_PTTRN_DC
        ,AP.ACT_PTTRN_CD
        ,AP.ACT_CAT_DC
    From
        BRFADM.CLM C

        Left Join BRFADM.ACT A on C.CLM_NTRL_ID = A.CLM_NTRL_ID and A.CRNT_REC_IN = 'Y' and A.REC_RET_IN = 'N'
 		Left Join BRFADM.ACT_PTTRN AP on A.ACT_PTTRN_NTRL_ID = AP.ACT_PTTRN_NTRL_ID and AP.CRNT_REC_IN = 'Y' and AP.REC_RET_IN = 'N'
        Left Join BRFADM.USR U on A.ASGN_USR_ID = U.USR_NTRL_ID and U.CRNT_REC_IN = 'Y' and U.REC_RET_IN = 'N'
        Left Join BRFADM.USR_TTL_TMP UTT on U.USR_NTRL_ID = UTT.USR_TTL_ID and A.ASGN_DT between UTT.USR_TTL_STRT_DT and UTT.USR_TTL_END_DT
        Left Join BRFADM.GRP G on A.ASGN_GRP_ID = G.GRP_NTRL_ID and G.CRNT_REC_IN = 'Y' and G.REC_RET_IN = 'N'
    Where
        C.CRNT_REC_IN = 'Y'
        and C.REC_RET_IN = 'N'
		and C.LOB_DC = 'WorkersCompensationLine'
/*		and c.CLM_NR = '000100019728'*/
    Order By
        C.CLM_NR
);
DISCONNECT FROM CCDS;
Quit;

/* only count activities for the adjuster */
/* this eliminates activities completed by the supervisor, subro, etc. */
data act1; set act;
	where Asgn_To_Ttl in('Workers Comp Specialist' 'Workers Comp Adjuster II' 'Sr Workers Comp Adjuster');
run;

proc sql;
	create table act_count as
	select clm_nr, count(act_subj_dc) as act_count
	from act1
	group by clm_nr;
quit;

proc sort data=act_count;
	by descending act_count;
run;

/******* Step 5: Count number of touches associated with each claim ***************/

Proc Sql;
CONNECT USING CCDS;
create table touches_count as 
Select * from connection to CCDS
(
     Select
             C.CLM_NTRL_ID
           ,C.CLM_NR
		   ,C.JURIS_STATE_DC
           ,Count(Distinct H.HIST_NTRL_ID) as Total_Touches
           ,SUM(Case When H.HIST_TYP_DC = 'Viewed' Then 1 Else 0 End) as Views
           ,SUM(Case When H.HIST_TYP_DC = 'Assigned' Then 1 Else 0 End) as Asgn
           ,SUM(Case When H.HIST_TYP_DC = 'Closed' Then 1 Else 0 End) as Closes
           ,SUM(Case When H.HIST_TYP_DC = 'Custom' Then 1 Else 0 End) as Custom_Evnts
           ,SUM(Case When H.HIST_TYP_DC = 'Delayed' Then 1 Else 0 End) as Delays
           ,SUM(Case When H.HIST_TYP_DC not in ('Viewed','Assigned','Closed','Custom','Delayed') Then 1 Else 0 End) as All_Other
     From
           BRFADM.CLM C
           Left Join BRFADM.HIST H on C.CLM_NTRL_ID = H.CLM_NTRL_ID
           Left Join BRFADM.USR U on H.USR_NTRL_ID = U.USR_NTRL_ID and U.CRNT_REC_IN = 'Y' and U.REC_RET_IN = 'N'
           Left Join BRFADM.USR_TTL_TMP UTT on U.USR_NTRL_ID = UTT.USR_TTL_ID and H.EVNT_DT between UTT.USR_TTL_STRT_DT and UTT.USR_TTL_END_DT
     Where
           C.CRNT_REC_IN = 'Y'
           and C.REC_RET_IN = 'N'
		   and C.LOB_DC = 'WorkersCompensationLine'
           and UTT.USR_TTL in ('Sr Workers Comp Adjuster', 'WORKERS COMP ADJUSTER I', 'WORKERS COMP SPECIALIST', 'Workers Compensation Specialist',
								'Workers Compensation Adjuster' , 'Workers Comp Adjuster I', 'WORKERS COMPENSATION SPECIALIST', 'Workers Comp Adjuster II',
								'SR WORKERS COMP ADJUSTER', 'Workers Compensation Adjuster II', 'Workers Comp Specialist', 'Workers Compensation Adjuster I',
								'Workers Comp Adjuser II', 'Sr Workers Compensation Adjuster', 'WORKERS COMP ADJUSTER II', 'Workers Comp Adjuster')
     Group By
             C.CLM_NTRL_ID
           ,C.CLM_NR
		   ,C.JURIS_STATE_DC
);
DISCONNECT FROM CCDS;
quit;

/* Join number of activites, notes, and documents back onto dataset from main query */

proc sql;
	create table clm_sum as
	select a.*, b.act_count
	from clm as a left join act_count as b
	on a.clm_nr = b.clm_nr;
quit;

data clm_sum; set clm_sum;
	if act_count eq . then act_count = 0;
		else act_count = act_count;
run;

proc sql;
	create table clm_sum1 as
	select a.*, b.note_count
	from clm_sum as a left join note_count as b
	on a.clm_nr = b.clm_nr;
quit;

data clm_sum1; set clm_sum1;
	if note_count eq . then note_count = 0;
		else note_count = note_count;
run;

proc sql;
	create table clm_sum2 as
	select a.*, b.doc_count
	from clm_sum1 as a left join doc_count as b
	on a.clm_nr = b.clm_nr;
quit;

data clm_sum2; set clm_sum2;
	if doc_count eq . then doc_count = 0;
		else doc_count = doc_count;
run;

proc sql;
	create table clm_sum3 as
	select a.*, b.total_touches, b.views, b.asgn, b.closes, b.custom_evnts, b.delays, b.all_other
	from clm_sum2 as a left join touches_count as b
	on a.clm_nr = b.clm_nr;
quit;

data clm_sum3; set clm_sum3;
	if total_touches eq . then delete;
run;

/*data matt; set ccds.USR_TTL_TMP;*/
/*	where clm_ntrl_id = '12127184';*/
/*run;*/

/* Number of touches is the y variable in the model */

data num_touch; set clm_sum3;
	num_stuff = act_count + note_count + doc_count;
run;

proc sort data=num_touch;
	by descending total_touches;
run;

/******* Step 6: Append and create Middle Market indicator ***************/

proc sql;
	create table num_touch1 as
	select a.*, b.Attribute_Name, b.Attribute_Description
	from num_touch as a left join mm_acct as b
	on a.pol_nr = b.Attribute_Name;
quit;

data num_touch2; set num_touch1;
	if Attribute_Description ne ""
		then MM_indic = "Y";
	else MM_indic = "N";
run;

data num_touch3; set num_touch2;
	rpt_yr = year(datepart(rpt_dt));
	cls_yr = year(datepart(cls_dt));
	cycle_time = cls_yr - rpt_yr;
	
	if BRTH_DT = . then AGE_CURR = -1;
	else AGE_CURR = 2023 - year(datepart(BRTH_DT));

	height_ft = floor(hght_nv)*12;
	inches = hght_nv - floor(hght_nv);

	if inches lt .12 then height_in = inches * 100;
		else height_in = inches * 10;

	HEIGHT = height_ft + height_in;

	BMI = 703 * WGT_NR / (height**2);

run;





data num_touch4; set num_touch3;
	keep CLM_NR 
			EMPT_INJ_IN
			BNFT_STT_DECSN_IN
			CMPT_SECR_INVLV_IN
			COV_IN_QUES_IN
			DGSTC_CNST_IN
			FRST_NOTIC_SUIT_IN
			FRTH_TRTMT_REQR_IN
			HAZ_WST_INVLV_IN
			INCID_RPT_ONLY_IN
			INJ_PRMIS_IN
			INJ_REG_JOB_IN
			INCID_INSD_PRMIS_IN
			ISO_ENBLE_IN
			ISO_KNW_IN
			LARGE_LOSS_NOTFN_STT_CD
			MOD_DUTY_AVLB_WRK_IN
			CLM_INVLV_MOLD_IN
			PRE_EXST_DSBLTY_IN
			PRIM_PHYS_MED_PRVD_NTWRK_IN
			REINS_RPT_IN
			SF_EQP_PRVD_IN
			SF_EQP_USD_IN
			SGMNT_DC
			SPCL_INVSTN_UNT_STATE_DC
			SPCL_INVSTN_UNT_STT_DC
			PTNT_TRTMT_BFR_IN
			WTHR_REL_ACCDNT_IN
			FLG_TYP_DC
			INSD_FLT_TYP_DC
			JURIS_STATE_DC
			LARGE_LOSS_NOTFN_STT_DC
			LTGTN_STT_DC
			LOSS_CAUS_DC
			TIER_TYP_DC
			CRNT_COND_IN
			CONCR_EMPT_DC
			DRG_INVLV_DC
			EMPR_QUES_VLDTY_DC
			SPCL_INVSTN_UNT_ESCL_DC
			APXMT_LOSS_DT_IN
			BAD_FAITH_CLM_IN
			CLM_TYP_DC
			CORP_REFL_AMPT_PERM_LOSS_IN
			CORP_REFL_DG_BRN_IN
			CORP_REFL_EMPR_LIAB_EXPSR_IN
			CORP_REFL_FTLY_IN
			CORP_REFL_FRAUD_SUSPCT_IN
			CORP_REFL_HD_INJ_IN
			INCUR_LOSS_EXCD_250K_IN
			CORP_REFL_OCCP_DS_IN
			CORP_REFL_OTHR_IN
			CORP_REFL_PRLYS_IN
			CORP_REFL_SCR_IN
			CORP_REFL_SGHT_LOSS_IN
			CORP_REFL_TM_LOSS_18_MTH_IN
			CORP_REFL_WHL_BODY_IN
			DED_ACCT_IN
			INIT_TRTMT_DC
			OTHR_CARR_INVLV_IN
			INSD_PNL_EXST_IN
			PRE_EXST_COND_IN
			PRIOR_MED_EXST_IN
			PRIOR_TRTMT_EXST_IN
			WRK_TRT_BY_PHYS_PNL_IN
			WAIT_PRD_MEET_IN
			NCCI_RCVRY_TYP_DC
			NCCI_MED_CR_ORG_TYP_DC
			NCCI_FRDLNT_CLM_DC
			NCCI_LOSS_TYP_DC
			NCCI_INJ_TYP_DC
			VCTNL_RHAB_INCL_INDEM_IN
			CLM_STLD_BY_LMP_SUM_IN
			MECH_DFCT_INVLV_IN
			USF_ACT_INVLV_IN
			AGNT_CNCRN_IN
			EXPRS_CLM_IN
			PHYS_CLM_IN
			VNDR_CLM_IN
			JDG_UNSTSFD_IN
			DOC_ATCH_IN
			ADT_HLD_IN
			BUS_HLD_IN
			LTGTN_HLD_IN
			REPR_IN
			EST_RECV_IN
			HM_LVBL_IN
			EMPT_IN
			ENVR_CLM_TYP_DC
			REINS_IN
			CMPNION_DEFNS_FILE_IN
			PRP_ELIG_IN
			INSP_STLMNT_IN
			LOSS_CAUS_CAT_TYP_DC
			POL_SPLT_CLM_IN
			SF_EEQP_PRVD_TYP_DC
			SF_EEQP_USD_TYP_DC
			EXPRS_DRP_IN
			EXPRS_PA_IN
			AGNT_CNTC_IN
			AGNT_NOT_CNTC_RSN_DC
			ARBG_DEPLY_IN
			ARBG_MISS_IN
			ITM_ALRDY_REPR_IN
			ABLNC_USE_IN
			VEH_EQP_ANTI_THFT_IN
			APPR_IN
			ACCDNT_DSBLTY_TYP_CD
			ACCDNT_DSBLTY_TYP_DC
			DRVR_INSD_REL_TYP_CD
			DRVR_INSD_REL_TYP_DC
			DRVR_VEH_OWNR_REL_TYP_CD
			EMPR_PRVD_MOD_DUTY_IN
			EMER_MGT_SVC_REQ_IN
			EQP_FAIL_INVLV_IN
			EXTCT_REQR_IN
			FNC_DMG_IN
			RSK_RPT_FILE_IN
			FIRE_BURN_DASH_IN
			FIRE_BRN_ENG_IN
			FIRE_BRN_WNDSHLD_IN
			FIRE_PROT_DC
			FIRE_PROT_AVLB_IN
			SLT_WTR_FLD_IN
			GNRL_INJ_TYP_DC
			HAZ_WST_INVLV_TYP_DC
			HIT_AND_RUN_IN
			ASSMT_CNTNT_ITM_INCL_IN
			ASSMT_ITM_INCL_IN
			INSP_REQR_IN
			INTR_MISS_IN
			LOC_IN
			EST_LOSS_AM
			LOSS_OCCUR_CD
			LOSS_OCCUR_DC
			USE_LOSS_IN
			WAGE_LOSS_IN
			MED_TRTMT_TYP_DC
			MNR_ON_POL_DC
			MOLD_INVLV_DC
			VEH_MOVE_PRMSN_RECV_IN
			PHNTM_VEH_INVLV_IN
			RCVRY_COND_TYP_DC
			MOD_DUTY_RFS_RSN_DC
			RENT_VEH_REQR_IN
			RTN_TO_MOD_WRK_IN
			MOD_WRK_VLD_IN
			RTN_TO_WRK_ACTL_IN
			RTN_TO_WRK_VLD_IN
			BNFT_CMPL_RSN_DC
			BNFT_SUSP_DC
			PHYS_RSTRC_IN
			RTN_TO_WRK_SAME_EMPR_IN
			DBTC_IN
			DPRS_IN
			SMKR_IN
			HEIGHT
			WGT_NR
			BMI
			HTN_IN
			HAZ_WST_DC
			AIR_TRANS_USD_IN
			STP_CLM_IN
			STBLT_WORN_IN
			LF_JCKT_WORN_IN
			BRKN_GLS_IN
			CMPL_INTR_BRN_IN
			CMPL_EXTR_BRN_IN
			VNDLM_DMG_RPT_IN
			VET_FCLTY_TRTMT_IN
			MRTL_STT_DC
			AUTO_SYNC_DC
			PRMCY_IN
			BCKUP_WHLD_IN
			CNTC_MGR_CNTC_LNK_PEND_IN
			MED_PRVD_IN
			act_count
			note_count
			doc_count
			TOTAL_TOUCHES
			MM_indic
			cycle_time
			AGE_CURR
			PRIM_BODY_PART;
		
run;
	

data WC_WPC_trimmed; set num_touch4;
	keep CLM_NR
		TOTAL_TOUCHES
		LTGTN_STT_DC
		FLG_TYP_DC
		NCCI_INJ_TYP_DC
		JURIS_STATE_DC
		BNFT_SUSP_DC
		CLM_STLD_BY_LUMP_SUM_IN
		SGMNT_DC
		SPCL_INVSTN_UNT_ESCL_DC
		LOSS_CAUS_DC
		SPCL_INVSTN_UNT_STT_DC
		INJ_PRMIS_IN
		INSD_PNL_EXST_IN
		FRTH_TRTMT_REQR_IN
		OTHR_CARR_INVLV_IN
		INSD_FLT_TYP_DC
		INJ_REG_JOB_IN
		SF_EQP_USD_IN
		HEIGHT
		WGT_NR
		BMI
		BNFT_CMPL_RSN_DC
		SF_EQP_PRVD_IN
		PHYS_RSTRC_IN
		EXPRS_CLM_IN
		FRST_NOTIC_SUIT_IN
		VCTNL_RHAB_INCL_INDEM_IN
		INIT_TRTMT_DC
		MOD_DUTY_AVLB_WRK_IN
		PRIOR_TRTMT_EXST_IN
		MED_TRTMT_TYP_DC
		EXPRS_PA_IN
		RTN_TO_MOD_WRK_IN
		MRTL_STT_DC
		EMPT_INJ_IN
		NCCI_FRDLNT_CLM_DC
		DBTC_IN
		INCID_RPT_ONLY_IN
		EMPR_QUES_VLDTY_IN
		DRG_INVLV_DC
		PRE_EXIST_COND_IN
		MECH_DFCT_INVLV_IN
		CORP_REFL_DG_BRN_IN
		NCCI_LOSS_TYP_DC
		WAIT_PRD_MEET_IN
		ISO_KNW_IN
		CORP_REFL_OTHR_IN
		RTN_TO_WORK_ACTL_IN
		NCCI_RCVRY_TYP_DC
		AGNT_CNTC_IN
		RTN_TO_WRK_SAME_EMPR_IN
		USF_ACT_INVLV_IN
		HTN_IN
		CORP_REFL_WHL_BOSY_IN
		EMPR_PRVD_MOD_DUTY_IN
		DPRS_IN
		PRIOR_MED_EXST_IN
		CONCR_EMPT_DC
		CORP_REFL_PRLYS_IN
		AGNT_CNCRN_IN
		EXPRS_DRP_IN
		CORP_REFL_FTLY_IN
		MM_indic
		JDG_UNSTSFD_IN
		AGNT_NOT_CNTC_RSN_DC
		CORP_REFL_EMPR_LIAB_EXPSR_IN
		HAZ_WST_INVLV_IN
		RCVRY_COND_TYP_DC
		BAD_FAITH_CLM_IN
		AGE_CURR
		PRIM_BODY_PART
		;
	run;

/* scrub data further based on EDA */

data wc_wpc_scrubbed; set wc_wpc_trimmed;

	if EMPT_INJ_IN = "Y" then EMPT_INJ = 1;
		ELSE EMPT_INJ = 0;

	IF FRST_NOTIC_SUIT_IN = 'Y' THEN FRST_NOTIC_SUIT = 1;
		ELSE FRST_NOTIC_SUIT = 0;

	IF FLG_TYP_DC IN ('IsFlagged' 'WasFlagged') then FLG_TYP = 1;
		ELSE FLG_TYP = 0;

	IF FRTH_TRTMT_REQR_IN = 'Y' THEN FRTH_TRTMT_REQR = 1;
		ELSE FRTH_TRTMT_REQR = 0;

	IF HAZ_WST_INVLV_IN = 'Y' THEN HAZ_WST_INVLV = 1;
		ELSE HAZ_WST_INVLV = 0;

	IF INCID_RPT_ONLY_IN = 'Y' THEN INCID_RPT_ONLY = 1;
		ELSE INCID_RPT_ONLY = 0;

	IF INJ_PRMIS_IN = 'Y' THEN INJ_PRMIS = 1;
		ELSE INJ_PRMIS = 0;

	IF INJ_REG_JOB_IN = 'Y' THEN INJ_REG_JOB = 1;
		ELSE INJ_REG_JOB = 0;

	IF ISO_KNW_IN = 'Y' THEN ISO_KNW = 1;
		ELSE ISO_KNW = 0;

	IF MOD_DUTY_AVLB_WRK_IN = 'Y' THEN MOD_DUTY_AVLB_WRK = 1;
		ELSE MOD_DUTY_AVLB_WRK = 0;

	IF SF_EQP_PRVD_IN = 'Y' THEN SF_EQP_PRVD = 1;
		ELSE SF_EQP_PRVD = 0;

	IF SF_EQP_USD_IN = 'Y' THEN SF_EQP_USD = 1;
		ELSE SF_EQP_USD = 0;

	IF SGMNT_DC = 'WorkersCompMedOnly' THEN SGMNT_MEDONLY = 1;
		ELSE SGMNT_MEDONLY = 0;

	IF SGMNT_DC IN('WorkersCompLostTime' 'WorkersCompEmployerLiab') THEN SGMNT_INDEMNITY = 1;
		ELSE SGMNT_INDEMNITY = 0;

	/* ISS Investigation */
	IF SPCL_INVSTN_UNT_STT_DC = 'NoISSReferral' then ISS_NOREF = 1;
		else ISS_NOREF = 0;

	IF SPCL_INVSTN_UNT_STT_DC = 'ReviewForPotentialFraud' then ISS_REVIEW = 1;
		else ISS_REVIEW = 0;

	IF SPCL_INVSTN_UNT_STT_DC = 'UnderInvestigationWithISS' then ISS_INVESTIGATE = 1;
		else ISS_INVESTIGATE = 0;

	IF SPCL_INVSTN_UNT_STT_DC IN('UnderInvestigationWithISS', 'ReviewForPotentialFraud') then ISS_INVOLVE = 1;
		else ISS_INVOLVE = 0;

	/*INSD_FLT_TYP_DC */

	IF INSD_FLT_TYP_DC = 'CompleteFault' then INSD_FLT_COMPLETE = 1;
		else INSD_FLT_COMPLETE = 0;

	IF INSD_FLT_TYP_DC = 'FaultUnknown' then INSD_FLT_UNK = 1;
		else INSD_FLT_UNK = 0;

	IF INSD_FLT_TYP_DC = 'Contributory' then INSD_FLT_CONTRIB = 1;
		else INSD_FLT_CONTRIB = 0;

	IF INSD_FLT_TYP_DC = 'Comparative' then INSD_FLT_COMPARATIVE = 1;
		else INSD_FLT_COMPARATIVE = 0;

	IF INSD_FLT_TYP_DC = 'PureComparative' then INSD_FLT_PURECOMPARATIVE = 1;
		else INSD_FLT_PURECOMPARATIVE = 0;

	IF INSD_FLT_TYP_DC IN('CompleteFault' 'FaultUnknown' 'Contributory' 'Comparative' 'PureComparative') then INSD_FLT = 1;
		else INSD_FLT = 0;


	/*JURIS STATE*/

	IF JURIS_STATE_DC = 'PA' then JURIS_STATE_PA = 1;
		else JURIS_STATE_PA = 0;

	IF JURIS_STATE_DC = 'VA' then JURIS_STATE_VA = 1;
		else JURIS_STATE_VA = 0;

	IF JURIS_STATE_DC = 'MD' then JURIS_STATE_MD = 1;
		else JURIS_STATE_MD = 0;

	IF JURIS_STATE_DC = 'NY' then JURIS_STATE_NY = 1;
		else JURIS_STATE_NY = 0;

	IF JURIS_STATE_DC = 'WV' then JURIS_STATE_WV = 1;
		else JURIS_STATE_WV = 0;

	IF JURIS_STATE_DC = 'WI' then JURIS_STATE_WI = 1;
		else JURIS_STATE_WI = 0;

	IF JURIS_STATE_DC = 'NC' then JURIS_STATE_NC = 1;
		else JURIS_STATE_NC = 0;

	IF JURIS_STATE_DC = 'TN' then JURIS_STATE_TN = 1;
		else JURIS_STATE_TN = 0;

	IF JURIS_STATE_DC = 'IL' then JURIS_STATE_IL = 1;
		else JURIS_STATE_IL = 0;

	IF JURIS_STATE_DC = 'IN' then JURIS_STATE_IN = 1;
		else JURIS_STATE_IN = 0;

	IF JURIS_STATE_DC = 'DC' then JURIS_STATE_WASHDC = 1;
		else JURIS_STATE_WASHDC = 0;

	IF JURIS_STATE_DC = 'KY' then JURIS_STATE_KY = 1;
		else JURIS_STATE_KY = 0;

	IF JURIS_STATE_DC IN ('PA' 'VA' 'MD' 'NY' 'WV' 'WI' 'NC' 'TN' 'IL' 'IN' 'DC' 'KY') then JURIS_STATE_OTHER = 0;
		else JURIS_STATE_OTHER = 1;

	IF LTGTN_STT_DC IN  ('LitigationComplete' 'InLitigation') then LEGAL_IND = 1;
		else LEGAL_IND = 0;

	/* LOSS CAUSE */
	IF LOSS_CAUS_DC = 'FallSlipOrTripInjury' then LOSS_CAUSE_FALLSLIPTRIP = 1;
		else LOSS_CAUSE_FALLSLIPTRIP = 0;

	IF LOSS_CAUS_DC = 'CutPunctureScrapeInjured' then LOSS_CAUSE_CUTSCRAPE = 1;
		else LOSS_CAUSE_CUTSCRAPE = 0;

	IF LOSS_CAUS_DC = 'StrainOrInjuryBy' then LOSS_CAUSE_STRAIN = 1;
		else LOSS_CAUSE_STRAIN = 0;

	IF LOSS_CAUS_DC = 'StruckOrInjuredBy' then LOSS_CAUSE_STRUCK = 1;
		else LOSS_CAUSE_STRUCK = 0;

	IF LOSS_CAUS_DC = 'MiscellaneousCauses' then LOSS_CAUSE_MISC = 1;
		else LOSS_CAUSE_MISC = 0;

	IF LOSS_CAUS_DC = 'CaughtInUnderOrBetween' then LOSS_CAUSE_CAUGHT_IN_OR_BETWEEN = 1;
		else LOSS_CAUSE_CAUGHT_IN_OR_BETWEEN = 0;

	IF LOSS_CAUS_DC = 'MotorVehicle' then LOSS_CAUSE_VEH = 1;
		else LOSS_CAUSE_VEH = 0;

	IF LOSS_CAUS_DC = 'StrikingAgainstSteppingOn' then LOSS_CAUSE_STRIKE = 1;
		else LOSS_CAUSE_STRIKE = 0;

	IF LOSS_CAUS_DC = 'BurnScaldHeatColdExposure' then LOSS_CAUSE_BURN = 1;
		else LOSS_CAUSE_BURN = 0;

	IF LOSS_CAUS_DC = 'RubbedOrAbradedBy' then LOSS_CAUSE_RUBBED = 1;
		else LOSS_CAUSE_RUBBED = 0;

	IF CONCR_EMPT_DC = 'Y' then CONCR_EMPT = 1;
		else CONCR_EMPT = 0;

	IF DRG_INVLV_DC = 'Y' then DRG_INVLV = 1;
		else DRG_INVLV = 0;

	IF SPCL_INVSTN_UNT_ESCL_DC = 'Y' THEN ISS_ESCALATE = 1;
		else ISS_ESCALATE = 0;

	IF BAD_FAITH_CLM_IN = 'Y' THEN BAD_FAITH_CLM = 1;
		else BAD_FAITH_CLM = 0;

	IF CORP_REFL_DG_BRN_IN = 'Y' THEN CORP_REFL_DG_BRN = 1;
		else CORP_REFL_DG_BRN = 0;

	IF CORP_REFL_EMPR_LIAB_EXPSR_IN = 'Y' THEN CORP_REFL_EMPR_LIAB_EXPSR = 1;
		else CORP_REFL_EMPR_LIAB_EXPSR = 0;

	IF CORP_REFL_FTLY_IN = 'Y' THEN CORP_REFL_FTLY = 1;
		else CORP_REFL_FTLY = 0;

	IF CORP_REFL_OTHR_IN = 'Y' THEN CORP_REFL_OTHR = 1;
		else CORP_REFL_OTHR = 0;

	IF CORP_REFL_PRLYS_IN = 'Y' THEN CORP_REFL_PRLYS = 1;
		else CORP_REFL_PRLYS = 0;

	/* INITIAL TREATMENT */
	IF INIT_TRTMT_DC = 'MinorClinic' THEN INIT_TRTMT_MINORCLINIC = 1;
		else INIT_TRTMT_MINORCLINIC = 0;

	IF INIT_TRTMT_DC = 'EmergencyEvaluation' THEN INIT_TRTMT_EMERGENCY = 1;
		else INIT_TRTMT_EMERGENCY = 0;

	IF INIT_TRTMT_DC = 'NoMedicalTreatment' THEN INIT_TRTMT_NONE = 1;
		else INIT_TRTMT_NONE = 0;

	IF INIT_TRTMT_DC = 'Hospitalization' THEN INIT_TRTMT_HOSPITAL = 1;
		else INIT_TRTMT_HOSPITAL = 0;

	IF INIT_TRTMT_DC = 'MinorOnsite' THEN INIT_TRTMT_MINORONSITE = 1;
		else INIT_TRTMT_MINORONSITE = 0;

	IF INIT_TRTMT_DC = 'Future' THEN INIT_TRTMT_FUTURE = 1;
		else INIT_TRTMT_FUTURE = 0;

	IF OTHR_CARR_INVLV_IN = 'Y' THEN OTHR_CARR_INVLV = 1;
		else OTHR_CARR_INVLV = 0;

	IF INSD_PNL_EXST_IN = 'Y' THEN INSD_PNL_EXST = 1;
		else INSD_PNL_EXST = 0;

	IF PRIOR_MED_EXST_IN = 'Y' THEN PRIOR_MED_EXST = 1;
		else PRIOR_MED_EXST = 0;

	IF PRIOR_TRTMT_EXST_IN = 'Y' THEN PRIOR_TRTMT_EXST = 1;
		else PRIOR_TRTMT_EXST = 0;

	IF WAIT_PRD_MEET_IN = 'Y' THEN WAIT_PRD_MEET = 1;
		else WAIT_PRD_MEET = 0;

	/* NCCI INJ TYPE */
	IF NCCI_INJ_TYP_DC = 'MedicalOnly' THEN NCCI_INJ_TYP_MEDONLY = 1;
		else NCCI_INJ_TYP_MEDONLY = 0;

	IF NCCI_INJ_TYP_DC = 'TemporaryInjury' THEN NCCI_INJ_TYP_TEMPORARYINJ = 1;
		else NCCI_INJ_TYP_TEMPORARYINJ = 0;

	IF NCCI_INJ_TYP_DC = 'PermanentPartlDisability' THEN NCCI_INJ_TYP_PERMPARTIAL = 1;
		else NCCI_INJ_TYP_PERMPARTIAL = 0;

	IF NCCI_INJ_TYP_DC = 'Death' THEN NCCI_INJ_TYP_DEATH = 1;
		else NCCI_INJ_TYP_DEATH = 0;

	IF NCCI_INJ_TYP_DC = 'PermanentTotalDisability' THEN NCCI_INJ_TYP_PERMTOTAL = 1;
		else NCCI_INJ_TYP_PERMTOTAL = 0;

	IF NCCI_INJ_TYP_DC = 'ContractMedical' THEN NCCI_INJ_TYP_CONTRACTMED = 1;
		else NCCI_INJ_TYP_CONTRACTMED = 0;

	IF NCCI_LOSS_TYP_DC = 'Trauma' THEN NCCI_LOSS_TYP_TRAUMA = 1;
		else NCCI_LOSS_TYP_TRAUMA = 0;

	IF NCCI_LOSS_TYP_DC = 'CumltvInjryOthrThnDisease' THEN NCCI_LOSS_TYP_CUMULATIVE = 1;
		else NCCI_LOSS_TYP_CUMULATIVE = 0;

	IF NCCI_LOSS_TYP_DC = 'OccupationalDisease' THEN NCCI_LOSS_TYP_DISEASE = 1;
		else NCCI_LOSS_TYP_DISEASE = 0;

	IF VCTNL_RHAB_INCL_INDEM_IN = 'Y' THEN VCTNL_RHAB_INCL_INDEM = 1;
		else VCTNL_RHAB_INCL_INDEM = 0;

	IF MECH_DFCT_INVLV_IN = 'Y' THEN MECH_DFCT_INVLV = 1;
		else MECH_DFCT_INVLV = 0;

	IF USF_ACT_INVLV_IN = 'Y' THEN USF_ACT_INVLV = 1;
		else USF_ACT_INVLV = 0;

	IF AGNT_CNCRN_IN = 'Y' THEN AGNT_CNCRN = 1;
		else AGNT_CNCRN = 0;

	IF AGNT_CNTC_IN = 'Y' THEN AGNT_CNTC = 1;
		else AGNT_CNTC = 0;

	IF EMPR_PRVD_MOD_DUTY_IN = 'Y' THEN EMPR_PRVD_MOD_DUTY = 1;
		else EMPR_PRVD_MOD_DUTY = 0;

	/* MEDICAL TREATMENT TYPE */
	IF MED_TRTMT_TYP_DC = 'ErTreated&Released' THEN MED_TRTMT_TYP_ER = 1;
		else MED_TRTMT_TYP_ER = 0;

	IF MED_TRTMT_TYP_DC = 'EmergencyCare' THEN MED_TRTMT_TYP_EMERGENCYCARE = 1;
		else MED_TRTMT_TYP_EMERGENCYCARE = 0;

	IF MED_TRTMT_TYP_DC = 'PrimaryCarePhysician' THEN MED_TRTMT_TYP_PCP = 1;
		else MED_TRTMT_TYP_PCP = 0;

	IF MED_TRTMT_TYP_DC = 'Orthopedic' THEN MED_TRTMT_TYP_ORTHO = 1;
		else MED_TRTMT_TYP_ORTHO = 0;

	IF MED_TRTMT_TYP_DC = 'XRay' THEN MED_TRTMT_TYP_XRAY = 1;
		else MED_TRTMT_TYP_XRAY = 0;

	IF MED_TRTMT_TYP_DC = 'Hospitalized' THEN MED_TRTMT_TYP_HOSPITALIZED = 1;
		else MED_TRTMT_TYP_HOSPITALIZED = 0;

	IF MED_TRTMT_TYP_DC IN ('Other' 'MultipleTreatments' 'Chiropractor' 'Surgery' 'PhysicalTherapy' 'MagneticResonanceImaging' 'Injections' 'Neurologic' 'PsychCounseling' 'Rehab' 'Acupuncture') THEN MED_TRTMT_TYP_OTHER = 1;
		else MED_TRTMT_TYP_OTHER = 0;

	IF RTN_TO_MOD_WRK_IN = 'Hospitalized' THEN RTN_TO_MOD_WRK = 1;
		else RTN_TO_MOD_WRK = 0;

	/* BENEFIT SUSPENSION */
	IF BNFT_CMPL_RSN_DC = 'FullSuspension' THEN BNFT_CMPL_RSN_FULLSUSPENSION = 1;
		else BNFT_CMPL_RSN_FULLSUSPENSION = 0;

	IF BNFT_CMPL_RSN_DC = 'CompletedWthoutSuspension' THEN BNFT_CMPL_RSN_COMPWOSUSPENSION = 1;
		else BNFT_CMPL_RSN_COMPWOSUSPENSION = 0;

	IF BNFT_CMPL_RSN_DC = 'PartialSuspension' THEN BNFT_CMPL_RSN_PARTIALSUSPENSION = 1;
		else BNFT_CMPL_RSN_PARTIALSUSPENSION = 0;

	IF BNFT_CMPL_RSN_DC in('PartialSuspension', 'FullSuspension') THEN BNFT_CMPL_RSN_SUSPENSION = 1;
		else BNFT_CMPL_RSN_SUSPENSION = 0;

	IF BNFT_SUSP_DC = 'RTWorMedicallyDetermndRTW' THEN BNFT_SUSP_RTW = 1;
		else BNFT_SUSP_RTW = 0;

	IF BNFT_SUSP_DC = 'BenefitsNotSuspended' THEN BNFT_SUSP_NOTSUSPENDED = 1;
		else BNFT_SUSP_NOTSUSPENDED = 0;

	IF BNFT_SUSP_DC = 'DirectedbyJurisdiction' THEN BNFT_SUSP_JURIS = 1;
		else BNFT_SUSP_JURIS = 0;

	IF BNFT_SUSP_DC IN ('MedicalNonCompliance' 'AdministrativeNonComplnc') THEN BNFT_SUSP_NONCOMPLIANCE = 1;
		else BNFT_SUSP_NONCOMPLIANCE = 0;

	IF BNFT_SUSP_DC = 'BenefitsExhausted' THEN BNFT_SUSP_BENEFITSEXHAUST = 1;
		else BNFT_SUSP_BENEFITSEXHAUST = 0;

	IF BNFT_SUSP_DC = 'PendingAppealJudicialRevw' THEN BNFT_SUSP_PENDINGAPPEAL = 1;
		else BNFT_SUSP_PENDINGAPPEAL = 0;

	IF BNFT_SUSP_DC = 'ClaimantDeath' THEN BNFT_SUSP_DEATH = 1;
		else BNFT_SUSP_DEATH = 0;

	IF BNFT_SUSP_DC = 'PendingSettlementApproval' THEN BNFT_SUSP_PENDINGSETTLEMENT = 1;
		else BNFT_SUSP_PENDINGSETTLEMENT = 0;

	IF BNFT_SUSP_DC = 'ClaimantWhereaboutsUnkn' THEN BNFT_SUSP_WHEREABOUTSUNK = 1;
		else BNFT_SUSP_WHEREABOUTSUNK = 0;

	IF BNFT_SUSP_DC = 'Incarceration' THEN BNFT_SUSP_JAIL = 1;
		else BNFT_SUSP_JAIL = 0;

	IF BNFT_SUSP_DC in('DirectedbyJurisdiction', 'MedicalNonCompliance', 'AdministrativeNonComplnc', 'BenefitsExhausted', 'PendingAppealJudicialRevw', 'ClaimantDeath', 'PendingSettlementApproval', 'ClaimantWhereaboutsUnkn', 'Incarceration') THEN BNFT_SUSP_OTHERREASON = 1;
		else BNFT_SUSP_OTHERREASON = 0;

	IF PHYS_RSTRC_IN = 'Y' THEN PHYS_RSTRC = 1;
		else PHYS_RSTRC = 0;

	IF RTN_TO_WRK_SAME_EMPR_IN = 'Y' THEN RTN_TO_WRK_SAME_EMPR = 1;
		else RTN_TO_WRK_SAME_EMPR = 0;

	IF DBTC_IN = 'Y' THEN DBTC = 1;
		else DBTC = 0;

	IF DPRS_IN = 'Y' THEN DPRS = 1;
		else DPRS = 0;

	IF HTN_IN = 'Y' THEN HTN = 1;
		else HTN = 0;

	if DBTC_IN = 'Y' or HTN_IN = 'Y' or SMKR_IN = 'Y' then COMORBITITIES = 1;
		else COMORBITITIES = 0;

	IF MRTL_STT_DC = 'Single' THEN MRTL_STT_SINGLE = 1;
		else MRTL_STT_SINGLE = 0;

	IF MRTL_STT_DC = 'Married' THEN MRTL_STT_MARRIED = 1;
		else MRTL_STT_MARRIED = 0;

	IF MRTL_STT_DC IN ('UNKNOWN' 'Divorced' 'Widowed' 'Separated' 'CommonLaw') THEN MRTL_STT_OTHER = 1;
		else MRTL_STT_OTHER = 0;

	IF PRIM_BODY_PART = 'UpperExtremities' THEN PRIM_BODY_PART_UPPEREXT = 1;
		else PRIM_BODY_PART_UPPEREXT = 0;

	IF PRIM_BODY_PART = 'LowerExtremities' THEN PRIM_BODY_PART_LOWEREXT = 1;
		else PRIM_BODY_PART_LOWEREXT = 0;

	IF PRIM_BODY_PART = 'Trunk' THEN PRIM_BODY_PART_TRUNK = 1;
		else PRIM_BODY_PART_TRUNK = 0;

	IF PRIM_BODY_PART = 'Head' THEN PRIM_BODY_PART_HEAD = 1;
		else PRIM_BODY_PART_HEAD = 0;

	IF PRIM_BODY_PART = 'MultipleBodyParts' THEN PRIM_BODY_PART_MULTIPLE = 1;
		else PRIM_BODY_PART_MULTIPLE = 0;

	IF PRIM_BODY_PART = 'Neck' THEN PRIM_BODY_PART_NECK = 1;
		else PRIM_BODY_PART_NECK = 0;

	IF PRIM_BODY_PART in('Neck' 'Head')THEN PRIM_BODY_PART_NECKHEAD = 1;
		else PRIM_BODY_PART_NECKHEAD = 0;

	IF MM_indic = 'Y' THEN MIDDLE_MARKET = 1;
		else MIDDLE_MARKET = 0;

RUN;

DATA wc_wpc_scrubbed_for_scoring; set wc_wpc_scrubbed;
	keep
	CLM_NR
	TOTAL_TOUCHES
/*	EMPT_INJ*/
/*	FRST_NOTIC_SUIT*/
/*	FLG_TYP*/
	FRTH_TRTMT_REQR
/*	HAZ_WST_INVLV*/
	INCID_RPT_ONLY
	INJ_PRMIS
	INJ_REG_JOB
/*	ISO_KNW*/
/*	MOD_DUTY_AVLB_WRK*/
/*	SF_EQP_PRVD*/
/*	SF_EQP_USD*/
/*	SGMNT_MEDONLY*/
/*	SGMNT_INDEMNITY*/
	ISS_INVOLVE
/*	ISS_NOREF*/
/*	ISS_REVIEW*/
/*	ISS_INVESTIGATE*/
/*	INSD_FLT*/
/*	INSD_FLT_COMPLETE*/
/*	INSD_FLT_UNK*/
/*	INSD_FLT_CONTRIB*/
/*	INSD_FLT_COMPARATIVE*/
/*	INSD_FLT_PURECOMPARATIVE*/
	JURIS_STATE_PA
	JURIS_STATE_VA
	JURIS_STATE_MD
	JURIS_STATE_NY
	JURIS_STATE_WV
	JURIS_STATE_WI
	JURIS_STATE_NC
	JURIS_STATE_TN
	JURIS_STATE_IL
	JURIS_STATE_IN
	JURIS_STATE_WASHDC
/*	JURIS_STATE_OTHER*/
	LEGAL_IND
	LOSS_CAUSE_FALLSLIPTRIP
	LOSS_CAUSE_CUTSCRAPE
	LOSS_CAUSE_STRAIN
/*	LOSS_CAUSE_STRUCK*/
/*	LOSS_CAUSE_MISC*/
/*	LOSS_CAUSE_CAUGHT_IN_OR_BETWEEN*/
	LOSS_CAUSE_VEH
/*	LOSS_CAUSE_STRIKE*/
/*	LOSS_CAUSE_BURN*/
/*	LOSS_CAUSE_RUBBED*/
/*	CONCR_EMPT*/
/*	DRG_INVLV*/
/*	ISS_ESCALATE*/
/*	BAD_FAITH_CLM*/
/*	CORP_REFL_DG_BRN*/
/*	CORP_REFL_EMPR_LIAB_EXPSR*/
/*	CORP_REFL_FTLY*/
/*	CORP_REFL_OTHR*/
	CORP_REFL_PRLYS
/*	INIT_TRTMT_MINORCLINIC*/
/*	INIT_TRTMT_EMERGENCY*/
/*	INIT_TRTMT_NONE*/
/*	INIT_TRTMT_HOSPITAL*/
/*	INIT_TRTMT_MINORONSITE*/
/*	INIT_TRTMT_FUTURE*/
/*	OTHR_CARR_INVLV*/
	INSD_PNL_EXST
/*	PRIOR_MED_EXST*/
	PRIOR_TRTMT_EXST
/*	WAIT_PRD_MEET*/
	NCCI_INJ_TYP_MEDONLY
	NCCI_INJ_TYP_TEMPORARYINJ
	NCCI_INJ_TYP_PERMPARTIAL
/*	NCCI_INJ_TYP_DEATH*/
	NCCI_INJ_TYP_PERMTOTAL
/*	NCCI_INJ_TYP_CONTRACTMED*/
	NCCI_LOSS_TYP_TRAUMA
	NCCI_LOSS_TYP_CUMULATIVE
/*	NCCI_LOSS_TYP_DISEASE*/
	VCTNL_RHAB_INCL_INDEM
	MECH_DFCT_INVLV
/*	USF_ACT_INVLV*/
/*	AGNT_CNCRN*/
/*	AGNT_CNTC*/
/*	EMPR_PRVD_MOD_DUTY*/
/*	MED_TRTMT_TYP_ER*/
/*	MED_TRTMT_TYP_EMERGENCYCARE*/
/*	MED_TRTMT_TYP_PCP*/
/*	MED_TRTMT_TYP_ORTHO*/
/*	MED_TRTMT_TYP_XRAY*/
/*	MED_TRTMT_TYP_HOSPITALIZED*/
/*	MED_TRTMT_TYP_OTHER*/
/*	RTN_TO_MOD_WRK*/
/*	BNFT_CMPL_RSN_SUSPENSION*/
/*	BNFT_CMPL_RSN_FULLSUSPENSION*/
/*	BNFT_CMPL_RSN_COMPWOSUSPENSION*/
/*	BNFT_CMPL_RSN_PARTIALSUSPENSION*/
/*	BNFT_SUSP_RTW*/
/*	BNFT_SUSP_NOTSUSPENDED*/
/*	BNFT_SUSP_OTHERREASON*/
/*	BNFT_SUSP_JURIS*/
/*	BNFT_SUSP_NONCOMPLIANCE*/
/*	BNFT_SUSP_BENEFITSEXHAUST*/
/*	BNFT_SUSP_PENDINGAPPEAL*/
/*	BNFT_SUSP_DEATH*/
/*	BNFT_SUSP_PENDINGSETTLEMENT*/
/*	BNFT_SUSP_WHEREABOUTSUNK*/
/*	BNFT_SUSP_JAIL*/
	PHYS_RSTRC
/*	RTN_TO_WRK_SAME_EMPR*/
/*	DBTC*/
/*	DPRS*/
/*	HTN*/
/*	COMORBITITIES*/
	BMI
/*	PRIM_BODY_PART_UPPEREXT*/
/*	PRIM_BODY_PART_LOWEREXT*/
	PRIM_BODY_PART_NECKHEAD
	PRIM_BODY_PART_TRUNK
/*	PRIM_BODY_PART_HEAD*/
	PRIM_BODY_PART_MULTIPLE
/*	PRIM_BODY_PART_NECK*/
	MIDDLE_MARKET
	AGE_CURR
	;
run;

PROC IMPORT DATAFILE='/ere/local/shared/actuarial/Share/Claims/WPC/Workers Comp/WorkloadWC.xlsx'
	DBMS=XLSX
	REPLACE
	OUT=workload_wc;
	GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE='/ere/local/shared/actuarial/Share/Claims/WPC/Adj Prod by WComp_Template.xlsx'
	DBMS=XLSX
	REPLACE
	OUT=wc_hr;
	GETNAMES=YES;
RUN;

data workload_wc; set workload_wc;
	where Status in ('New', 'Completed');
	PayPeriodEnding = input(PayPeriodEnd, $20.);
run;

data wc_hr; set wc_hr;
	if Adj_position = "Workers Compensation Spct" then Adj_title = "Workers Comp Specialist";
		else Adj_title = Adj_position;
run;

/*proc sql;*/
/*	create table wc_hr1 as*/
/*	select distinct Adj Number, Adj Position, Adjuster Team Branch as Adj_Team*/
/*	from wc_hr;*/
/*quit;*/

proc sql;
	create table wc_hr2 as
	select distinct Adj_Number as Adj_Number, Adjuster_Team_Branch as Adj_Team
	from wc_hr;
quit;

proc sql;
	create table workload_wc1 as
	select a.*, b.*
	from workload_wc as a left join wc_hr2 as b
	on a.AdjNu = b.Adj_Number;
quit;

data workload_wc2; set workload_wc1;
	where Adj_Team is not null;
run;
data workload_wc2;
	set workload_wc2;
	RENAME 'Adjuster Work Group'n =Adjuster_Work_Group;
run;

proc sql;
	create table wc_wpc_scrubbed_for_scoring1 as
	select a.*, b.ClaimKey, b.AdjNu, b.Status, b.Adj_Team, b.Adjuster_Work_Group, b.PayPeriodEnd 
	from wc_wpc_scrubbed_for_scoring as a left join workload_wc2 as b
	on a.CLM_NR = b.ClaimNu;
quit;

/*"Adjuster Work Group"n as */

data wc_wpc_scrubbed_for_scoring1; set wc_wpc_scrubbed_for_scoring1;
	where CLaimKey ne "";
run;

/* Save the dataset for future analysis */
data WC.WC_WPC_for_scoring; set wc_wpc_scrubbed_for_scoring1;
	run;
/**/
/*proc export data=wc_wpc_scrubbed_for_scoring1*/
/*	outfile="/ere/local/shared/actuarial/Share/Claims/WPC/TESTING 2/Workers Comp/2024/05-29-2024/WC_WPC_for_scoring.csv"*/
/*    dbms=csv*/
/*    replace;*/
/*run;*/
/*"/ere/local/shared/actuarial/Modeling/Claims/Resource Capacity/Workers Comp Adjuster/Data/WC_WPC_for_scoring_&date..csv"*/

%macro ExportCustom();

%if &flag. = 1 %then %do;
	PROC EXPORT DATA= wc_wpc_scrubbed_for_scoring1
		OUTFILE= "/ere/local/shared/actuarial/Share/Claims/WPC/Workers Comp/executable/Output/WC_WPC_for_scoring.csv"
		DBMS=CSV REPLACE;
	RUN;
%end;
%else %do;
	PROC EXPORT DATA= wc_wpc_scrubbed_for_scoring1
		OUTFILE= "&output_path_csv/WC_WPC_for_scoring.csv"
		DBMS=CSV REPLACE;
	RUN;
/*	PROC EXPORT DATA= wc_hr2*/
/*		OUTFILE= "&output_path_csv/wc_hr2.csv"*/
/*		DBMS=CSV REPLACE;*/
/*	RUN;*/
%end;

%mend ExportCustom;

%ExportCustom();

