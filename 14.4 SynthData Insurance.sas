proc smote data=CASUSER.INSURANCE_PREMIUM_HISTORY;
 input InsuranceClass 'Type'n  Campaign InternalPromo PreCovidPeriod /level = nominal;
 input Contracts / type = interval;

 output out=casuser.Insurance_SynthData
 sample numsamples=500 
        EXTRAPOLATIONFACTOR = 0.1 
        K = 7;

run;
 