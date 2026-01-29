*** 
1-Basic Rounds
2-Jail Y/N
3-Doublet, dice again
4-3doublet, goto jail
5-VA Report
;



%let cnt_players = 3;
%let cnt_games   = 1000;
%let cnt_rounds  = 70;
%let ConsiderJail = yes;
%let Doublet3Jail = no;
%let ConsiderChance = yes;
%let seed  = 1;
%let ScenarioName = "5. correct Jail and Chance Cards";
*%let ScenarioName = "2. go-to-jail and 3Doublet";
*%let ScenarioName = "1. go-to-jail only ignore 3Doublet";
*%let ScenarioName = "0. No Jail";


 data     work.Monopoly1(where=(Round ne 0))
 ;

  format Game Round Player Dice1 Dice2 DiceSum 8.;

  ARRAY PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;
  ARRAY PlayerInJail  {&cnt_players.} PlayerInJail1 - PlayerInJail&cnt_players.;
 * Array Field         {52} Field1        - Field52       ;



  call streaminit(&seed);

  do Game = 1 to &cnt_games;


        *** Init-Block;
        Round=0; Dice1=.; Dice2=.; 
        do Player   = 1 to &cnt_players; 
                   PlayerPos[Player]=1; 
                   PlayerInJail[Player]=0;
        end;

        *** Mix CommunityChest and Chance cards. Here: leave the order as is (should be fine for the simulation),
            but define a new start in the stack of cards;
        ActualCommChestID = ceil(rand('Uniform')*16);
        ActualChanceID    = ceil(rand('Uniform')*16);

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

                  if PlayerPos[Player]=31 then do; 
                        PlayerPos[Player] = 11; *** Go to Jail;
                        PlayerInJail[player]=3;
                  end;                        

                %end; ** Jail;


                %if %upcase(&ConsiderChance) = YES %then %do;

                 if PlayerPos[Player] in (3, 18, 39) then do; ** Pick CommunityChest Cards;

                  if ActualCommChestID=1 then PlayerPos[Player] = 1; *** Goto Field 1;
                  else if ActualCommChestID=6 then PlayerPos[Player] = 11; *** Goto Field 11 = jail;
                  ActualCommChestID = mod(ActualCommChestID+1,16); *** Move to of pile to next card;

                 end; ** Community Chest Card;

                 else if PlayerPos[Player] in (8, 23, 37) then do; ** Pick Chance Cards;

                        select (ActualChanceID);

                        when (1) PlayerPos[Player] = 1;    /* Advance to GO */
                        when (2) PlayerPos[Player] = 25;   /* Advance to Illinois Avenue */
                        when (3) PlayerPos[Player] = 12;   /* Advance to St. Charles Place */

                        /* Advance to nearest Utility */
                        when (4) do;
                            if PlayerPos[Player] in (8,23) then PlayerPos[Player] = 13;
                            else if PlayerPos[Player] = 37 then PlayerPos[Player] = 29;
                        end;

                        /* Advance to nearest Railroad */
                        when (5) do;
                            if PlayerPos[Player] = 8  then PlayerPos[Player] = 16;
                            else if PlayerPos[Player] = 23 then PlayerPos[Player] = 26;
                            else if PlayerPos[Player] = 37 then PlayerPos[Player] = 6;
                        end;

                        when (6) do; end;   /* Bank pays you dividend of $50 – no move */
                        when (7) do; end;   /* Get Out of Jail Free – no move */

                        /* Go Back 3 Spaces */
                        when (8) do;
                            if PlayerPos[Player] = 8  then PlayerPos[Player] = 5;
                            else if PlayerPos[Player] = 23 then PlayerPos[Player] = 20;
                            else if PlayerPos[Player] = 37 then PlayerPos[Player] = 34;
                        end;

                        when (9) PlayerPos[Player] = 11;   /* Go to Jail */
                        when (10) do; end;  /* General repairs – no move */
                        when (11) do; end;  /* Pay poor tax – no move */
                        when (12) PlayerPos[Player] = 6;   /* Take a trip to Reading Railroad */
                        when (13) PlayerPos[Player] = 40;  /* Take a walk on the Boardwalk */
                        when (14) do; end;  /* Chairman of the Board – no move */
                        when (15) do; end;  /* Building loan matures – no move */

                        /* Advance to nearest Railroad */
                        when (16) do;
                            if PlayerPos[Player] = 8  then PlayerPos[Player] = 16;
                            else if PlayerPos[Player] = 23 then PlayerPos[Player] = 26;
                            else if PlayerPos[Player] = 37 then PlayerPos[Player] = 6;
                        end;

                        otherwise;
                        end;

                  ActualChanceID = mod(ActualChanceID+1,16); *** Move to of pile to next card;


                 end; ** Chance Card;

                %end; ** Consider Chance and CommunityChest Cards;
 


              output work.Monopoly1;

            end; *** Player;
        end; *** Round;
 end; *** Game;
run;


data work.PlayerPos_LastRecRound;
 set work.monopoly1;
 by Game Round Player;
 drop dice1 dice2 dicesum player;
  ARRAY PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;
  ARRAY PlayerInJail  {&cnt_players.} PlayerInJail1 - PlayerInJail&cnt_players.;
  do Player = 1 to &cnt_players;
   if PlayerInJail[Player] then PlayerPos[Player]=.;
  end;
  if last.round then output;
run;

proc transpose data=work.PlayerPos_LastRecRound out=work.PlayerPos_LastRecRound_tp;*(drop=_name_ rename=(col1 = Field) where =(Field ne .));
 by game round;
 var PlayerPos:;
run;

data work.PlayerPos_LastRecRound_tp;
*data work.Monopoly_Visit_Scenarios;
 length ScenarioName $50 ConsiderJail ConsiderAction Doublet3Jail $3;
 set work.PlayerPos_LastRecRound_tp;
 drop _name_;
 rename col1 = Field;
 where col1 ne .;
 ScenarioName = &ScenarioName;
 ConsiderJail = upcase("&ConsiderJail");
 *ConsiderAction = upcase("&ConsiderChance");
 ConsiderChance = upcase("&ConsiderChance");
 Doublet3Jail = upcase("&Doublet3Jail");
run;



*%CASTableLoad(Monopoly_Visit_Scenarios,inlib=work);
/*
data casuser.Monopoly_Visit_Scenarios(promote=YES);
 set work.playerpos_lastrecround_tp;
run;
*/

/**/ 
data casuser.Monopoly_Visit_Scenarios(append=YES);
 set work.playerpos_lastrecround_tp;
run;



/*
*** Check if Last Record in Game has "open Jail records" to explain the uneven distribution on PlayerInJail;
data work.Monopoly1_LastRecGame;
 set work.monopoly1;
 by Game Round ;
 drop dice1 dice2 dicesum player round;
 if last.Game then output;
run;
*/



/**
proc print work.Monopoly1_LastRecRound;;
 *where round in (67,68,69,70,71);
run;
**/
/*
proc freq data= work.Monopoly1_LastRecRound;;;
 *table PlayerPos1-PlayerPos3/plots=(freqplot(scale=percent)) ;
 table PlayerPos1/plots=(freqplot(scale=percent)) ;
run;

proc freq data= work.Monopoly1_LastRecRound;;
 table PlayerInJail1-PlayerInJail3;
run;
*/

proc freq data=CASUSER.MONOPOLY_VISIT_SCENARIOS;
     table ScenarioName;
run;
