


%let cnt_players = 5;
%let cnt_games   = 1000;
%let cnt_rounds  = 100;
%let ConsiderJail = yes;
%let Doublet3Jail = no;
%let ConsiderChance = no;
%let seed  = 1;

*                    1234567890123456789012345678901234567890;
%let ScenarioName = "2. Consider Jail";
*%let ScenarioName = "1. Basic Game - Dice only";




 data     work.MNP_Sim1(where=(Round ne 0)) ;

  format Game Round Player Dice1 Dice2 DiceSum 8.;

  ARRAY PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;
  ARRAY PlayerInJail  {&cnt_players.} PlayerInJail1 - PlayerInJail&cnt_players.;

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
  *** Set Location to MISSING, if Player is in Jail to avoid double/triple counting;
  ARRAY PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;
  ARRAY PlayerInJail  {&cnt_players.} PlayerInJail1 - PlayerInJail&cnt_players.;
  do Player = 1 to &cnt_players;
   if PlayerInJail[Player] then PlayerPos[Player]=.;
  end;
  *** Keep only last record per round;
  if last.round then output;
run;



/**************************************************************
*** Prepare Player Table
***************************************************************/


proc transpose data=work.MNP_Sim1_LastRec 
                out=work.Player_Long;*(drop=_name_ rename=(col1 = Field) where =(Field ne .));
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


