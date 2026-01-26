

/*******************************************
*** 00. Init
***
*** API Keys;
*******************************************/

%let omdb_key=c4d6f026;
%let dmdb_key=9eb229b0bed20d2c97054c5b96d52e15;

*** User TMDB = bmirror;
** API token für den Lesezugriff
eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ZWIyMjliMGJlZDIwZDJjOTcwNTRjNWI5NmQ1MmUxNSIsIm5iZiI6MTc2OTQyNzkzOS4yNDMsInN1YiI6IjY5Nzc1M2UzNjUyOGM5MTVlOGI2ODRhZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.y-ItuDy-mvLBPYmiLOUDhWyyRuou15XWiqDbavZ73zA
** API schlüssel
9eb229b0bed20d2c97054c5b96d52e15
*proc http
    url="https://api.themoviedb.org/3/tv/42009/season/&episode.?api_key=9eb229b0bed20d2c97054c5b96d52e15"
    out=tmdbjson;
;
**** https://api.themoviedb.org/3/tv/42009/season/1?api_key=YOUR_API_KEY;
**** https://api.themoviedb.org/3/tv/60735?api_key=YOUR_API_KEY;




/*******************************************************************
  TMDB
********************************************************************/
options mprint;

%macro TMDB_OMDB_Query;
/*
data work.OMDB_BlackMirror;
 length Title Director Writer Actors $200 Plot $2000;
run;

data work.TMDB_BlackMirror;
 length Name $200 Overview $2000;
run;
*/

/**/ 
proc delete data=
    work.TMDB_BlackMirror
    work.OMDB_BlackMirror
;
run;
/**/


/*******************************************
*** Step 1 - Count the number of Seasons ***
*******************************************/


filename cnt_seas temp;

proc http
    url='https://api.themoviedb.org/3/tv/42009?api_key=9eb229b0bed20d2c97054c5b96d52e15'
    out=cnt_seas;
run;

libname cnt_s json fileref=cnt_seas;

proc sql noprint;
 select max(value)
 into :Cnt_seasons
 from CNT_S.ALLDATA
 where upcase(p1)="SEASONS" 
    and upcase(p2)="SEASON_NUMBER";
 quit;
 
 %put ------------------------;
 %put Number of Seasons found ;
 %put &=cnt_seasons;
 %put ------------------------;




%do season = 1 %to &cnt_seasons.;
 
    libname tmdb_lib clear;

    filename tmdbjson clear;
    filename tmdbjson temp;

    *** Query TMDB Database;
    proc http
        url="https://api.themoviedb.org/3/tv/42009/season/&season.?api_key=&dmdb_key."
        out=tmdbjson;
    run;

    libname tmdb_lib json fileref=tmdbjson;

    ** temporary table to format char var length;
    data work.TMDB_tmp;
        length Name $200 Overview $2000;
        set tmdb_lib.episodes;
    run;

    proc append base=work.TMDB_BlackMirror data=work.TMDB_tmp force;
    run;


    *** Query OMDB Database;
    
    proc sql noprint;
    select max(episode_number)
    into :Cnt_episodes
    from TMDB_LIB.EPISODES
    quit;

     %put ------------------------;
     %put Number of Episodes found in Season = &season.;
     %put &=Cnt_episodes;
     %put ------------------------;



    %do episode = 1 %to &cnt_episodes.;
    
            libname omdb_lib clear;

            filename omdbjson clear;
            filename omdbjson temp;

            proc http
                url="http://www.omdbapi.com/?apikey=&omdb_key.%str(&)i=tt2085059%str(&)Season=&season.%str(&)episode=&episode.%str(&)plot=full"
                out=omdbjson;
            run;

            libname omdb_lib json fileref=omdbjson;

            ** temporary table to format char var length;
            data work.OMDB_tmp;
                length Title Director Writer Actors $200 Plot $2000;
                set omdb_lib.root;
            run;

            proc append base=work.OMDB_BlackMirror data=work.OMDB_tmp force;
            run;
            
    %end; ** Episodes Loop;

%end; ** Season Loop;

%mend; ** TMDB_Query;

%TMDB_OMDB_Query;


/***
    data tmdb_lib.episodes;
     lenght overview $ 1000;        
     set tmdb_lib.episodes; 
    run;
*/


*** Merge tables together an rename;


proc sql;
 create table gdata.BlackMirrorDB
 as
 select 
  t.season_number as Season
 ,t.episode_number as Episode
 ,t.id as Episode_ID
 ,t.name as Episode_Title
 ,t.overview as Plot_TMDB
 ,o.plot as Plot_OMDB
 /*,cats(Plot_TMDB,Plot_OMDB) as Plot_Combined*/
 ,input(t.air_date,yymmdd10.) as Air_Date format = yymmddp10.
 ,year(calculated Air_Date) as Year
 ,t.runtime as Runtime_Mins
 ,t.vote_average as Rating_TMDB
 ,t.vote_count as VoteCnt_TMDB
 ,input(o.imdbRating,8.) as Rating_IMDB
 ,input(o.imdbVotes,8.) as VoteCnt_IMDB
 ,o.director
 ,o.writer
 ,o.actors
 ,o.awards
 from WORK.TMDB_BLACKMIRROR as t,
      WORK.OMDB_BLACKMIRROR as o
where input(o.season,8.) = t.season_number
   and input(o.episode,8.) = t.episode_number
   ;
quit;


*** Add Clusterings generated  ChatGPT in chat:
https://chatgpt.com/share/6977b903-5d60-8004-89d0-1b704cd348bf;


proc sql;
 create table gdata.BlackMirrorDB_CLS
 as select
 a.*
 ,b.cluster_ID as GPT_FULL_CLSID
 ,b.cluster_name as GPT_FULL_CLSNAME
 ,b.cluster_ID as GPT_TMDB_CLSID
 ,b.cluster_name as GPT_TMDB_CLSNAME
 from gdata.BlackMirrorDB as a
 ,WORK.BLACKMIRROR_GPT_FULL as b
 ,WORK.BLACKMIRROR_GPT_TMDB_OMDB as c
 where a.season = b.season and a.season = c.season
 and a.episode = b.episode and a.episode = c.episode;
quit;


cas cas1;
caslib _all_ assign;




%macro CASTableLoad(data,inlib=work,outlib=casuser);

proc casutil incaslib="&outlib" outcaslib="&outlib";
 droptable casdata="&data" quiet;
 load data=&inlib..&data. casout="&data";
 save casdata="&data" casout="&data" replace;
 promote casdata="&data" casout="&data";

%mend;

%CASTableLoad(BLACKMIRRORDB_CLS,inlib=GDATA);

