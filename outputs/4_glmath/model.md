# Model Report: Grade 4, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_Unknown + raceth_3 + raceth_5 + raceth_6 + raceth_7 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_3 + avg_raceth_5 + avg_raceth_6 + avg_raceth_7
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 2861 |
| Schools | 100 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.2098 | 0.2052 | 1.02 |
| age | -0.0080 | 0.0345 | -0.23 |
| specialed_ever | -0.0155 | 0.0045 | -3.42 |
| homeless_ever | -0.0018 | 0.0070 | -0.26 |
| lep_ever | -0.0009 | 0.0040 | -0.23 |
| migrant_ever | -0.0009 | 0.0081 | -0.11 |
| attend_p0 | 0.0115 | 0.0209 | 0.55 |
| glmath_scr_m1 | 0.7442 | 0.0130 | 57.15 |
| gender_2 | -0.0032 | 0.0032 | -1.02 |
| raceth_4 | -0.0077 | 0.0066 | -1.15 |
| raceth_2 | -0.0033 | 0.0040 | -0.83 |
| raceth_Unknown | 0.0159 | 0.0095 | 1.67 |
| raceth_3 | -0.0041 | 0.0044 | -0.91 |
| raceth_5 | 0.0055 | 0.0096 | 0.57 |
| raceth_6 | -0.0103 | 0.0113 | -0.91 |
| raceth_7 | -0.0243 | 0.0111 | -2.19 |
| avg_age | 0.1136 | 0.1959 | 0.58 |
| avg_specialed_ever | 0.0307 | 0.0232 | 1.32 |
| avg_homeless_ever | -0.0197 | 0.0404 | -0.49 |
| avg_lep_ever | 0.0192 | 0.0214 | 0.90 |
| avg_migrant_ever | -0.0123 | 0.0398 | -0.31 |
| avg_attend_p0 | -0.1734 | 0.1210 | -1.43 |
| avg_glmath_scr_m1 | 0.7438 | 0.0639 | 11.64 |
| avg_gender_2 | 0.0366 | 0.0194 | 1.89 |
| avg_raceth_4 | -0.0119 | 0.0378 | -0.32 |
| avg_raceth_2 | 0.0245 | 0.0237 | 1.03 |
| avg_raceth_Unknown | 0.0385 | 0.0607 | 0.63 |
| avg_raceth_3 | -0.0290 | 0.0298 | -0.98 |
| avg_raceth_5 | -0.0144 | 0.0519 | -0.28 |
| avg_raceth_6 | -0.0036 | 0.0591 | -0.06 |
| avg_raceth_7 | 0.0754 | 0.0660 | 1.14 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000008 | 0.0027 |
| Residual | 0.006915 | 0.0832 |

**ICC:** 0.0011

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -5878.59 |
| BIC | -5681.95 |
| Log-likelihood | 2972.30 |

## Convergence

- Converged: Yes
- Singular fit: No

