cas cas1;
caslib _all_ assign;

proc contents data=casuser.cybersecurity_beth_trn;
run;

data casuser.cybersecurity_beth_cas;
 set casuser.cybersecurity_beth_trn;
/*** reduce length of long text variables
length args2 stackAddresses2 $24.;
 args2 = substr(args,1,24);
 stackAddresses2 = substr(stackAddresses,1,24);
***/

drop stackaddresses args;


*** Create Derived Variables as listed in the paper;

ProcessID_012 = (ProcessID in (0,1,2));
ParentProcessID_012 = (ParentProcessID in (0,1,2));
UserID_LT1000 = (UserID < 1000);

MountNamespace4026531840 = (mountNamespace = 4026531840);

if missing(returnValue) then ReturnValueGrp = .;
else if returnValue < 0 then ReturnValueGrp = -1;
else if returnValue = 0 then ReturnValueGrp = 0;
else                         ReturnValueGrp = 1;


run;



proc freqtab data=casuser.cybersecurity_beth_trn;
 table sus;
run;


/***

proc freqtab data=casuser.cybersecurity_beth_trn;
 table stackaddresses;
run;


***/

proc partition data=casuser.cybersecurity_beth_cas 
     samppctevt=100 eventprop=0.05 event="1" seed=1 ;
   output out=casuser.cybersecurity_beth_smp copyvars=(_all_);
   by sus;
run;


proc freqtab data=casuser.cybersecurity_beth_smp;
 table sus;
run;


proc partition data=casuser.cybersecurity_beth_smp 
     samppct=50 samppct2=25 partind; *** remainging 25% --> VALID;
   output out=casuser.cybersecurity_beth_smp copyvars=(_all_);
run;
*** 1=TRN 0=VLD 2=TST;

proc freqtab data=casuser.cybersecurity_beth_smp;
 table _partind_;
run;


proc contents data=casuser.cybersecurity_beth_cas;
run;





*%let path = "/Users/autges/My Folder/ViyaDemos/Include SAS Programs";
*%let path = /export/pvs/sasdata/homes/autges/IncludeSASCode;
%let path= /export/pvs/sasdata/homes/autges/IncludeSASCode;



proc freqtab data=casuser.cybersecurity_beth_smp;
 table eventname;
run;


proc binning data=casuser.cybersecurity_beth_smp method=tree;

 target sus      /level=  nominal;
 input eventname /level = nominal;

 output outlevelbinmap=casuser.outlevel;
 code file="&path./Cyber_Binning_Eventname.sas";
run;



data casuser.cybersecurity_beth_smp;
 set casuser.cybersecurity_beth_smp;

 %include "&path./Cyber_Binning_Eventname.sas";

 rename Bin_nom_Eventname = Eventname_Binned;
run;





proc varreduce data=casuser.cybersecurity_beth_smp matrix=COV tech=DSC;
   ods output SelectionSummary=Summary;
   class eventName_Binned sus ReturnValueGrp;


   reduce supervised sus =  ParentProcessID_012 argsNum  ProcessID_012  
             ReturnValueGrp MountNamespace4026531840 
            EventName_Binned UserID_LT1000/ maxiter=15 BIC;



   display 'SelectionSummary' 'SelectedEffects';
run;






proc sgplot data=Summary;
   series x=Iteration  y=BIC;
run;







proc logselect data=casuser.cybersecurity_beth_smp;

 partition role=_partind_;
 class eventName_Binned ReturnValueGrp;

 model sus(event="1") =  ParentProcessID_012 argsNum  ProcessID_012  
             ReturnValueGrp MountNamespace4026531840 EventName_Binned UserID_LT1000;
 selection method=lasso;

 code file="&path./Cyber_LR_ScoreCode.sas";

 output out=casuser.cyber_beth_logreg_score pred copyvar=(sus _partind_);
run;





proc gradboost data=casuser.cybersecurity_beth_smp;
 partition ROLE=_partind_ (TEST='2' TRAIN='1' VALIDATE='0');

 target sus / level = nominal;
 input eventName_Binned ReturnValueGrp / level= nominal;
 input ParentProcessID_012 argsNum  ProcessID_012  
              MountNamespace4026531840  UserID_LT1000 / level = interval;

 code file="&path./Cyber_GB_ScoreCode.sas";
 SAVESTATE rstore=CASUSER.Cyber_Astore_GB;

 output out=casuser.cyber_beth_gb_score  copyvar=(sus _partind_);

run;

*** Assess Logreg;

proc format;
 value part_ind 0="Valid" 1="Train" 2="Test";
run;

proc assess data=casuser.cyber_beth_logreg_score ncuts=10 nbins=10;
   var _pred_;
   target sus / event="1" level=nominal;
   *fitstat pvar=p_bad / pevent="bad" ;
   by _PartInd_;
   ods output liftinfo = work.liftinfo_LR rocinfo = work.rocinfo_LR;
run;



proc sgplot data = work.liftinfo_LR;
 title Lift-Chart;
 format _partind_ part_ind.;
 series x=Depth y=lift / group=_partind_;
run;
title;

data work.rocinfo_LR;
 set work.rocinfo_LR;
 Spec_minus1 = 1-specificity;
run;

proc sgplot data = work.rocinfo_LR;
 title ROC-Chart;
 format _partind_ part_ind.;
 series x=Spec_minus1 y=Sensitivity / group=_partind_;
run;
title;



*** Assess GB;



proc assess data=casuser.cyber_beth_GB_score ncuts=10 nbins=10;
   var p_sus1;
   target sus / event="1" level=nominal;
   *fitstat pvar=p_bad / pevent="bad" ;
   by _PartInd_;
   ods output liftinfo = work.liftinfo_GB rocinfo = work.rocinfo_GB;
run;



proc sgplot data = work.liftinfo_GB;
 title Lift-Chart;
 format _partind_ part_ind.;
 series x=Depth y=lift / group=_partind_;
run;
title;

data work.rocinfo_GB;
 set work.rocinfo_GB;
 Spec_minus1 = 1-specificity;
run;

proc sgplot data = work.rocinfo_GB;
 title ROC-Chart;
 format _partind_ part_ind.;
 series x=Spec_minus1 y=Sensitivity / group=_partind_;
run;
title;


**** Scoring;
data casuser.Cyber_Scored_LR;
 set casuser.cybersecurity_beth_smp;
 %include "&path./Cyber_LR_ScoreCode.sas";
run;


proc astore ;
 score data=casuser.cybersecurity_beth_smp copyvar=(sus _partind_)
       rstore=casuser.cyber_astore_gb
       out=casuser.Cyber_Scored_GB;
 *describe rstore=casuser.cyber_astore_gb;
run;

