



%let CutoffDate = 01JAN2025;


data work.BORG_Demogr;
 set tundata.bigorganics;
 *set work.bigorganics;
 keep id DemAffl DemAge DemGender DemCluster DemTVReg;
run;

proc sql ;
 create table work.BORG_ClusterGroup_Lookup
 as select distinct DemCluster, DemClusterGroup
    from tundata.bigorganics
    order by 1
;

 create table work.BORG_DemReg_Lookup 
 as select distinct DemTVReg, DemReg
    from tundata.bigorganics
    order by 2
;
quit;

data work.BORG_TargetEvents;
 call streaminit (040525);
 set tundata.bigorganics;
 format PurchaseDate date9.;
 keep id PurchaseDate targetAmt;
 do Index = 1 to targetAmt ;
   PurchaseDate = "&CutoffDate."d + round(rand('Uniform')*90);
   output;
 end;
run;



data work.BORG_Spend; 
 call streaminit ( 952025); 
 set tundata.bigorganics; 
 keep id  SpendAmount SpendDate ; 
 format SpendDate date9. SpendAmount _tmp_spend 8.2; 
 retain _tmp_spend 0; 
 if PromSpend <= 10 then do; 
  SpendDate = intnx('MONTH',"&CutoffDate."d,-PromTime); 
  SpendAmount  = PromSpend; 
  output; 
 end; 
 else if PromTime ne . then  do; 
   if PromTime in (0,1) then do; 
		SpendDate = intnx('MONTH',"&CutoffDate."d,-PromTime); 
  		SpendAmount  = PromSpend; 
  		output; 
   end; 
   else do SpendEvent = 1 to PromTime; 
     SpendDate   = intnx('MONTH',"&CutoffDate."d,-SpendEvent); 
     if  mod(SpendEvent,2) = 1 then do; 
	     SpendAmountSplit = PromSpend / PromTime; 
	     _tmp_Spend = SpendAmountSplit * (0.08 + round(rand('Uniform')*6)/100); 
          if SpendEvent < Promtime  then SpendAmount = SpendAmountSplit + _tmp_Spend; 
          else SpendAmount = SpendAmountSplit; 
     end; 
     else do; 
       SpendAmount = SpendAmountSplit - _tmp_Spend; 
     end; 
     output; 
   end; 
 end; 
 else do; ** PromTime = .;
   SpendDate = .; 
   SpendAmount  = PromSpend; 
   output;
 end;

run; 

