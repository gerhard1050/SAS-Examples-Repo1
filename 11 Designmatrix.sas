/*********************************************************************************
 Gerhard Svolba - 20250328
 
 Creation of the Designmatrix (one-hot encoding) using
 PROC MODELMATRIX
 PROC LOGISTIC

Creates a designmatrix with dummy variables 0/1 (and also other encoding types);

PROC LOGISTIC has been available for many years in SAS9 (SPRE);
https://go.documentation.sas.com/doc/en/pgmsascdc/default/statug/statug_logistic_toc.htm

PROC MODELMATRIX allows this also for CAS tables;
*** https://go.documentation.sas.com/doc/en/pgmsascdc/default/casstat/casstat_modelmatrix_syntax03.htm;;


**********************************************************************************/

proc logistic data = sashelp.cars
              noprint 
              outdesignonly  
              outdesign = work.designmatrix;
 class make type; */ param = glm;
 model origin = make type;
run;


quit;



*** Start CAS + Load Data ;

cas cas1;
caslib _all_ assign;

data casuser.cars;
 set sashelp.cars;
run;


*** PROC MODELMATRIX;


** Store reference table in a SAS-Dataset 
   that translates the variablename assignment e.g param2 = TYPE_SUV ;

ods output OutDesignInfo = work.OutDesignInfo;

proc modelmatrix data=casuser.cars;
   class  make type ;
   model invoice = make type;
   output out=casuser.designMat 
          prefix=designvar_ 
          copyVars=(make type invoice);
 run;
** in the copyVars statement you would 
   also add you interval variables which should not be dummy encoced;