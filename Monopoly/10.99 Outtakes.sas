
data work.Field_Stats;
length Game Round 8 Feature $8 Field 8;* Value 8;    
 set work.Field_Stats;
 Field=input(compress(_name_,,"ul"),3.);
 Feature_tmp=strip(compress(_name_,,"d"));
 if Feature_tmp = "Field" then Feature = "Owner";
 else Feature = tranwrd(Feature_tmp,'Field','');
 rename col1 = Value;
 drop _name_ Feature_tmp;
 ID = Field;
run;





*cas cas1;

data casuser.ResultsRepo(promote=yes);
 set work.resultsrepo;
run;








data gdata.field_statistics;*(promote=yes);
 set work.field_statistics;
run;

data gdata.player_statistics;*(promote=yes);
 set work.player_statistics;
run;

 
data casuser.field_statistics(promote=yes);
 set gdata.field_statistics;
run;

data casuser.player_statistics(promote=yes);
 set gdata.player_statistics;
run;
