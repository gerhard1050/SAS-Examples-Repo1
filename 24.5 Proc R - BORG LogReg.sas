proc r;
submit;




# =========================================================
# 1. Read SAS dataset into R
# =========================================================

df <- sd2df("WORK.BIGORG_20PCTSAMPLE")

#df <- read.sasdata(table = "BIGORG_20PCTSAMPLE", libref = "WORK")

# =========================================================
# 2. Prepare variables
# =========================================================

# Convert categorical variables to factors
df$DemGender <- as.factor(df$DemGender)
df$PromClass <- as.factor(df$PromClass)

# Ensure target is numeric (0/1)
df$TargetBuy <- as.numeric(df$TargetBuy)

# Drop missing values
df <- df[complete.cases(df[, c("TargetBuy",
                              "DemAge", "DemAffl", "PromTime", "PromSpend",
                              "DemGender", "PromClass")]), ]

# =========================================================
# 3. Logistic regression (like PROC LOGISTIC)
# =========================================================

model <- glm(
  TargetBuy ~ DemAge + DemAffl + PromTime + PromSpend +
              DemGender + PromClass,
  data = df,
  family = binomial(link = "logit")
)

# =========================================================
# 4. Predicted probabilities → SAS
# =========================================================

df$P_TargetBuy1 <- predict(model, type = "response")

# Write scored dataset back to SAS
# write.sasdata(df, table = "BIGORG_SCORED_R", libref = "WORK")

df2sd(df, "BIGORG_SCORED_R",libref='WORK')

# =========================================================
# 5. Parameter estimates → SAS
# =========================================================

# Extract coefficients
coef_table <- as.data.frame(summary(model)$coefficients)

# Clean up table
coef_table$Variable <- rownames(coef_table)
rownames(coef_table) <- NULL

# Reorder columns
coef_table <- coef_table[, c("Variable",
                            "Estimate",
                            "Std. Error",
                            "z value",
                            "Pr(>|z|)")]

# Write to SAS
# write.sasdata(coef_table, table = "BIGORG_PARAMS_R", libref = "WORK")

df2sd(coef_table, "BIGORG_PARAMS_R", libref='WORK')

endsubmit;
run;