
data WORK.PROPERTY_COSTREVENUE;
  infile datalines dsd truncover;
  input 
    Field : best12.
    M0    : best12.
    M1    : best12.
    M2    : best12.
    M3    : best12.
    M4    : best12.
    M5    : best12.
    C0    : best12.
    C1    : best12.;
  format _numeric_ best12.;
datalines4;
2,2,10,30,90,160,250,60,50
4,4,20,60,180,320,450,60,50
7,6,30,90,270,400,550,100,50
9,6,30,90,270,400,550,100,50
10,8,40,100,300,450,600,120,50
12,10,50,150,450,625,750,140,100
14,10,50,150,450,625,750,140,100
15,12,60,180,500,700,900,160,100
17,14,70,200,550,750,950,180,100
19,14,70,200,550,750,950,180,100
20,16,80,220,600,800,1000,200,100
22,18,90,250,700,875,1050,220,150
24,18,90,250,700,875,1050,220,150
25,20,100,300,750,925,1100,240,150
27,22,110,330,800,975,1150,260,150
28,22,110,330,800,975,1150,260,150
30,24,120,360,850,1025,1200,280,150
32,26,130,390,900,1100,1275,300,200
33,26,130,390,900,1100,1275,300,200
35,28,150,450,1000,1200,1400,320,200
38,35,175,500,1100,1300,1500,350,200
40,50,200,600,1400,1700,2000,400,200
;;;;
run;





*Property_CostRevenue;



*** Cost; 

data c0;
 set Property_CostRevenue;
 fmtname = 'c0_';
 type = 'i';
 rename field=start c0=label;
run;

proc format cntlin=c0 ; run;


data c1;
 set Property_CostRevenue;
 fmtname = 'c1_';
 type = 'i';
 rename field=start c1=label;
run;

proc format cntlin=c1 ; run;



*** Income; 

data m0;
 set Property_CostRevenue;
 fmtname = 'm0_';
 type = 'i';
 rename field=start m0=label;
run;

proc format cntlin=m0 ; run;


data m1;
 set Property_CostRevenue;
 fmtname = 'm1_';
 type = 'i';
 rename field=start m1=label;
run;

proc format cntlin=m1 ; run;


data m2;
 set Property_CostRevenue;
 fmtname = 'm2_';
 type = 'i';
 rename field=start m2=label;
run;

proc format cntlin=m2 ; run;


data m3;
 set Property_CostRevenue;
 fmtname = 'm3_';
 type = 'i';
 rename field=start m3=label;
run;

proc format cntlin=m3 ; run;


data m4;
 set Property_CostRevenue;
 fmtname = 'm4_';
 type = 'i';
 rename field=start m4=label;
run;

proc format cntlin=m4 ; run;


data m5;
 set Property_CostRevenue;
 fmtname = 'm5_';
 type = 'i';
 rename field=start m5=label;
run;

proc format cntlin=m5 ; run;

