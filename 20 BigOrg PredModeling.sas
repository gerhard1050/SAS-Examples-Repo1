



/***  0. INIT

cas cas1;
caslib _all_ assign;


data casuser.bigorganics;
 set tundata.bigorganics;
run;



*%let path = "/Users/autges/My Folder/ViyaDemos/Include SAS Programs";
%let path = /export/viya/homes/gerhard.svolba@sas.com/SAS_Files;

***/


/********************************************************
 ***  1. Sample and Partition Data
 ********************************************************/


proc freqtab data=casuser.bigorganics;
 table targetbuy;
run;


proc partition data=casuser.bigorganics
     samppctevt=100 eventprop=0.3 event="1" seed=1 ;
   output out=casuser.bigorganics_smp copyvars=(_all_);
   by targetbuy;
run;

proc freqtab data=casuser.bigorganics_smp;
 table targetbuy;
run;

proc partition data=casuser.bigorganics_smp 
     samppct=70 samppct2=10 partind;
   output out=casuser.bigorganics_smp copyvars=(_all_);
run;

proc contents data=casuser.bigorganics_smp;
run;
proc freqtab data=casuser.bigorganics_smp;
 table _partind_;
run;




/********************************************************
 ***  2. Explore and Modify Data
 ********************************************************/





proc binning data=casuser.bigorganics_smp method=tree;
 target targetbuy      /level=  nominal;
 input DemTVReg /level = nominal;
 output outlevelbinmap=casuser.outlevel;
 code file="&path./BigOrg_TVReg_Binning.sas";
run;

data casuser.bigorganics_smp;
 set casuser.bigorganics_smp;
 %include "&path./BigOrg_TVReg_Binning.sas";
 rename Bin_nom_DemTVReg = DemTVReg_Binned;
run;

proc varreduce data=casuser.bigorganics_smp matrix=COV tech=DSC;
   ods output SelectionSummary=Summary;
   class DemTVReg_Binned  DemGender targetbuy;
   reduce supervised targetbuy =  
          DemAffl DemGender DemAffl PromTime PromSpend DemTVReg_Binned
          / maxiter=15 BIC;
   display 'SelectionSummary' 'SelectedEffects';
run;

proc sgplot data=Summary;
   series x=Iteration  y=BIC;
run;


proc varreduce data=casuser.bigorganics_smp matrix=COV tech=DSC;
   ods output SelectionSummary=Summary;
   class DemTVReg_Binned  DemGender targetbuy;
   reduce supervised targetbuy =  
          DemAffl DemGender DemAffl PromTime PromSpend DemTVReg_Binned
          / maxiter=15 BIC;
   display 'SelectionSummary' 'SelectedEffects';
run;




/********************************************************
 ***  3. Create Models
 ********************************************************/



proc logselect data=casuser.bigorganics_smp;
 partition role=_partind_;

   class DemTVReg_Binned  DemGender ;
 model targetbuy(event="1") =  DemAge DemAffl DemGender DemAffl 
                               PromTime PromSpend DemTVReg_Binned;
 selection method=lasso;

 code file="&path./BigOrg_LR_ScoreCode.sas";

 output out=casuser.bigorganics_smp_LogReg_pred copyvar=(targetbuy _partind_);

run;


proc gradboost data=casuser.bigorganics_smp;
 partition ROLE=_partind_ (TEST='2' TRAIN='1' VALIDATE='0');
 target targetbuy / level = nominal;
 input DemTVReg_Binned  DemGender  / level= nominal;
 input DemAge DemAffl   PromTime PromSpend  / level = interval;

 code file="&path./Cyber_GB_ScoreCode.sas";
 SAVESTATE rstore=CASUSER.BigOrg_GB_Score;

 output out=casuser.bigorganics_smp_GB_pred  copyvar=(_all_);

run;





/********************************************************
 ***  4. Score Fresh Data with the Models
 ********************************************************/



data casuser.bigorganics_smp_Score_LR;
 set casuser.bigorganics_smp;
 %include "&path./BigOrg_LR_ScoreCode.sas";
run;


proc astore ;
 score data=casuser.bigorganics_smp copyvar=(targetbuy _partind_)
       rstore=casuser.BigOrg_GB_Score
       out=casuser.bigorganics_smp_Score_GB;
 *describe rstore=casuser.cyber_astore_gb;
run;



/********************************************************
 ***  5. Register Models to SAS Model Manager
 ********************************************************/



proc registermodel
      name = "BigOrg_LogReg_SASCode"
      description = "LogReg Data Step Code Model from SAS Code"
      data = casuser.bigorganics_smp
      algorithm = LOGISTIC
      function = CLASSIFICATION
      replace;
   project id ='02b58efb-87e1-4011-b9ba-dadc6abd9e31';*name="BigOrganicsDemo" ;*folder="/Model Repositories/DMRepository";
   code file = "&path./BigOrg_LR_ScoreCode.sas";
   target targetbuy / level=binary event="1";
   *assessment;
run;


proc astore;
 download rstore= casuser.BigOrg_GB_Score store="&path./BigOrg_GB_Score.ast";
run;


proc registermodel
      name = "BigOrg_GradBoost_SASCode"
      description = "BigOrganics Gradient Boosting Model"
      data = casuser.bigorganics_smp
      algorithm = GRADBOOST
      function = CLASSIFICATION
      replace;
   project id ='02b58efb-87e1-4011-b9ba-dadc6abd9e31';
   astoremodel store = "&path./BigOrg_GB_Score.ast";
   target targetbuy / level=binary event="1";
   *assessment;
run;


