** https://blogs.sas.com/content/iml/2024/03/20/mle-linear-regression.html;

/* simple linear model 
   y ~ betas0 + beta1*x + eps for eps ~ N(0,sigma)
*/
data Sim;
call streaminit(4321);
array beta[0:1] (10, 0.5);     /* beta0=10; beta1 = 0.5 */
sigma = 1.5;                   /* scale for the distribution of errors */
N = 50;
do i = 1 to N;
   x = i / N;                  /* X is equally spaced in [0,1] */
   eta = beta[0] + beta[1]*x;  /* model */
   y =  eta + rand("Normal", 0, sigma);
   output;
end;
run;



proc reg data=Sim plots(only)=fit;
   model y = x;
run;

proc genmod data=Sim plots=none;
   model y = x;
run;






proc iml;
use Sim;        /* read the data */
   read all var {"x" "y"};
close;
X = j(nrow(x),1,1) || x;    * design matrix;
 
start LogLikReg(parm) global(X, y);
   pi = constant('pi');
   b = parm[1:2];
   sigma = parm[3];
   sigma2 = sigma##2;
   r = y - X*b;
   /* you can use the explicit formula:
         n = nrow(X);
         LL = -1/2*(n*log(2*pi) + n*log(sigma2) + ssq(r)/sigma2);  
      but a simpler expression uses the sum of the log-PDF */
   LL = sum( logpdf("normal", r, 0, sigma) );                
   return LL;
finish;

/* set constraint matrix, options, and initial guess for optimization */
/*     b0 b1 sigma constraint matrix */
con = { .   . 1E-6,    /* lower bounds: none  for beta[i]; 0 < sigma */
        .   . .};      /* upper bounds: none */
opt = {1,              /* find maximum of function   */
       0};             /* do not print durin optimization */
param0 = {11 1 1.2};   /* initial guess */
call nlpnra(rc, MLEest, "LogLikReg", param0, opt, con);
 
/* what is the LL at the optimal parameter? */
LLopt = LogLikReg(MLEest);
print LLopt[F=8.4], 
      MLEest[c={'b0' 'b1' 'RMSE'} F=7.5];

quit;



