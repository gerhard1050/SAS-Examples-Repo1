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

/* Community Chest: 3,18 and 39 visits are moved to 1 in 1/16 and to 11 in 1/16 of the cases*/
/* Increase probability for target fields */
mat[1, ]    = mat[1, ]   + (mat[3, ] + mat[18,] + mat[39,])/16;
mat[11, ]   = mat[11, ]  + (mat[3, ] + mat[18,] + mat[39,])/16;

/* Decrease probability for source fields */
mat[3,]  = mat[3,]  * 14/16;
mat[18,] = mat[18,] * 14/16;
mat[39,] = mat[39,] * 14/16;


/* Chance cards */
/***  instructions for the Chance Cards:
 *** Cards are located at 8,23,37:
                        when (1) PlayerPos[Player] = 40;  * Take a walk on the Boardwalk *
                        when (2) PlayerPos[Player] = 1;    * Advance to GO *
                        when (3) PlayerPos[Player] = 25;   * Advance to Illinois Avenue *
                        when (4) PlayerPos[Player] = 12;   * Advance to St. Charles Place *
                        when (11) PlayerPos[Player] = 11;   * Go to Jail *
                        when (14) PlayerPos[Player] = 6;   * Take a trip to Reading Railroad *

                        when (5,6) do; * Advance to nearest Railroad *
                            if PlayerPos[Player] = 8 then PlayerPos[Player] = 16;
                            else if PlayerPos[Player] = 23 then PlayerPos[Player] = 26;
                            else if PlayerPos[Player] = 37 then PlayerPos[Player] = 6;
                        end;
                        when (7) do; * Advance to nearest Utility *
                            if PlayerPos[Player] in (8,37)  then PlayerPos[Player] = 13;
                            else if PlayerPos[Player] = 23 then PlayerPos[Player] = 29;
                        end;
                        * Go Back 3 Spaces *
                        when (10) do;
                            if PlayerPos[Player] = 8  then PlayerPos[Player] = 5;
                            else if PlayerPos[Player] = 23 then PlayerPos[Player] = 20;
                            else if PlayerPos[Player] = 37 then PlayerPos[Player] = 34;
							*** Alternative would be to use: PlayerPos[Player] = mod(PlayerPos[Player]-1,40)+1+3;
                        end;
***/

source = {8 23 37};
target = {40 1 25 12 11 6};

/* Increase probability for target fields */
do t_idx = 1 to ncol(target);
 t = target[t_idx];
 mat[t, ] = mat[t,] + (mat[8,] + mat[18,] + mat [39,])/16;
end;

/* Decrease probability for source fields */
do s_idx = 1 to ncol(source);
 s = source[s_idx];
 mat[s,]  = mat[s,]  * 6/16;
end;

/***

do idx = 1 to ncol(x);
    i = x[idx];
    mat[mod(i + 7 - 1, 40)+1, ]      = mat[mod(i + 7 - 1, 40)+1, ]      + mat[i, ] / 16;
    mat[mod(i - 4 - 1 + 40, 40)+1, ] = mat[mod(i - 4 - 1 + 40, 40)+1, ] + mat[i, ] / 16;

    do jdx = 1 to ncol(y);
        j = y[jdx];
        mat[j, ] = mat[j, ] + mat[i, ] / 16;
    end;
end;

**/
/* Remove redistributed probabilities from original chance positions */
do idx = 1 to ncol(x);
    i = x[idx];
    mat[i, ] = mat[i, ] - mat[i, ] / 16 * 7;
end;

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





proc sgplot data=stationary_prob;
    *vbar _N_ / response=Probability;
    vbar field / response=Probability;
    xaxis label="Field";
    yaxis label="Probability";
    title "Stationary Visit Probabilities (SAS IML)";
run;
