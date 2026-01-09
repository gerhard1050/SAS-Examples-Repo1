
%macro CASTableLoad(data,inlib=work,outlib=casuser);

proc casutil incaslib="&outlib" outcaslib="&outlib";
 droptable casdata="&data" quiet;
 load data=&inlib..&data. casout="&data";
 save casdata="&data" casout="&data" replace;
 promote casdata="&data" casout="&data";

%mend;

%CASTableLoad(cars,inlib=sashelp);

libname casuser 	cas caslib="casuser";
libname adml 		cas caslib="adml";
libname helpdata 	cas caslib="helpdata";
libname svso 		cas caslib="svso";
libname tundata 	cas caslib="tundata";

*caslib _all_ assign;

