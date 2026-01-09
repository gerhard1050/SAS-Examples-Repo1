cas cas1;

libname casuser  cas caslib=casuser;
libname helpdata cas caslib=helpdata;
libname tundata  cas caslib=tundata;
libname svso 	 cas caslib=svso;


/*******************************************************************************
 ***   BIGORGANICS
 *******************************************************************************/


proc casutil incaslib="casuser" outcaslib="casuser";
 droptable casdata="bigorganics" quiet;
run;

proc partition data=tundata.bigorganics 
samppct=70
samppct2=10
partind;
output out=casuser.bigorganics copyvar=(_all_);
run;

data casuser.bigorganics;
 set casuser.bigorganics;
 format _partition_ $1.;
 _partition_ = put(_partind_,$1.);
 drop _partind_ _freq_;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
 promote casdata="bigorganics" casout="bigorganics" ;
 save casdata="bigorganics" casout="bigorganics" replace;
run;





/*******************************************************************************
 ***   PVA
 *******************************************************************************/


proc casutil incaslib="casuser" outcaslib="casuser";
 droptable casdata="pva" quiet;
run;

proc partition data=svso.pva
samppctevt=11
eventprop=0.1
event='1'
seed=1;
output out=casuser.pva copyvar=(_all_);
by target_B;
run;

proc partition data=casuser.pva 
samppct=70
samppct2=10
partind;
output out=casuser.pva copyvar=(_all_);
run;

data casuser.pva;
 set casuser.pva;
 format _partition_ $1.;
 _partition_ = put(_partind_,$1.);
 drop _partind_ _freq_;

 drop GiftCntAll GiftCntCardAll GiftAvgAll PromCntAll PromCntCardAll 
      PromCnt12 PromCntCard12 ;
run;

proc casutil incaslib="casuser" outcaslib="casuser";
 promote casdata="pva" casout="pva" ;
 save casdata="pva" casout="pva" replace;
run;

/*
proc freqtab data=casuser.pva; 
table target_B;
run;
*/