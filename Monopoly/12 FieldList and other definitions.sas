Data work.MonopolyFieldList;
    infile datalines dlm='|' dsd truncover;
    length Field 3 fieldname $40;
    input Field fieldname $;
datalines;
1|GO
2|Mediterranean Avenue
3|Community Chest
4|Baltic Avenue
5|Income Tax
6|Reading Railroad
7|Oriental Avenue
8|Chance
9|Vermont Avenue
10|Connecticut Avenue
11|Jail / Just Visiting
12|St. Charles Place
13|Electric Company
14|States Avenue
15|Virginia Avenue
16|Pennsylvania Railroad
17|St. James Place
18|Community Chest
19|Tennessee Avenue
20|New York Avenue
21|Free Parking
22|Kentucky Avenue
23|Chance
24|Indiana Avenue
25|Illinois Avenue
26|B&O Railroad
27|Atlantic Avenue
28|Ventnor Avenue
29|Water Works
30|Marvin Gardens
31|Go To Jail
32|Pacific Avenue
33|North Carolina Avenue
34|Community Chest
35|Pennsylvania Avenue
36|Short Line
37|Chance
38|Park Place
39|Luxury Tax
40|Boardwalk
;
run;


data monopoly_cards;
    infile datalines dlm='|' dsd truncover;
    length deck $15 cardtext $120;
    input deck $ cardtext $ moveto;
datalines;
CommunityChest|Advance to GO (Collect $200)|1
CommunityChest|Bank error in your favor – Collect $200|.
CommunityChest|Doctor’s fees – Pay $50|.
CommunityChest|From sale of stock you get $50|.
CommunityChest|Get Out of Jail Free|.
CommunityChest|Go to Jail – Go directly to Jail|11
CommunityChest|Grand Opera Night – Collect $50 from every player|.
CommunityChest|Holiday Fund matures – Collect $100|.
CommunityChest|Income tax refund – Collect $20|.
CommunityChest|It is your birthday – Collect $10 from every player|.
CommunityChest|Life insurance matures – Collect $100|.
CommunityChest|Hospital fees – Pay $50|.
CommunityChest|School fees – Pay $50|.
CommunityChest|Receive $25 consultancy fee|.
CommunityChest|You are assessed for street repairs – Pay $40 per house, $115 per hotel|.
CommunityChest|You have won second prize in a beauty contest – Collect $10|.
Chance|Advance to GO (Collect $200)|1
Chance|Advance to Illinois Avenue|25
Chance|Advance to St. Charles Place|12
Chance|Advance to nearest Utility (from 8 or 23)|13
Chance|Advance to nearest Utility (from 37)|29
Chance|Advance to nearest Railroad (from 8)|16
Chance|Advance to nearest Railroad (from 23)|26
Chance|Advance to nearest Railroad (from 37)|6
Chance|Bank pays you dividend of $50|.
Chance|Get Out of Jail Free|.
Chance|Go Back 3 Spaces (from 8)|5
Chance|Go Back 3 Spaces (from 23)|20
Chance|Go Back 3 Spaces (from 37)|34
Chance|Go to Jail – Go directly to Jail|11
Chance|Make general repairs on all your property – Pay $25 per house, $100 per hotel|.
Chance|Pay poor tax of $15|.
Chance|Take a trip to Reading Railroad|6
Chance|Take a walk on the Boardwalk|40
Chance|You have been elected Chairman of the Board – Pay each player $50|.
Chance|Your building loan matures – Collect $150|.
;
run;
