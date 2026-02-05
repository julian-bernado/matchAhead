# Model Report: Grade 5, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_6 + raceth_Unknown + raceth_2 + raceth_3 + raceth_4 + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_6 + avg_raceth_Unknown + avg_raceth_2 + avg_raceth_3 + avg_raceth_4 + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 29896 |
| Schools | 425 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.0675 | 0.1696 | 0.40 |
| age | -0.0408 | 0.0091 | -4.47 |
| lep_ever | -0.0031 | 0.0008 | -3.91 |
| migrant_ever | -0.0058 | 0.0047 | -1.25 |
| homeless_ever | -0.0009 | 0.0014 | -0.65 |
| specialed_ever | -0.0143 | 0.0010 | -14.31 |
| attend_p0 | 0.1556 | 0.0082 | 19.08 |
| glmath_scr_m1 | 0.6810 | 0.0047 | 146.30 |
| gender_2 | 0.0014 | 0.0005 | 2.74 |
| raceth_6 | -0.0041 | 0.0043 | -0.95 |
| raceth_Unknown | -0.0065 | 0.0046 | -1.42 |
| raceth_2 | 0.0055 | 0.0045 | 1.23 |
| raceth_3 | -0.0124 | 0.0044 | -2.82 |
| raceth_4 | -0.0077 | 0.0043 | -1.78 |
| raceth_5 | -0.0151 | 0.0079 | -1.91 |
| avg_age | -0.0847 | 0.1352 | -0.63 |
| avg_lep_ever | 0.0044 | 0.0055 | 0.80 |
| avg_migrant_ever | 0.0270 | 0.0359 | 0.75 |
| avg_homeless_ever | 0.0071 | 0.0095 | 0.75 |
| avg_specialed_ever | -0.0165 | 0.0136 | -1.21 |
| avg_attend_p0 | 0.3591 | 0.0942 | 3.81 |
| avg_glmath_scr_m1 | 0.7183 | 0.0412 | 17.43 |
| avg_gender_2 | -0.0018 | 0.0122 | -0.15 |
| avg_raceth_6 | -0.1116 | 0.0880 | -1.27 |
| avg_raceth_Unknown | -0.0474 | 0.0935 | -0.51 |
| avg_raceth_2 | -0.0811 | 0.0886 | -0.92 |
| avg_raceth_3 | -0.1178 | 0.0881 | -1.34 |
| avg_raceth_4 | -0.1078 | 0.0874 | -1.23 |
| avg_raceth_5 | -0.2060 | 0.1678 | -1.23 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000234 | 0.0153 |
| Residual | 0.001931 | 0.0439 |

**ICC:** 0.1079

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -100850.79 |
| BIC | -100593.32 |
| Log-likelihood | 50456.40 |

## Convergence

- Converged: Yes
- Singular fit: No

