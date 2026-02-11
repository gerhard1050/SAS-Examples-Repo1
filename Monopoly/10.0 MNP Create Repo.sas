data work.Monopoly_Visit_Scenarios;
  length 
  ScenarioName $40 
  ConsiderJail 
  ConsiderChance 
  Doublet3Jail $3
  Field 
  Game 
  Round 
  Player 8;
  if game = . then delete;
run;      
  
%CASTableLoad(Monopoly_Visit_Scenarios,inlib=work);


