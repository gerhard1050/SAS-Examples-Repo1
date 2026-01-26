*** 
1-Basic Rounds
2-Jail Y/N
3-Doublet, dice again
4-3doublet, goto jail
5-VA Report

%let cnt_players = 3;
%let cnt_games   = 2000;
%let cnt_rounds  = 80;
%let ConsiderJail = yes;
%let Doublet3Jail = yes;
%let seed  = 1;


 data work.Monopoly1(where=(Round ne 0));

  format Game Round Player Dice1 Dice2 DiceSum 8.;

  Array PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;
  ARRAY PlayerInJail    {&cnt_players.} PlayerInJail1 - PlayerInJail&cnt_players.;
 * Array Field         {52} Field1        - Field52       ;



  call streaminit(&seed);

  do Game = 1 to &cnt_games;

        *** Init-Block;
        Round=0; Dice1=.; Dice2=.; 
        do Player   = 1 to &cnt_players; 
                   PlayerPos[Player]=1; 
                   PlayerInJail[Player]=0;
        end;

        do Round = 1 to &cnt_rounds;
            do Player = 1 to &cnt_players;

             if PlayerInJail[player]=0 then do;

                Dice1 = ceil(rand('Uniform')*6);    
                Dice2 = ceil(rand('Uniform')*6);
                DiceSum = sum(Dice1,Dice2);

             *%if &DiceAgainDoublet. = YES %then %do;   

                if Dice1 = Dice2 then do; ** First Doublet;
                   output;
                   Dice1 = ceil(rand('Uniform')*6);    
                   Dice2 = ceil(rand('Uniform')*6);
                   DiceSum + sum(Dice1,Dice2);

                   if Dice1 = Dice2 then do; ** Second Doublet;
                      output;
                      Dice1 = ceil(rand('Uniform')*6);    
                      Dice2 = ceil(rand('Uniform')*6);
                      DiceSum + sum(Dice1,Dice2);

                    %if %upcase(&doublet3jail.) = YES %then %do;
                      if Dice1 = Dice2 then do; ** Third Doublet;
                         PlayerInJail[player]=3;
                         PlayerPos[Player]=31;
                      end; ** Third Doublet;
                    %end;
                 
                    end; ** Second Doublet;
                end; ** First Doublet;
                if PlayerInJail[player] ne 3 then do; ** was just sent to jail, do not move forward;
                    PlayerPos[Player] + DiceSum;
                    PlayerPos[Player] = mod(PlayerPos[Player]-1,40)+1;
                end; ** PlayerJail Check = 0;
              end; 

              else PlayerInJail[player] + (-1);


                %if %upcase(&ConsiderJail) = YES %then %do;
                  if PlayerPos[Player]=11 then PlayerPos[Player] = 31; *** Go to Jail;
                %end; ** Jail;
 


              output;
            end; *** Player;
        end; *** Round;
 end; *** Game;
run;

/**
proc print;
 *where round in (67,68,69,70,71);
run;
**/

proc freq ;
 table PlayerPos1-PlayerPos3/plots=(freqplot);
run;

