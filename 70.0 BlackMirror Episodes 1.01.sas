

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

%do season = 1 %to &cnt_seasons.;

    libname tmdb_lib clear;
    libname omdb_lib clear;

    filename omdbjson clear;
    filename tmdbjson clear;

    filename tmdbjson temp;
    filename omdbjson temp;


    proc http
        url="https://api.themoviedb.org/3/tv/42009/season/&season.?api_key=&dmdb_key."
        out=tmdbjson;
    run;

    proc http
        url="http://www.omdbapi.com/?apikey=&omdb_key.%str(&)i=tt2085059%str(&)Season=&season."
        out=omdbjson;
    run;


    libname tmdb_lib json fileref=tmdbjson;
    libname omdb_lib json fileref=omdbjson;


    proc append base=work.TMDB_BlackMirror data=tmdb_lib.episodes force;
    run;

    proc append base=work.OMDB_BlackMirror data=omdb_lib.episodes force;
    run;


%end;

%mend; ** TMDB_Query;

%TMDB_OMDB_Query;


/***
    data tmdb_lib.episodes;
     lenght overview $ 1000;        
     set tmdb_lib.episodes; 
    run;
*/




/*******************************************************************
  OMDB
********************************************************************/

filename bmjson temp;

proc http
    url='http://www.omdbapi.com/?apikey=c4d6f026&i=tt2085059&Season=2'
    out=bmjson;
run;

libname bmapi json fileref=bmjson;

proc contents data=bmapi._all_;
run;


data black_mirror_s2;
    set bmapi.episodes;

    length season 8;
    season = 1;

    *rename
        Episode = episode_number
        Title   = title
        Released= release_date
        Plot    = description;

    *keep season episode_number title release_date imdbRating;
run;

proc print data=black_mirror_s1;
run;


filename bm_f41 temp;

proc http
    url='http://www.omdbapi.com/?apikey=c4d6f026&i=tt2085059&Season=4&episode=1&plot=full'
    out=bm_f41;
run;

libname bm_f json fileref=bm_f41;

proc print data=bm_f.root;
var plot;
run;


