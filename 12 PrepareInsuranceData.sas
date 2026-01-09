/*
libname tmp9 "C:\Users\autges\OneDrive - SAS\400 SAS\Daten\Tmp-Daten";

data work.Insurance_Premium_History;
 Format Date date9.;
 set tmp9.allianz_outfor(rename=(date=date2));
 drop predict lower upper error std initiativen _name_ date2 sparte Bewegungsart Kennzahl actual;
 *rename actual = Value;
 Date = intnx('MONTH',date2,12*15);
 if actual = . then delete;

 if actual = 0 then Value =0;
 else Value = round(8.5*actual*(0.95+rand('uniform')*0.1));

 Format InsuranceClass $26.;
 select (sparte);
 when ("ELEMENTAR ZIVIL") InsuranceClass = "Property Class";
 when ("HAFTPFLICHT") InsuranceClass = "Liability";
 when ("KFZ-HAFTPFLICHT") InsuranceClass = "Motor Vehicle Liability";
 when ("RECHTSSCHUTZ") InsuranceClass = "Legal Protection";
 end;

 format KPI $9.;
select (Bewegungsart);
When ("Praemie") KPI = "Premium";
when ("Stueck") KPI = "Contracts";
end;

Format Type $24.;
select (kennzahl);
when ("AB") Type = "Opening Balance";
when ("NEU") Type = "New Sales";
when ("ERH") Type = "Increase";
when ("RED") Type = "Reduction";
when ("INDEX") Type = "Index";
when ("BZ") Type = "Other";
when ("STORNO") Type = "Cancellation";
OTHERWISE type = "_X_";
end;

run;

proc sort data=work.Insurance_Premium_History;
 by date InsuranceClass type;
run;

proc transpose data=work.Insurance_Premium_History 
                out=tmp9.Insurance_Premium_History(drop=_name_);
 by date InsuranceClass type;
 var value;
 id KPI;
run;
*/


data work.Insurance_Premium_History;
 set task.Insurance_Premium_History;

 PreCovidPeriod = (date <= '01FEB2020'd);

 Campaign = 0;
 InternalPromo = 0;

 if InsuranceClass = "Property Class" and Type = "New Sales" then do;
   if  '01SEP2017'd <= date <= '01NOV2017'd 
    or '01SEP2018'd <= date <= '01NOV2018'd 
    or '01SEP2019'd <= date <= '01NOV2019'd 
    or '01SEP2023'd <= date <= '01NOV2023'd 
    or '01SEP2024'd <= date <= '01NOV2024'd  then do;
	                                 Campaign = 1;
									 Premium = Premium * 1.07;
									 Contracts = Contracts * 1.08;
	end;       
 end;
 else if InsuranceClass = "Legal Protection" and Type = "New Sales" then do;
   if year(date) >= 2022 and month(date) in (1,2,3) then do;
	                                 Campaign = 1;
									 Premium = Premium * 1.12;
									 Contracts = Contracts * 1.15;
   end;
 end;
 else if InsuranceClass = "Liability" and Type = "New Sales" then do;
  if year(date) >= 2023 and month(date) in (4,5,6) then do;
       	   							InternalPromo = 1;
        							Premium = Premium * 1.15;
									Contracts = Contracts * 1.10;
  end;
 end;
run;

%CASTableLoad(Insurance_Premium_History,inlib=work);


proc freq data=work.Insurance_Premium_History;
 *table  Kennzahl Sparte Bewegungsart; 
 table type InsuranceClass PreCovidPeriod Campaign InternalPromo;
run;

/*
Kennzahl:
AB
BZ
ERH
INDEX
NEU
RED
STORNO

AB Anfangsbestand
NEU Neuzugang
ERH Erhöhung
RED Reduktion
INDEX Indexierung
Direct Mail
STORNO Storno




Sparte:
ELEMENTAR ZIVIL
HAFTPFLICHT
KFZ-HAFTPFLICHT
RECHTSSCHUTZ

Bewegungsart:
Praemie
Stueck

 ***/

