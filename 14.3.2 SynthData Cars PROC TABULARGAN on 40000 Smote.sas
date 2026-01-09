data casuser.cars;
 set sashelp.cars;
run;


proc smote data = casuser.cars seed=1;
 input type drivetrain/level = nominal;
 input invoice horsepower mpg_city mpg_highway weight;
 output out=casuser.CarsSynth_Smote_40000;
 sample numsamples=40000 
        EXTRAPOLATIONFACTOR = 0.1 
        K = 7;
run;



proc tabularGAN data = casuser.CarsSynth_Smote_40000  seed = 42   numSamples = 500;

 input type drivetrain/level = nominal;
 input invoice horsepower mpg_city mpg_highway weight;

    gmm alpha = 1 maxClusters = 10 seed = 42 VB(maxVbIter = 30);
    aeOptimization ADAM LearningRate = 0.0001 numEpochs = 3;
    ganOptimization ADAM(beta1 = 0.55 beta2 = 0.95) numEpochs = 5;
    train embeddingDim = 32 miniBatchSize = 300 useOrigLevelFreq;

    saveState rStore = casuser.ASTORE_CarsSynth_TabGAN;
    output out = casuser.CarsSynth_TabGAN_40000;
run; quit;


data gdata.CarsSynth_TabGAN_40000;
 set casuser.CarsSynth_TabGAN_40000;
run;



title sashelp.cars Data;
proc print data=sashelp.cars(obs=10);
 title Original Cars Data;
 var invoice horsepower mpg_city mpg_highway weight;
run;

title Synthetic Cars Data with PROC TABULARGAN;
*proc print data=casuser.CarsSynth_TabGAN_40000(obs=10);
proc print data=gdata.CarsSynth_TabGAN_40000(obs=10);
 format invoice DOLLAR8. horsepower mpg_city mpg_highway weight 8.;
 var invoice horsepower mpg_city mpg_highway weight;
run;




proc sgplot data=casuser.cars;
title Original Cars Data;
 scatter x=horsepower y=mpg_highway;
run;


*proc sgplot data=casuser.CarsSynth_TabGAN_40000;
proc sgplot data=gdata.CarsSynth_TabGAN_40000;
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
*proc freq data= casuser.CarsSynth_TabGAN_40000;
proc freq data= gdata.CarsSynth_TabGAN_40000;
 ods select mosaicplot;
 title Synthetic Cars Data created with PROC TABULARGAN;
 table type *  drivetrain / plots=(mosaicplot);
run;
