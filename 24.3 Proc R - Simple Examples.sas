proc r;
submit;

cars_df <- sd2df("sashelp.cars")

show(cars_df, title = "SASHELP.CARS (First 10 Rows)", count = 10)

summary_stats <- data.frame(
  Statistic = c("Mean MPG", "Max Horsepower", "Min Weight",
                "Avg MSRP", "Total Cars"),
  Value = c(
    mean(cars_df$MPG_City, na.rm = TRUE),
    max(cars_df$Horsepower, na.rm = TRUE),
    min(cars_df$Weight, na.rm = TRUE),
    mean(cars_df$MSRP, na.rm = TRUE),
    nrow(cars_df)
  )
)

show(summary_stats, title = "Cars Dataset Summary Statistics")
endsubmit;
run;


data work.mydata;
  length a 8;
  length b_value 8;
  length var_32 $32;
  var_32 = "x";
  a = 1;
  b_value = 2;
  output;
run;

proc r;
submit;
df <- sd2df("mydata", "work");
show(df)
endsubmit;
run;