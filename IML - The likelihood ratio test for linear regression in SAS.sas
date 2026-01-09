*** https://blogs.sas.com/content/iml/2024/03/27/likelihood-ratio-test.html;




/* Call PROC GENMOD twice and use DATA step to compute LR test.
   See https://support.sas.com/kb/24/474.html */
proc genmod data=Sim plots=none;
   Full: model y = x;
   ods select ModelFit;
   ods output ModelFit=LLFull;
run;
proc genmod data=Sim plots=none;
   Reduced: model y = ;
   ods select ModelFit;
   ods output ModelFit=LLRed;
run;
 
/* "Full Log Likelihood" is the 6th row in the data set */
data LRTest;
retain DF;
keep DF LLFull LLRed LRTest pValue;
merge LLFull(rename=(DF=DFFull Value=LLFull))
      LLRed (rename=(DF=DFRed  Value=LLRed));
if _N_ = 1 then
   DF = DFRed - DFFull;
if _N_ = 6 then do;
   LRTest = 2*abs(LLFull - LLRed);     /* test statistic */
   pValue = sdf("ChiSq", LRTest, DF);  /* p-value Pr(X > LRTest) where X~ChiSq(DF) */
   output;
end;
label LLFull='LL Full' LLRed='LL Red' LRTest='LR Test' pValue = 'Pr > ChiSq';
run;
 
proc print data=LRTest noobs label;
run;





proc iml;
/* the data are defined in 
   https://blogs.sas.com/content/iml/2024/03/20/mle-linear-regression.html
*/
use Sim;
   read all var {"x" "y"};
close;
X = j(nrow(x),1,1) || x;    * design matrix;
 
/* the three-parameter model (beta0, beta1, sigma) */
start LogLikRegFull(parm) global(X, y);
   pi = constant('pi');
   b = parm[1:2];
   sigma = parm[3];
   sigma2 = sigma##2;
   r = y - X*b;
   LL = sum( logpdf("normal", r, 0, sigma) );    
   return LL;
finish;
 
/* max of LogLikRegFull, starting from param0 */
start MaxLLFull(param0)  global(X, y);
   /*     b0 b1 sigma constraint matrix */
   con = { .   . 1E-6,    /* lower bounds: none  for beta[i]; 0 < sigma */
           .   . .};      /* upper bounds: none */
   opt = {1,              /* find maximum of function   */
          0};             /* do not print durin optimization */
   call nlpnra(rc, z, "LogLikRegFull", param0, opt, con);
   return z;
finish;
 
param0 = {11 1 1.2};     /* initial guess for full model */
MLFull = MaxLLFull( param0 );
LLF = LogLikRegFull(MLFull);  /* LL at the optimal parameter */
print LLF[F=8.4], MLFull[c={'b0' 'b1' 'RMSE'} F=7.5];

/* the two-parameter model (beta0, 0, sigma) */
start LogLikRegRed(parm) global(X, y);
   p = parm[1] || 0 || parm[2];
   return( LogLikRegFull( p ) );
finish;
/* max of LogLikRegReded, starting from param0 */
start MaxLLRed(param0)  global(X, y);
   /*     b0 sigma constraint matrix */
   con = { .  1E-6,       /* lower bounds: none  for beta[i]; 0 < sigma */
           .  .};         /* upper bounds: none */
   opt = {1,              /* find maximum of function   */
          0};             /* do not print durin optimization */
   call nlpnra(rc, z, "LogLikRegRed", param0, opt, con);
   return z;
finish;
 
param0 = {11 1.2};   /* initial guess */
MLRed = MaxLLRed( param0 );
/* what is the LL at the optimal parameter? */
LLR = LogLikRegRed(MLRed);
print LLR[F=8.4], MLRed[c={'b0' 'b1' 'RMSE'} F=7.5];


/* LL ratio test for null hypothesis of restricted model  */
LLRatio = 2*abs(LLF - LLR);         /* test statistic */
DF = 1;
pValue = sdf('ChiSq', LLRatio, DF); /* Pr(z > LLRatio) if z ~ ChiSq with DF=1 */
print DF LLF LLR LLRatio[F=7.5] pValue[F=PVALUE6.4];

quit;
