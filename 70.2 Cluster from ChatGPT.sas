***
*** Add Clusterings generated  ChatGPT in chat:
https://chatgpt.com/share/6977b903-5d60-8004-89d0-1b704cd348bf;


data work.BlackMirror_GPT_Full;
length title $50 cluster_id $3 cluster_name $80;
infile datalines dlm='|' truncover;
input season episode title :$50. cluster_id :$3. cluster_name :$80.;
datalines;
1|1|The National Anthem|C1|Media, Spectacle & Social Pressure
1|2|Fifteen Million Merits|C1|Media, Spectacle & Social Pressure
1|3|The Entire History of You|C3|Love, Memory & Identity
2|1|Be Right Back|C2|AI, Consciousness & Digital Afterlife
2|2|White Bear|C4|Crime, Punishment & Justice
2|3|The Waldo Moment|C6|Satire & Corporate Dystopia
3|1|Nosedive|C1|Media, Spectacle & Social Pressure
3|2|Playtest|C5|Gaming, War & Virtual Reality
3|3|Shut Up and Dance|C4|Crime, Punishment & Justice
3|4|San Junipero|C3|Love, Memory & Identity
3|5|Men Against Fire|C4|Crime, Punishment & Justice
3|6|Hated in the Nation|C4|Crime, Punishment & Justice
4|1|USS Callister|C2|AI, Consciousness & Digital Afterlife
4|2|Arkangel|C3|Love, Memory & Identity
4|3|Crocodile|C4|Crime, Punishment & Justice
4|4|Hang the DJ|C3|Love, Memory & Identity
4|5|Metalhead|C5|Gaming, War & Virtual Reality
4|6|Black Museum|C2|AI, Consciousness & Digital Afterlife
5|1|Striking Vipers|C3|Love, Memory & Identity
5|2|Smithereens|C1|Media, Spectacle & Social Pressure
5|3|Rachel, Jack and Ashley Too|C2|AI, Consciousness & Digital Afterlife
6|1|Joan Is Awful|C1|Media, Spectacle & Social Pressure
6|2|Loch Henry|C3|Love, Memory & Identity
6|3|Beyond the Sea|C2|AI, Consciousness & Digital Afterlife
6|4|Mazey Day|C1|Media, Spectacle & Social Pressure
6|5|Demon 79|C2|AI, Consciousness & Digital Afterlife
7|1|Common People|C1|Media, Spectacle & Social Pressure
7|2|Bête Noire|C7|Technological & Emotional Exploitation
7|3|Hotel Reverie|C2|AI, Consciousness & Digital Afterlife
7|4|Plaything|C5|Gaming, War & Virtual Reality
7|5|Eulogy|C3|Love, Memory & Identity
7|6|USS Callister: Into Infinity|C2|AI, Consciousness & Digital Afterlife
;
run;


data work.BlackMirror_GPT_TMDB_OMDB;
    length title $50 cluster_id $3 cluster_name $80;
    infile datalines dlm='|' dsd truncover;
    input season episode title :$50. cluster_id :$3. cluster_name :$80.;
    datalines;
1|1|The National Anthem|C2|Social Pressure, Media & Networked Control
1|2|Fifteen Million Merits|C2|Social Pressure, Media & Networked Control
1|3|The Entire History of You|C3|Memory, Relationships & Emotional Tech Effects
2|1|Be Right Back|C1|AI, Digital Consciousness & Technology Affecting Humans
2|2|White Bear|C4|Crime, Coercion & Justice
2|3|The Waldo Moment|C2|Social Pressure, Media & Networked Control
3|1|Nosedive|C2|Social Pressure, Media & Networked Control
3|2|Playtest|C5|Virtual/Simulated Worlds & Game-like Tech
3|3|Shut Up and Dance|C4|Crime, Coercion & Justice
3|4|San Junipero|C1|AI, Digital Consciousness & Technology Affecting Humans
3|5|Men Against Fire|C5|Virtual/Simulated Worlds & Game-like Tech
3|6|Hated in the Nation|C4|Crime, Coercion & Justice
4|1|USS Callister|C5|Virtual/Simulated Worlds & Game-like Tech
4|2|Arkangel|C3|Memory, Relationships & Emotional Tech Effects
4|3|Crocodile|C4|Crime, Coercion & Justice
4|4|Hang the DJ|C3|Memory, Relationships & Emotional Tech Effects
4|5|Metalhead|C6|Horror, Absurd or Extreme Tech Consequences
4|6|Black Museum|C6|Horror, Absurd or Extreme Tech Consequences
5|1|Striking Vipers|C5|Virtual/Simulated Worlds & Game-like Tech
5|2|Smithereens|C2|Social Pressure, Media & Networked Control
5|3|Rachel, Jack and Ashley Too|C1|AI, Digital Consciousness & Technology Affecting Humans
6|1|Joan Is Awful|C2|Social Pressure, Media & Networked Control
6|2|Loch Henry|C4|Crime, Coercion & Justice
6|3|Beyond the Sea|C1|AI, Digital Consciousness & Technology Affecting Humans
6|4|Mazey Day|C6|Horror, Absurd or Extreme Tech Consequences
6|5|Demon 79|C6|Horror, Absurd or Extreme Tech Consequences
7|1|Common People|C2|Social Pressure, Media & Networked Control
7|2|Bête Noire|C6|Horror, Absurd or Extreme Tech Consequences
7|3|Hotel Reverie|C1|AI, Digital Consciousness & Technology Affecting Humans
7|4|Plaything|C5|Virtual/Simulated Worlds & Game-like Tech
7|5|Eulogy|C3|Memory, Relationships & Emotional Tech Effects
7|6|USS Callister: Into Infinity|C1|AI, Digital Consciousness & Technology Affecting Humans
;
run;

/* Verify the dataset */
proc print data=black_mirror_plot_clusters;
    title "Black Mirror Episodes Clustered by OMDb/TMDb Plot";
run;
