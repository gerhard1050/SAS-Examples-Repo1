proc sort data=CASUSER.GPS_RACERUST_DAY1 out=work.GPS_RACERUST_DAY1;
    by team racetime;
run;

*** Part 1 - Checks ;
data work.gps_check;
     set work.GPS_RACERUST_DAY1;
 by team;     
 New_RaceTime = round(RaceTime,2);
 time_jump = dif(RaceTime); 
 New_Ractime_jump = dif(New_RaceTime); 

 retain Corrct_RaceTime;
 if first.team then Corrct_RaceTime = "14:00:00"t;
 else Corrct_RaceTime + 2;
 Corrct_time_jump = dif(Corrct_RaceTime); 

 if first.team then do; 
            time_jump=.;
            New_Ractime_jump=.;
            Corrct_time_jump = .;
            end;
run;

proc print data=work.gps_check;
    *where time_jump ne 2 or New_Ractime_jump ne 2;
    where Corrct_time_jump ne 2;
run;

*** Part 2 - Change;
/**
save a copy
data gdata.GPS_RACERUST_DAY1_Pre2026;
    set CASUSER.GPS_RACERUST_DAY1;
run;
**/

proc sort data= GDATA.GPS_RACERUST_DAY1_PRE2026
          out=work.GPS_RACERUST_DAY1;
    by team racetime;
run;


data work.GPS_RACERUST_DAY1;
 set work.GPS_RACERUST_DAY1;
  by team racetime;     

 retain Corrct_RaceTime;
 if first.team then Corrct_RaceTime = "14:00:00"t;
 else Corrct_RaceTime + 2;

 RaceTime = Corrct_RaceTime;
 RaceTime_XT = dhms(datepart(RaceTime_XT),0,0,RaceTime);

run;

%CASTableLoad(GPS_RACERUST_DAY1,inlib=work,outlib=casuser);

/**
save a copy
data gdata.GPS_RACERUST_DAY1;
    set CASUSER.GPS_RACERUST_DAY1;
run;
**/


data  GDATA.GPS_RACERUST_DAY1_V2;
set GDATA.GPS_RACERUST_DAY1;
 rename Corrct_RaceTime = RaceTime_Num;
run;
%CASTableLoad(GPS_RACERUST_DAY1_V2,inlib=gdata,outlib=casuser);
