/*********************************************************************************************************************
 ***  SASHELP.CARS Data
 *********************************************************************************************************************/


title sashelp.cars Data;
proc print data=sashelp.cars(obs=10);
 var invoice horsepower mpg_city mpg_highway weight;
run;


proc sgplot data=sashelp.cars;
 scatter x=horsepower y=mpg_highway;
run;

title;




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
               out = work.synth_cars
			   numreal= 500
			   seed = 1333;
  var invoice horsepower mpg_city mpg_highway weight;
run;


/*********************************************************************************************************************
 ***  Show Generated Data
 *********************************************************************************************************************/



title sashelp.cars Data;
proc print data=sashelp.cars(obs=10);
 var invoice horsepower mpg_city mpg_highway weight;
run;

title Synthetic Cars Data with PROC SIMNORMAL;
proc print data=work.synth_cars(obs=10);
 var invoice horsepower mpg_city mpg_highway weight;
run;


proc sgplot data=work.synth_cars;
 scatter x=horsepower y=mpg_highway;
run;


title;

