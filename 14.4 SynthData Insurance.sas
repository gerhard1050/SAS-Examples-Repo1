data CASUSER.INS_PREMIUM_HISTORY_Features;
 set CASUSER.INSURANCE_PREMIUM_HISTORY;
 Year = Year(date);
 month = month(date);
 where type = "New Sales" and InsuranceClass in ("Legal Protection");
run;


proc smote data=CASUSER.INS_PREMIUM_HISTORY_Features;
 input InsuranceClass 'Type'n  Campaign InternalPromo PreCovidPeriod Month/level = nominal;
 input date Contracts Year/ level = interval;

 output out=casuser.Insurance_Premium_SynthData;
 sample numsamples=500 
        EXTRAPOLATIONFACTOR = 0.1 
        K = 7;

run;

proc sort data=casuser.Insurance_Premium_SynthData
          out = work.Insurance_Premium_SynthData;
by type insuranceclass date;
run;

proc timeseries data = work.Insurance_Premium_SynthData
                out = work.Insurance_Premium_SynthData_avg;
 id date  interval = month;
 var contracts / accumulate=average setmiss=last;
 by type insuranceclass;
run;

title Original Data;
proc sgplot data=casuser.INSURANCE_PREMIUM_HISTORY;
 series x=date y=contracts;
 yaxis min=10000 max=40000;
 where type = "New Sales" and InsuranceClass in ("Legal Protection");
 by insuranceclass;
run;
title;
title Synthetic Data; 
proc sgplot data=work.Insurance_Premium_SynthData_avg;
 series x=date y=contracts;
 yaxis min=10000 max=40000;
 where type = "New Sales" and InsuranceClass in ("Legal Protection");
 by insuranceclass;
run;
run;
