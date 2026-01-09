/***********************************************************************************************
 ***  1. Call Data to Datastep Macro for;
 ***********************************************************************************************/
** https://github.com/SASJedi/sas-macros/blob/master/data2datastep.sas;


*** Data
BORG_CLUSTERGROUP_LOOKUP
BORG_DEMOGR
BORG_DEMREG_LOOKUP
BORG_SPEND
BORG_TARGETEVENTS
;


%let path = /export/viya/homes/gerhard.svolba@sas.com/SAS_Data;
%put =&path;


%data2datastep(Bigorganics,gdata,work,&path./Create_BIGORGANICS.sas);

%data2datastep(BORG_CLUSTERGROUP_LOOKUP,work,work,&path./Create_BORG_CLUSTERGROUP_LOOKUP.sas);
%data2datastep(BORG_DEMOGR,work,work,&path./Create_BORG_DEMOGR.sas);
%data2datastep(BORG_DEMREG_LOOKUP,work,work,&path./Create_BORG_DEMREG_LOOKUP.sas);
%data2datastep(BORG_SPEND,work,work,&path./Create_BORG_SPEND.sas);
%data2datastep(BORG_TARGETEVENTS,work,work,&path./Create_BORG_TARGETEVENTS.sas);






/***********************************************************************************************
 ***  6. CHECK
 ***********************************************************************************************/


cas cas1;

data gdata.bigorganics;
 set tundata.bigorganics;
run;


%let class = demclustergroup;

proc means data=gdata.bigorganics  maxdec=2 n nmiss mean std median min max ;
 title Original;
 class &class;
run;


proc means data=work.bigorganics_flow  maxdec=2 n nmiss mean std median min max ;;
 *class demGender DemClusterGroup;
 title sql;
 class &class;
run;

*proc means data=WORK.PROM_DATA_AGGR maxdec=2 n nmiss mean std median min max ;;
run;






*** Check;

*** Abhängigkeiten
DemCluster --> DemClusterGroup
DemClusterGroup # DemReg
DemTVReg --> DemReg
;

proc freqtab data=tundata.bigorganics;
 table DemCluster* DemClusterGroup;
 table DemClusterGroup * DemReg;
 table DemReg * DemTVReg;
run;

*** PromSpend Limits
Platinum: 20000.01 --> max
Gold: -> 5000.01 --> 20000
Silver --> 0.02 --> 5000
Tin = 0.01
;

proc mdsummary data=tundata.bigorganics;
 var PromSpend ;
 groupby PromClass/ out=casuser._tmp_PromSpend;
run;




proc contents  data=work.bigorganics_assmbl;
run;

proc contents  data=gdata.bigorganics;
run;





ods trace off;
proc contents  data=gdata.bigorganics;
ods select variables;
run;

proc contents  data=work.bigorganics_flow;
ods select variables;
run;





