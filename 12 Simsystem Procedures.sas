*** https://go.documentation.sas.com/doc/en/pgmsascdc/v_066/casstat/casstat_simsystem_examples02.htm;

data casuser.Grid;
   do s2 = 0 to 10 by 0.05;
      do Kurtosis = 1 to 11 by 0.05;
         Skewness = sqrt(s2);
         output;
         end;
      end;
run;

ods select none;
proc simsystem data=casuser.Grid system=johnson cumprob=-3 3 plot=none;
   ods output Parameters=SKProbJ;
run;
ods select all;

data SKProbJ; set SKProbJ;
   Coverage = P2 - P1;
   s2 = Skewness*Skewness;
   format Coverage percent6.;
run;

proc sgrender data=SKProbJ template=acas.simsystem.Graphics.S2KContourMap;
   dynamic _Title = "Three-Sigma Coverage for Johnson Distributions"
           _XVar  = "s2"
           _YVar  = "Kurtosis"
           _ZVar  = "Coverage";
run;






data casuser.LowCoverage;
   do s2 = 7 to 10 by 0.5;
      do Kurtosis = 8 to 11 by 0.5;
         Skewness = sqrt(s2);
         if (1 + s2 < Kurtosis <= 1 + s2 + 0.5) then
            output;
         end;
      end;
run;

proc simsystem data=casuser.LowCoverage system=johnson
               plots=mrmap(skewscale=square);
run;