    
    %let season=1;
    
    proc http
        url="http://www.omdbapi.com/?apikey=&omdb_key.%str(&)i=tt2085059%str(&)Season=&season."
        out=omdbjson;
    run;



    

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


