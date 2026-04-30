** https://chatgpt.com/share/6818be5e-e134-8004-9cd9-da4b3ca2742f **;
** credits to Johannes Palmetshofer from JKU;


proc iml;
/* Initialize a 40x40 zero matrix */
mat = j(40, 40, 0);

/* Define dice probabilities */
probs = {0 1 2 3 4 5 6 5 4 3 2 1} / 36;

/* Fill transition probabilities */
do col = 1 to 40;
    do i = 1 to 12;
        mat[mod(col + i - 1, 40)+1, col] = probs[i];
    end;
end;


/* Go to jail: add probabilities from 31 to 11, zero out 31 */
mat[11, ] = mat[11, ] + mat[31, ];
mat[31, ] = 0;


/* Compute eigenvalues and eigenvectors */
call eigen(evals, evecs, mat);

/* Find eigenvalue closest to 1 */
diffs = abs(evals - 1);
idx = loc(diffs = min(diffs));

/* Get stationary distribution (normalize) */
stationary = abs(evecs[, idx]);
stationary = stationary / sum(stationary);


/* Add index (field number) as first column */
index = t(1:40);
result = index || stationary;

/* Create dataset with index and probability */
create stationary_prob from result[colname={"Field" "Probability"}];
append from result;
close stationary_prob;


print stationary[rowname=(1:40) colname={"Probability"}];
quit;




proc freq data=work.stationary_prob;
 table field / nofreq nocum out=work.simprob;;
 weight Probability;
run;


proc sgplot data=stationary_prob1;
    *vbar _N_ / response=Probability;
    vbar field / response=Probability;
    xaxis label="Field";
    yaxis label="Probability";
    title "Stationary Visit Probabilities (SAS IML)";
run;
