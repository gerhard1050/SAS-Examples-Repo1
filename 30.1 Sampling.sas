
/***************************************************************
•	Welche Möglichkeiten bietet SAS Viya für die automatisierte Ziehung von Stichproben aus großen Datensätzen?
•	Gibt es eingebaute Algorithmen in SAS Viya, die speziell für die zufällige oder geschichtete Stichprobenziehung entwickelt wurden
https://go.documentation.sas.com/doc/en/statug/latest/statug_surveyselect_syntax01.htm
https://go.documentation.sas.com/doc/en/pgmsascdc/default/casstat/casstat_partition_gettingstarted.htm

•	Wie kann SAS Viya mit bestehenden Datenpipelines integriert werden, um eine kontinuierliche und automatisierte Stichprobenziehung zu ermöglichen?
        siehe Beispiel
•	Können benutzerdefinierte Regeln für die Stichprobenziehung in SAS Viya erstellt und automatisiert angewendet werden?
        Code
•	Welche Funktionen in SAS Viya helfen dabei, den Prozess der Stichprobenziehung zu optimieren und zu beschleunigen, besonders bei großen Datensätzen?
        CAS, Proc Partition
•	Gibt es eine Möglichkeit, in SAS Viya mehrere Stichproben gleichzeitig zu ziehen und zu analysieren, um Zeit und Ressourcen zu sparen?
        Datastep
•	Wie können Ergebnisse aus der automatisierten Stichprobenziehung in SAS Viya visualisiert und weiterverarbeitet werden?
	und wie oben beschrieben Reporting und Visualisierung Möglichkeiten
        SAS Procedures oder VA
*/


/***************************************************************************
***  Create Data
*****************************************************************************/

data work.Accounts;
    set 
    gdata.accounts
;

proc surveyselect data=gdata.accounts out=work.accounts_500 reps=500 samprate=1;
run;

 
proc copy in = work out=casuser;
    select accounts_500;
run;



/***************************************************************************
***  10 SAS-Compute
*****************************************************************************/

data work.Sample1
     work.Sample2
     work.Sample3;
 call streaminit(1);
 set work.bigorganics;
 if rand('Normal') < 0.1 then output work.Sample1;
 if PromClass = 'Gold' and rand('Normal') < 0.1 then output work.Sample1;
 if 
run;


/***************************************************************************
***  20 CAS Datastep
*****************************************************************************/



data work.accounts_sample_1pct; *** OUTPUT;
 set work.accounts_500; *** INPUT;
 if rand('Uniform') < 0.01 then output;
run;     




data casuser.accounts_sample_1pct;
 set casuser.accounts_500;
 if rand('Uniform') < 0.01 then output;
run;     


/***************************************************************************
***  20 CAS Datastep
*****************************************************************************/
  proc sort data=work.accounts_500 out=WORK.accounts_500_sort;
   by type ;
 run;

  proc surveyselect data=work.accounts_500_sort 
  out=WORK.accounts_strat_sample(rename=(Selected=_PartInd_)) 
  outall 
method=srs sampsize=10000;
      
   strata type / alloc=prop;
 run;

 proc freq data=accounts_500;
    title Full Data;
     table type;
 run;

 proc freq data=accounts_strat_sample;
    title sample;
     table type;
 run;


 

/***************************************************************************
***  99 Basic Example
*****************************************************************************/


data work.students;    ** entspricht:   data students;
length id 3  Nachname Vorname $20 TaskSubm $10;  ** reicht, die Länge am Schluss der Liste anzugeben;
input id Nachname$ Vorname$ TaskSubm$;

    datalines;
1 Binder Christopher 123
4 Hafizovic Elmedina 123
5 Hallweger Leonhard 123
6 Haslehner Tobias 123
7 Jonic Dusan 123
9 Plöckinger Victoria 123
10 Spitzer Fabian 123
11 Stöttinger Mona 123
12 Wagner VivienneLeonie 123
14 Wurm Katharina 123
2 Gartner David 123
15 Herz Florian 123
;  
run ;


*** seed: 
postiver Wert: Fixer Seed --> Wiederholbar
nicht-positiver Seed: 0 oder negativ --> Systemzeit. immer neues Ergebnis;

proc surveyselect data=work.students 
                  out =work.Assignment_Select 
                  seed=-1
                  method=srs noprint
                  sampsize=3;  *** SRS = simple random sampling;

 where find(TaskSubm,'3');
run;

proc print;* data=work.assigment_select;
run;

