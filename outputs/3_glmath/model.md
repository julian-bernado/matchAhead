# Model Report: Grade 3, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + gender_2 + raceth_2 + raceth_3 + raceth_6 + raceth_4 + raceth_Unknown + raceth_5 + raceth_7 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_2 + avg_raceth_3 + avg_raceth_6 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_5 + avg_raceth_7
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 2834 |
| Schools | 100 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.9552 | 0.2742 | 3.48 |
| age | -0.1102 | 0.0457 | -2.41 |
| specialed_ever | -0.0246 | 0.0069 | -3.58 |
| homeless_ever | -0.0038 | 0.0099 | -0.38 |
| lep_ever | -0.0308 | 0.0062 | -4.96 |
| migrant_ever | -0.0061 | 0.0118 | -0.52 |
| attend_p0 | 0.0085 | 0.0321 | 0.26 |
| gender_2 | 0.0100 | 0.0048 | 2.08 |
| raceth_2 | -0.0041 | 0.0061 | -0.67 |
| raceth_3 | -0.0108 | 0.0068 | -1.59 |
| raceth_6 | 0.0056 | 0.0163 | 0.34 |
| raceth_4 | -0.0106 | 0.0097 | -1.10 |
| raceth_Unknown | -0.0200 | 0.0146 | -1.37 |
| raceth_5 | -0.0210 | 0.0143 | -1.47 |
| raceth_7 | -0.0204 | 0.0190 | -1.07 |
| avg_age | -0.2683 | 0.2795 | -0.96 |
| avg_specialed_ever | -0.0117 | 0.0362 | -0.32 |
| avg_homeless_ever | -0.1183 | 0.0605 | -1.96 |
| avg_lep_ever | -0.0393 | 0.0354 | -1.11 |
| avg_migrant_ever | 0.0470 | 0.0744 | 0.63 |
| avg_attend_p0 | -0.0596 | 0.1907 | -0.31 |
| avg_gender_2 | -0.0044 | 0.0270 | -0.16 |
| avg_raceth_2 | -0.0746 | 0.0372 | -2.00 |
| avg_raceth_3 | -0.0531 | 0.0391 | -1.36 |
| avg_raceth_6 | -0.1051 | 0.1076 | -0.98 |
| avg_raceth_4 | 0.0128 | 0.0488 | 0.26 |
| avg_raceth_Unknown | -0.0681 | 0.0855 | -0.80 |
| avg_raceth_5 | -0.0399 | 0.0732 | -0.54 |
| avg_raceth_7 | 0.0601 | 0.1022 | 0.59 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000067 | 0.0082 |
| Residual | 0.015688 | 0.1253 |

**ICC:** 0.0043

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -3527.41 |
| BIC | -3342.98 |
| Log-likelihood | 1794.71 |

## Convergence

- Converged: Yes
- Singular fit: No

