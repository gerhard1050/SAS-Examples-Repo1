/*********************************************************************************************************************
 ***  SASHELP.CARS Data
 *********************************************************************************************************************/


title Original Cars Data;
proc print data=sashelp.cars(obs=10);
 var invoice horsepower mpg_city mpg_highway weight;
run;




/*********************************************************************************************************************
 ***  Create Data Generator
 *********************************************************************************************************************/


proc corr data=sashelp.cars out=work.cars_cov cov noprint nocorr;
 var invoice horsepower mpg_city mpg_highway weight;
run;


/*********************************************************************************************************************
 ***  Use Generator to Create Synthetic Data
 *********************************************************************************************************************/

proc simnormal data=work.cars_cov(type=cov)
               out = work.CarsSynth_Simnormal
               numreal= 500
               seed = 1;
  var invoice horsepower mpg_city mpg_highway weight;
run;


/*********************************************************************************************************************
 ***  Show Generated Data
 *********************************************************************************************************************/


title Original Cars Data;
proc print data=sashelp.cars(obs=10);
 var invoice horsepower mpg_city mpg_highway weight;
run;

title Synthetic Cars Data with PROC SIMNORMAL;
proc print data=work.CarsSynth_Simnormal(obs=10);
 format invoice DOLLAR8. horsepower mpg_city mpg_highway weight 8.;
 var invoice horsepower mpg_city mpg_highway weight;
run;




title Original Cars Data;
proc sgplot data=sashelp.cars;
 scatter x=horsepower y=mpg_highway;
run;

title;
title Synthetic Cars Data created with PROC SIMNORMAL;
proc sgplot data=work.CarsSynth_Simnormal;
 scatter x=horsepower y=mpg_highway;
run;





title;

