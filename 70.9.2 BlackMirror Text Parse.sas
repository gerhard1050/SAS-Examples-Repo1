/* 1. Download the Wikipedia page */
filename wiki_htm temp;

proc http
    url="https://en.wikipedia.org/wiki/List_of_Black_Mirror_episodes#Series_1_(2011)"
    method="get"
    out=wiki_htm;
run;

/* 2. Read the HTML into a text file for parsing */
data html_raw;
    infile wiki_htm lrecl=32767;
    input line $char32767.;
run;

/* 3. Parse the HTML for episode table rows */
/*    Note: Wikipedia uses <tr> for rows and <th>/<td> for cells */
data ep_table (keep=title description season epnum release);
    length title description season epnum release $200;
    retain title description season epnum release;

    infile wiki_htm lrecl=32767 truncover;
    input line $char32767.;

    /* Detect start of season group */
    if prxmatch("/Series\s+\d+/", line) then do;
        *call prx(substr(line, 1, length(line)), _p, position, length);
        season = prxchange("s/.*Series\s+([0-9]+).*/\1/", -1, line);
    end;

    /* Look for table row start */
    if prxmatch("/<tr/", line) then do;
        /* Reset fields at each new row */
        title = ""; description = ""; epnum = ""; release = "";
    end;

    /* Episode number (first <td>) */
    if prxmatch("/<td[^>]*>[0-9]+<\/td>/", line) then do;
        epnum = prxchange("s/<[^>]*>//g", -1, line);
    end;

    /* Episode title (enclosed in quotes) */
    *if prxmatch("/title=\"*?\"/", line) then do;
     *   title = prxchange('s/*title=\"([^\"]+)\".*/\1/', -1, line);
    *end;

    /* Description within <td> after title */
    if prxmatch("/<td>.*<p>.*<\/p><\/td>/", line) then do;
        description = prxchange("s/<[^>]*>//g", -1, line);
    end;

    /* Release date (formatted text with year) */
    if prxmatch("/[0-9]{1,2}\s+[A-Za-z]+\s+[0-9]{4}/", line) then do;
        release = prxchange("s/.*?([0-9]{1,2}\s+[A-Za-z]+\s+[0-9]{4}).*/\1/", -1, line);
    end;

    /* When all key fields found, output record */
    if title ne "" and epnum ne "" and release ne "" then output;
run;

/* 4. Review the dataset */
proc print data=ep_table;
    title "Black Mirror Episodes Scraped from Wikipedia";
run;
