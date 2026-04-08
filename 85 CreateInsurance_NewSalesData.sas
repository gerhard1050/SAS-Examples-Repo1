data gdata.insurance_premium_history;
 set casuser.insurance_premium_history;
run;


data gdata.insurance_premium_newsales;
 set casuser.insurance_premium_history;
 if 'Type'n = "New Sales";
run;
