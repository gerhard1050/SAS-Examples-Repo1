*** 
1-Basic Rounds
2-Jail Y/N
3-Doublet, dice again
4-3doublet, goto jail
5-VA Report
;



%let cnt_players = 5;
%let cnt_games   = 1000;
%let cnt_rounds  = 100;
%let ConsiderJail = yes;
%let Doublet3Jail = yes;
%let ConsiderChance = yes;
%let CalcProfit = yes;
%let seed  = 1;
%let ScenarioName = "5. correct Jail and Chance Cards";
*%let ScenarioName = "2. go-to-jail and 3Doublet";
*%let ScenarioName = "1. go-to-jail only ignore 3Doublet";
*%let ScenarioName = "0. No Jail";


proc sql noprint;
 select field
 into :property_field separated by ","
 from WORK.PROPERTY_COSTREVENUE;
quit;
%put &=property_field;



 data     work.Monopoly1(where=(Round ne 0))
 ;

  format Game Round Player Dice1 Dice2 DiceSum 8.;

  ARRAY PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;
  ARRAY PlayerInJail  {&cnt_players.} PlayerInJail1 - PlayerInJail&cnt_players.;
  Array PlayerBalance {&cnt_players} PlayerBalance1 - PlayerBalance&cnt_players.  ;
  Array PlayerIncome  {&cnt_players} PlayerIncome1  - PlayerIncome&cnt_players.   ;
  Array PlayerExpense {&cnt_players} PlayerExpense1 - PlayerExpense&cnt_players.  ;
  Array Field         {40} Field1        - Field40       ;
  Array FieldSetup    {40} FieldSetup1   - FieldSetup40  ;
  Array FieldRevenue  {40} FieldRevenue1 - FieldRevenue40;
  Array FieldCost     {40} FieldCost1    - FieldCost40   ;
  Array FieldBalance  {40} FieldBalance1 - FieldBalance40;


  drop FieldCost1    - FieldCost40;
  drop FieldRevenue1 - FieldRevenue40;
    drop field1  field3  field5  field8  field11  field18  field21  field23  field31  field34  field37  field39;

    drop fieldsetup1  fieldsetup3  fieldsetup5  fieldsetup8  fieldsetup11
        fieldsetup18 fieldsetup21 fieldsetup23 fieldsetup31 fieldsetup34
        fieldsetup37 fieldsetup39;

    drop fieldbalance1  fieldbalance3  fieldbalance5  fieldbalance8  fieldbalance11
        fieldbalance18 fieldbalance21 fieldbalance23 fieldbalance31 fieldbalance34
        fieldbalance37 fieldbalance39;

  call streaminit(&seed);

  do Game = 1 to &cnt_games;


        *** Init-Block;
        Round=0; Dice1=.; Dice2=.; 
        do Player   = 1 to &cnt_players; 
                   PlayerPos[Player]=1; 
                   PlayerInJail[Player]=0;
				   PlayerIncome[Player]=0; 
				   PlayerExpense[Player]=0; 
				   PlayerBalance[Player]=0; 
        end;

		do FieldNum = 1 to 40; 
                   Field[FieldNum]=0; 
				   FieldSetup[FieldNum]=0; 
				   FieldRevenue[FieldNum]=0; 
				   FieldCost[FieldNum]=0; 
				   FieldBalance[FieldNum]=0; 
        end;
		drop fieldnum;





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
 
				%IF %UPCASE(&CalcProfit) = YES %then %do;
	                *** Buy Properties, Houses and Collect Rents;
                    
	                if PlayerPos[Player] in (&property_field) then do; *** Property Card;
					    rent=0;
						if Field[PlayerPos[Player]] = 0 then do;
		                                                   Field[PlayerPos[Player]]= Player;              *** If Field is still Free, Player buys this field;
														   FieldCost[PlayerPos[Player]]= input(PlayerPos[Player],C0_.);  *** Cost of Purchase;
														   FieldSetup[PlayerPos[Player]]= 0;                    *** Empty Field, no houses;
														   PlayerExpense[Player]= PlayerExpense[Player] + input(PlayerPos[Player],C0_.);   *** Increase Player Expense;
		                                               end;

		                else if Field[PlayerPos[Player]]=Player and FieldSetup[PlayerPos[Player]]<=4 then do; *** Re-Visit Place, Setup can still be increased, buy houses;
						                                   FieldCost[PlayerPos[Player]]= FieldCost[PlayerPos[Player]]+input(PlayerPos[Player],C1_.);   *** Increase FieldCost;
														   FieldSetup[PlayerPos[Player]]= FieldSetup[PlayerPos[Player]]+1;                                       *** Increase Field Setup;
														   PlayerExpense[Player]= PlayerExpense[Player] + input(PlayerPos[Player],C1_.);                                 *** Increase Player Expense;
		                                               end;  
		                else if Field[PlayerPos[Player]] ne Player then do; *** Other Player lands on fields, pays fee;
						                                   if FieldSetup[PlayerPos[Player]] = 0      then rent = input(PlayerPos[Player],M0_.);
						                                   else if FieldSetup[PlayerPos[Player]] = 1 then rent = input(PlayerPos[Player],M1_.);
						                                   else if FieldSetup[PlayerPos[Player]] = 2 then rent = input(PlayerPos[Player],M2_.);
						                                   else if FieldSetup[PlayerPos[Player]] = 3 then rent = input(PlayerPos[Player],M3_.);
						                                   else if FieldSetup[PlayerPos[Player]] = 4 then rent = input(PlayerPos[Player],M4_.);
						                                   else if FieldSetup[PlayerPos[Player]] = 5 then rent = input(PlayerPos[Player],M5_.);
						                                   FieldRevenue[PlayerPos[Player]]= FieldRevenue[PlayerPos[Player]] + rent;          *** Increase Field Revenue;
														   PlayerIncome[Field[PlayerPos[Player]]]= PlayerIncome[Field[PlayerPos[Player]]] + rent;   *** Increase Field-Owners Revenue;
														   PlayerExpense[Player] = PlayerExpense[Player] + rent;                           *** Increase Player Expense;
                                                           rent=0;
		                                               end; 
	                
	               end; *** Property Card;

                                        
                        *** ====== RAILROADS ======  ***;
                        if PlayerPos[Player] in (6,16,26,36) then do;
                                if Field[PlayerPos[Player]] = 0 then do;
                                    Field[PlayerPos[Player]]= Player;              *** If Field is still Free, Player buys this field;
                                    FieldCost[PlayerPos[Player]]= input(PlayerPos[Player],C0_.);  *** Cost of Purchase;
                                    FieldSetup[PlayerPos[Player]]= 0;                    *** Empty Field, no houses;
                                    PlayerExpense[Player]= PlayerExpense[Player] + input(PlayerPos[Player],C0_.);   *** Increase Player Expense;
                                end;

                                else if Field[PlayerPos[Player]] ne Player then do;

                                    RRcount = 0;
                                    do i = 1 to 4;
                                        if Field[scan("6 16 26 36", i)] = Field[PlayerPos[Player]] then RRcount + 1;
                                    end;

                                    select (RRcount);
                                        when (1) Rent = 25;
                                        when (2) Rent = 50;
                                        when (3) Rent = 100;
                                        when (4) Rent = 200;
                                        otherwise Rent = 0;
                                    end;


                                    FieldRevenue[PlayerPos[Player]]= FieldRevenue[PlayerPos[Player]] + Rent;                 *** Increase Field Revenue;
                                    PlayerIncome[Field[PlayerPos[Player]]]= PlayerIncome[Field[PlayerPos[Player]]] + Rent;   *** Increase Field-Owners Revenue;
                                    PlayerExpense[Player] = PlayerExpense[Player] + Rent;                                    *** Increase Player Expense;
                                    Rent=0;

                        end;
                        end;

                        ** ====== UTILITIES ====== ;
                        else if PlayerPos[Player] in (13,29) then do;


                            if Field[PlayerPos[Player]] = 0 then do;
                                        Field[PlayerPos[Player]]= Player;              *** If Field is still Free, Player buys this field;
                                        FieldCost[PlayerPos[Player]]= input(PlayerPos[Player],C0_.);  *** Cost of Purchase;
                                        FieldSetup[PlayerPos[Player]]= 0;                    *** Empty Field, no houses;
                                        PlayerExpense[Player]= PlayerExpense[Player] + input(PlayerPos[Player],C0_.);   *** Increase Player Expense;
                                    end;
                                    else if Field[PlayerPos[Player]] ne Player then do;

                                        if Field[PlayerPos[Player]] = Field[13] and Field[PlayerPos[Player]] = Field[29] then Rent = 10  * DiceSum;
                                        else Rent = 4 * DiceSum;

                                        FieldRevenue[PlayerPos[Player]]= FieldRevenue[PlayerPos[Player]] + Rent;                 *** Increase Field Revenue;
                                        PlayerIncome[Field[PlayerPos[Player]]]= PlayerIncome[Field[PlayerPos[Player]]] + Rent;   *** Increase Field-Owners Revenue;
                                        PlayerExpense[Player] = PlayerExpense[Player] + Rent;                                    *** Increase Player Expense;
                                        Rent=0;

                            end;
                            end;


                     ** Calculate Balances;
                     FieldBalance[PlayerPos[Player]] =FieldRevenue[PlayerPos[Player]]-FieldCost[PlayerPos[Player]];
                     drop rent;


                                    %end; *** CalcProfit yesno;


                                    output work.Monopoly1;

                                    end; *** Player;

                                    %IF %UPCASE(&CalcProfit) = YES %then %do;
                                        *** re-loop over players to make sure, that the Income is updated;
                                        do player = 1 to &cnt_players;
                                            PlayerBalance[Player]=PlayerIncome[Player]-PlayerExpense[Player];
                                        end;
                                    %END;
                                    



        end; *** Round;
 end; *** Game;
run;


/**************************************************************
*** Prepare Player Table
***************************************************************/

data work.PlayerPos_LastRecRound;
 set work.monopoly1;
 by Game Round Player;
 drop dice1 dice2 dicesum;
  ARRAY PlayerPos     {&cnt_players.} PlayerPos1  - PlayerPos&cnt_players. ;
  ARRAY PlayerInJail  {&cnt_players.} PlayerInJail1 - PlayerInJail&cnt_players.;
  do Player = 1 to &cnt_players;
   if PlayerInJail[Player] then PlayerPos[Player]=.;
  end;
  if last.round then output;
run;


proc transpose data=work.PlayerPos_LastRecRound 
                out=work.PlayerPos_LastRecRound_tp;*(drop=_name_ rename=(col1 = Field) where =(Field ne .));
 by game round;
 var PlayerPos: PlayerBalance:;
run;


data work.PlayerPos_LastRecRound_tp;
*data work.Monopoly_Visit_Scenarios;
 *length ScenarioName $50 ConsiderJail ConsiderAction Doublet3Jail $3;
 set work.PlayerPos_LastRecRound_tp;
 Player=input(compress(_name_,,"ul"),3.);
 Measure=strip(compress(tranwrd(_name_,'Player',''),,"d"));
 if Measure = "Pos" then Measure = "Field";

 *where col1 ne .;
 /*
 ScenarioName = &ScenarioName;
 ConsiderJail = upcase("&ConsiderJail");
 *ConsiderAction = upcase("&ConsiderChance");
 ConsiderChance = upcase("&ConsiderChance");
 Doublet3Jail = upcase("&Doublet3Jail");
 */
run;


proc sort data=work.PlayerPos_LastRecRound_tp;
 by game round Player measure;
run;

proc transpose data=work.PlayerPos_LastRecRound_tp out = work.Player_statistics(drop=_name_);
 by game round Player;
 id measure;
 var col1;
run;





/**************************************************************
*** Prepare Field Table
***************************************************************/


data work.PlayerPos_LastRecRound_tp;
*data work.Monopoly_Visit_Scenarios;
 length ScenarioName $50 ConsiderJail ConsiderAction Doublet3Jail $3;
 set work.PlayerPos_LastRecRound_tp;
 *drop _name_;
 rename col1 = Field;
 where col1 ne .;
 ScenarioName = &ScenarioName;
 ConsiderJail = upcase("&ConsiderJail");
 *ConsiderAction = upcase("&ConsiderChance");
 ConsiderChance = upcase("&ConsiderChance");
 Doublet3Jail = upcase("&Doublet3Jail");
run;




proc transpose data=work.PlayerPos_LastRecRound
               out=work.FieldStat_tp;
 by game round;
 var FieldBalance: FieldSetup:;
run;

data work.FieldStat_tp;
 set work.FieldStat_tp;
 Field=input(compress(_name_,,"ul"),3.);
 Measure=strip(compress(tranwrd(_name_,'Field',''),,"d"));
run;

proc sort data=work.FieldStat_tp;
 by game round field measure;
run;


proc transpose data=work.FieldStat_tp out = work.field_statistics(drop=_name_);
 by game round field;
 id measure;
 var col1;
run;

     


data work.FieldStat_tp;
*data work.Monopoly_Visit_Scenarios;
 length ScenarioName $50 ConsiderJail ConsiderAction Doublet3Jail $3;
 set work.FieldStat_tp;
 drop _name_;
 rename col1 = Value;
 ScenarioName = &ScenarioName;
 ConsiderJail = upcase("&ConsiderJail");
 *ConsiderAction = upcase("&ConsiderChance");
 ConsiderChance = upcase("&ConsiderChance");
 Doublet3Jail = upcase("&Doublet3Jail");
run;





 proc means data=    work.Player_statistics mean;
    where round=&cnt_rounds;
    var balance;
    class player;
 run;

proc means data=    work.Player_statistics n;
    *where round=70;
    var balance;
    class field;
 run;




 proc means data=    work.field_statistics mean maxdec=1;
    where round=&cnt_rounds;
    var balance ;
    *var setup;
    class field;
 run;



data gdata.field_statistics;*(promote=yes);
 set work.field_statistics;
run;

data gdata.player_statistics;*(promote=yes);
 set work.player_statistics;
run;

 
data casuser.field_statistics(promote=yes);
 set gdata.field_statistics;
run;

data casuser.player_statistics(promote=yes);
 set gdata.player_statistics;
run;
