%let id = "A0002176327";
*%let id = "A0001978349";
*%let id = "A0000000868";
*%let id = "A0000010812";



ods powerpoint file="/export/viya/homes/gerhard.svolba@sas.com/output/data4ID_&id..ppt";

proc print data = WORK.BORG_DEMOGR label noobs;
 where id = &id;
run;
proc sql noprint;
 select DemCluster into :DemCluster from WORK.BORG_DEMOGR where id = &id;
 select DemTVReg into :DemTVReg from WORK.BORG_DEMOGR where id = &id;
quit;

proc print data = WORK.BORG_DEMREG_LOOKUP label noobs;
 where DemTVReg = "&DemTVReg";
run;
proc print data = WORK.BORG_CLUSTERGROUP_LOOKUP label noobs;
 where DemCluster = "&DemCluster";
run;
proc print data = WORK.BORG_SPEND label noobs;
 where id = &id;
run;
proc print data = WORK.BORG_TARGETEVENTS label noobs ;
 where id = &id;
run;

proc print data=gdata.bigorganics label noobs;
 where id in (
"A0002176327",
"A0001978349",
"A0000000868",
"A0000010812"
);
run;

ods powerpoint close;
