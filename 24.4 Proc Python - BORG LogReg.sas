proc python;
submit;

import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

# Load SAS dataset into pandas
df = SAS.sd2df('BIGORG_20PCTSAMPLE', libref='WORK')

# Define variables
target = 'TargetBuy'
interval_vars = ['DemAge', 'DemAffl', 'PromTime', 'PromSpend']
class_vars = ['DemGender', 'PromClass']

# Drop missing values (important!)
df = df.dropna(subset=[target] + interval_vars + class_vars)

# Split X and y
X = df[interval_vars + class_vars]
y = df[target]

# Preprocessing:
# - Pass through interval variables
# - One-hot encode categorical variables
preprocessor = ColumnTransformer(
    transformers=[
        ('num', 'passthrough', interval_vars),
        ('cat', OneHotEncoder(drop='first'), class_vars)
    ]
)

# Create pipeline with logistic regression
model = Pipeline(steps=[
    ('prep', preprocessor),
    ('logit', LogisticRegression(max_iter=1000))
])

# Fit model
model.fit(X, y)

# Print coefficients
feature_names = (
    interval_vars +
    list(model.named_steps['prep']
         .named_transformers_['cat']
         .get_feature_names_out(class_vars))
)

coefficients = model.named_steps['logit'].coef_[0]

for name, coef in zip(feature_names, coefficients):
    print(f"{name}: {coef}")

# Intercept
print("Intercept:", model.named_steps['logit'].intercept_[0])


# =========================================================
# ✅ 1. Predicted probabilities → SAS dataset
# =========================================================

# Probability of class "1"
df['P_TargetBuy1'] = model.predict_proba(X)[:, 1]

# Write back to SAS
SAS.df2sd(df, 'BIGORG_SCORED_PY', libref='WORK')

# =========================================================
# ✅ 2. Parameter estimates table → SAS dataset
# =========================================================

# Get feature names
cat_features = list(
    model.named_steps['prep']
    .named_transformers_['cat']
    .get_feature_names_out(class_vars)
)

feature_names = interval_vars + cat_features

# Coefficients
coefficients = model.named_steps['logit'].coef_[0]

# Create parameter table
param_df = pd.DataFrame({
    'Variable': feature_names,
    'Estimate': coefficients
})

# Add intercept
intercept_df = pd.DataFrame({
    'Variable': ['Intercept'],
    'Estimate': [model.named_steps['logit'].intercept_[0]]
})

param_df = pd.concat([intercept_df, param_df], ignore_index=True)

# Write parameter table to SAS
SAS.df2sd(param_df, 'BIGORG_PARAMS_PY', libref='WORK')



endsubmit;
run;