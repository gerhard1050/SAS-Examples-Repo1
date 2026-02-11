


%let cnt_players = 5;
%let cnt_games   = 1000;
%let cnt_rounds  = 100;

%let seed  = 1;
%let ConsiderJail = no;
%let Doublet3Jail = no;
%let ConsiderChance = no;

%let ScenarioName = "1. Basic Game - Dice only";




 data     work.MNP_Sim1(where=(Round ne 0)) ;

  format Game Round Player Dice1 Dice2 DiceSum 8.;

  ARRAY PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;

  call streaminit(&seed);

  do Game = 1 to &cnt_games;

        *** Init-Block;
        Round=0; Dice1=.; Dice2=.; 
        do Player = 1 to &cnt_players; 
            PlayerPos[Player]=1; 
        end;

        do Round = 1 to &cnt_rounds;
            do Player = 1 to &cnt_players;

                Dice1 = ceil(rand('Uniform')*6);    
                Dice2 = ceil(rand('Uniform')*6);
                DiceSum = sum(Dice1,Dice2);

                PlayerPos[Player] + DiceSum;
                PlayerPos[Player] = mod(PlayerPos[Player]-1,40)+1;

                output;
                
              end; *** Player;
        end; *** Round;

 end; *** Game;
run;


/**************************************************************
*** Keep only last record of round
***************************************************************/

data work.MNP_Sim1_LastRec;
 set work.MNP_Sim1;
 by Game Round Player;
 drop dice1 dice2 dicesum;
  *** Keep only last record per round;
  if last.round then output;
run;



/**************************************************************
*** Prepare Player Table
***************************************************************/


proc transpose data=work.MNP_Sim1_LastRec 
                out=work.Player_Long;
 by game round;
 var PlayerPos: ;
run;



data work.Player_Location;
 length ScenarioName $40 ConsiderJail ConsiderChance Doublet3Jail $3;
 set work.Player_Long;
 Player=input(compress(_name_,,"ul"),3.);
 Feature=strip(compress(tranwrd(_name_,'Player',''),,"d"));
 if Feature = "Pos" then Feature = "Location";
 rename col1 = Value;
 drop _name_;

 ScenarioName = &ScenarioName;
 ConsiderJail = upcase("&ConsiderJail");
 ConsiderChance = upcase("&ConsiderChance");
 Doublet3Jail = upcase("&Doublet3Jail");

run;



proc sgplot data=work.player_location;
 title Scenario: &scenarioname.;
 histogram value / binstart=1 binwidth=1;
 yaxis max = 6;
run;
title;



data casuser.Monopoly_Visit_Scenarios(append=YES);
 set work.player_location (rename =(Value=Field) drop=feature);
run;