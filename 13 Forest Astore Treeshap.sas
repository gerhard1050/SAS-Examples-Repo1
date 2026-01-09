data casuser.bigorganics;
 set gdata.bigorganics;
run;


proc forest data=casuser.bigorganics seed=1234    ntrees=100
   maxdepth=10
   minleafsize=5;

   target targetbuy / level=nominal;
   input demage demaffl promspend promtime / level=interval;
   input demgender demreg promclass / level=nominal;


   /* Save as analytic store */
   savestate rstore=casuser.forest_astore;
run;



proc astore;
 score data=casuser.bigorganics
       rstore=casuser.forest_astore
       out = casuser.bigorganics_scored copyvars=(_all_);
      setoption treeshap 1
                 ;
run;
