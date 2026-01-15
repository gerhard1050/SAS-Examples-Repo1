/*********************************************************************************************************************
 ***  Create a copy in CASUSER
 *********************************************************************************************************************/

data casuser.cars;
 set sashelp.cars;
run;

/*********************************************************************************************************************
 ***  Create Synthetic Data with PROC SMOTE
 *********************************************************************************************************************/


proc smote data = casuser.cars seed=1;
 input type drivetrain/level = nominal;
 input invoice horsepower mpg_city mpg_highway weight;
 output out=casuser.CarsSynth_Smote;
 sample numsamples=500 
        EXTRAPOLATIONFACTOR = 0.1 
        K = 7;
run;

/*********************************************************************************************************************
 ***  Validate the Data
 *********************************************************************************************************************/

title sashelp.cars Data;
proc print data=sashelp.cars(obs=10);
 title Original Cars Data;
 var invoice horsepower mpg_city mpg_highway weight;
run;

title Synthetic Cars Data with PROC SMOTE;
proc print data=casuser.CarsSynth_Smote(obs=10);
 format invoice DOLLAR8. horsepower mpg_city mpg_highway weight 8.;
 var invoice horsepower mpg_city mpg_highway weight;
run;

proc sgplot data=casuser.cars;
title Original Cars Data;
 scatter x=horsepower y=mpg_highway;
run;

proc sgplot data=casuser.CarsSynth_Smote;
 title Synthetic Cars Data created with PROC SMOTE;
 scatter x=horsepower y=mpg_highway;
run;


ods noproctitle;
proc freq data= casuser.cars ;
 ods select mosaicplot;
title Original Cars Data;
 table type *  drivetrain / plots=(mosaicplot);
run;

ods noproctitle;
proc freq data= casuser.CarsSynth_Smote;
 ods select mosaicplot;
 title Synthetic Cars Data created with PROC SMOTE;
 table type *  drivetrain / plots=(mosaicplot);
run;


