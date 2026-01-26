

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



proc delete data=
    work.TMDB_BlackMirror
    work.OMDB_BlackMirror
;
run;



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

    proc append base=work.TMDB_BlackMirror data=tmdb_lib.episodes force;
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

            proc append base=work.OMDB_BlackMirror data=omdb_lib.root force;
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


