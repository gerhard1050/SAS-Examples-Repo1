/*--------------------------------------------------------------*
| BIGORGANICS end-to-end example using SAS Viya ML procedures |
| Procedures: PARTITION, VARREDUCE, LOGSELECT, GRADBOOST, ASSESS |
*--------------------------------------------------------------*/

/* Folder to write score code */
*%let path= /export/pvs/sasdata/homes/autges/IncludeSASCode;
%let path = /export/home/users/autges/sas_code; *** CACTUS;

/* (Optional) Inspect target distribution */
proc freqtab data=casuser.BIGORGANICS;
tables TargetBuy;
run;

/*--------------------------------------------------------------*
| 1) Create partitions |
| - First: optional event sampling (kept from your template) |
| - Second: Train/Valid/Test split |
*--------------------------------------------------------------*/

/* If you do NOT want event sampling, skip this block and use
casuser.BIGORGANICS directly in the second PARTITION. */
/***
proc partition data=casuser.BIGORGANICS
samppctevt=100 eventprop=0.05 event="1" seed=1;
output out=casuser.bigorganics_smp copyvars=(_all_);
by TargetBuy;
run;
***/
data casuser.bigorganics_smp;
set casuser.BIGORGANICS;
run;


proc freqtab data=casuser.bigorganics_smp;
tables TargetBuy;
run;

proc partition data=casuser.bigorganics_smp
samppct=50 samppct2=25 partind;
output out=casuser.bigorganics_smp copyvars=(_all_);
run;
/* 1=TRN 0=VLD 2=TST */

proc freqtab data=casuser.bigorganics_smp;
tables _PartInd_;
run;
/*--------------------------------------------------------------*
| 2) Variable reduction (supervised) |
| Adjust predictor lists below to match your BIGORGANICS |
| column names (these are the common ones used in training). |
*--------------------------------------------------------------*/


proc binning data=casuser.bigorganics_smp method=tree;

 target TargetBuy      /level=  nominal;
 input DemCluster /level = nominal;

 output outlevelbinmap=casuser.outlevel;
 code file="&path./BigOrg_Binning_Eventname.sas";
run;



data casuser.bigorganics_smp;
 set casuser.bigorganics_smp;

 %include "&path./BigOrg_Binning_Eventname.sas";

 rename BIN_NOM_DemCluster = DemCluster_Binned;
run;





proc varreduce data=casuser.bigorganics_smp matrix=COV tech=DSC;
ods output SelectionSummary=work.Summary;

/* Categorical predictors */
class DemGender DemReg DemTVReg DemClusterGroup PromClass DemCluster TargetBuy DemCluster_Binned;

/* Supervised reduction: TargetBuy is the target */
reduce supervised TargetBuy =
DemAge PromTime PromSpend PromClass
DemGender DemAffl DemReg DemTVReg DemClusterGroup
DemCluster
/ maxiter=15 BIC;

display 'SelectionSummary' 'SelectedEffects';
run;

proc sgplot data=work.Summary;
series x=Iteration y=BIC;
run;
/*--------------------------------------------------------------*
| 3) Logistic regression with LASSO selection |
*--------------------------------------------------------------*/

proc logselect data=casuser.bigorganics_smp;
partition role=_PartInd_;

class DemGender DemReg DemTVReg DemClusterGroup PromClass DemCluster DemCluster_Binned;

model TargetBuy(event="1") =
DemAge PromTime PromSpend PromClass
DemGender DemAffl DemReg DemTVReg DemClusterGroup
DemCluster DemCluster_Binned;

selection method=stepwise ( slentry=0.1 slstay=0.15);

code file="&path./BigOrganics_LR_ScoreCode.sas";

output out=casuser.bigorganics_logreg_score
pred
copyvar=(ID TargetBuy _PartInd_);
run;




/*--------------------------------------------------------------*
| 4) Gradient boosting |
*--------------------------------------------------------------*/

proc gradboost data=casuser.bigorganics_smp;
partition role=_PartInd_ (TEST='2' TRAIN='1' VALIDATE='0');

target TargetBuy / level=nominal;

/* Categorical inputs */
input DemGender DemReg DemTVReg DemClusterGroup PromClass DemCluster DemCluster_Binned
/ level=nominal;

/* Interval inputs */
input DemAge PromTime PromSpend DemAffl
/ level=interval;

code file="&path./BigOrganics_GB_ScoreCode.sas";
savestate rstore=casuser.BigOrganics_Astore_GB;

output out=casuser.bigorganics_gb_score
copyvar=(ID TargetBuy _PartInd_);
run;
/*--------------------------------------------------------------*
| 5) Assessment (Lift + ROC) |
*--------------------------------------------------------------*/

proc format;
value part_ind 0='Valid' 1='Train' 2='Test';
run;

/* Assess logistic regression */
proc assess data=casuser.bigorganics_logreg_score ncuts=10 nbins=10;
var _pred_;
target TargetBuy / event="1" level=nominal;
by _PartInd_;
ods output liftinfo=work.liftinfo_LR rocinfo=work.rocinfo_LR;
run;

proc sgplot data=work.liftinfo_LR;
title 'Lift Chart (Logistic Regression)';
format _PartInd_ part_ind.;
series x=Depth y=Lift / group=_PartInd_;
run;
title;

data work.rocinfo_LR;
set work.rocinfo_LR;
Spec_minus1 = 1 - Specificity;
run;

proc sgplot data=work.rocinfo_LR;
title 'ROC Chart (Logistic Regression)';
format _PartInd_ part_ind.;
series x=Spec_minus1 y=Sensitivity / group=_PartInd_;
run;
title;

/* Assess gradient boosting */
proc assess data=casuser.bigorganics_gb_score ncuts=10 nbins=10;
/* For a nominal binary target, GB commonly outputs P_TargetBuy1 */
var P_TargetBuy1;
target TargetBuy / event="1" level=nominal;
by _PartInd_;
ods output liftinfo=work.liftinfo_GB rocinfo=work.rocinfo_GB;
run;

proc sgplot data=work.liftinfo_GB;
title 'Lift Chart (Gradient Boosting)';
format _PartInd_ part_ind.;
series x=Depth y=Lift / group=_PartInd_;
run;
title;

data work.rocinfo_GB;
set work.rocinfo_GB;
Spec_minus1 = 1 - Specificity;
run;

proc sgplot data=work.rocinfo_GB;
title 'ROC Chart (Gradient Boosting)';
format _PartInd_ part_ind.;
series x=Spec_minus1 y=Sensitivity / group=_PartInd_;
run;
title;
