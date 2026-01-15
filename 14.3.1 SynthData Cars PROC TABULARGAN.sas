
data casuser.cars;
 set sashelp.cars;
run;


proc tabularGAN data = casuser.cars  seed = 42   numSamples = 500;

 input type drivetrain/level = nominal;
 input invoice horsepower mpg_city mpg_highway weight;

    gmm alpha = 1 maxClusters = 10 seed = 42 VB(maxVbIter = 3);
    aeOptimization ADAM LearningRate = 0.0001 numEpochs = 3;
    ganOptimization ADAM(beta1 = 0.55 beta2 = 0.95) numEpochs = 5;
    train embeddingDim = 32 miniBatchSize = 300 useOrigLevelFreq;

    saveState rStore = casuser.ASTORE_CarsSynth_TabGAN;
    output out = casuser.CarsSynth_TabGAN;
run; quit;



*** https://documentation.sas.com/doc/en/pgmsascdc/default/casml/casml_smote_syntax04.htm#casml.smote.sample_K;


title sashelp.cars Data;
proc print data=sashelp.cars(obs=10);
 title Original Cars Data;
 var invoice horsepower mpg_city mpg_highway weight;
run;

title Synthetic Cars Data with PROC TABULARGAN;
proc print data=casuser.CarsSynth_TabGAN(obs=10);
 format invoice DOLLAR8. horsepower mpg_city mpg_highway weight 8.;
 var invoice horsepower mpg_city mpg_highway weight;
run;




proc sgplot data=casuser.cars;
title Original Cars Data;
 scatter x=horsepower y=mpg_highway;
run;


proc sgplot data=casuser.CarsSynth_TabGAN;
 title Synthetic Cars Data created with PROC TABULARGAN;
 scatter x=horsepower y=mpg_highway;
run;




ods noproctitle;
proc freq data= casuser.cars ;
 ods select mosaicplot;
title Original Cars Data;
 table type *  drivetrain / plots=(mosaicplot);
run;

ods noproctitle;
proc freq data= casuser.CarsSynth_TabGAN;
 ods select mosaicplot;
 title Synthetic Cars Data created with PROC TABULARGAN;
 table type *  drivetrain / plots=(mosaicplot);
run;


data casuser.Cars800_Base;
 do id = 1 to 800;
   output;
 end;
run;


proc astore;
 score data     = casuser.Cars800_Base
       rstore   = casuser.ASTORE_CarsSynth_TabGAN
       out      = casuser.CarsSynthData_TabGAN800
       copyVars = (_all_)
;
run;

data gdata.CarsSynthData_TabGAN800;
 set casuser.CarsSynthData_TabGAN800;
run;



