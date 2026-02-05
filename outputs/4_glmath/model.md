# Model Report: Grade 4, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_3 + raceth_4 + raceth_6 + raceth_2 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_3 + avg_raceth_4 + avg_raceth_6 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 45689 |
| Schools | 456 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.0272 | 0.1402 | -0.19 |
| age | -0.0606 | 0.0087 | -6.96 |
| lep_ever | -0.0105 | 0.0007 | -16.06 |
| migrant_ever | 0.0085 | 0.0029 | 2.89 |
| homeless_ever | -0.0054 | 0.0011 | -4.68 |
| specialed_ever | -0.0111 | 0.0008 | -13.77 |
| attend_p0 | 0.1452 | 0.0063 | 22.95 |
| glmath_scr_m1 | 0.7431 | 0.0041 | 180.07 |
| gender_2 | 0.0036 | 0.0005 | 7.48 |
| raceth_3 | -0.0091 | 0.0035 | -2.62 |
| raceth_4 | -0.0022 | 0.0034 | -0.64 |
| raceth_6 | 0.0049 | 0.0034 | 1.41 |
| raceth_2 | 0.0198 | 0.0036 | 5.44 |
| raceth_Unknown | 0.0000 | 0.0037 | 0.01 |
| raceth_5 | 0.0047 | 0.0062 | 0.75 |
| avg_age | -0.0805 | 0.1321 | -0.61 |
| avg_lep_ever | 0.0025 | 0.0051 | 0.49 |
| avg_migrant_ever | -0.0603 | 0.0463 | -1.30 |
| avg_homeless_ever | 0.0026 | 0.0071 | 0.37 |
| avg_specialed_ever | -0.0134 | 0.0138 | -0.97 |
| avg_attend_p0 | 0.3649 | 0.1031 | 3.54 |
| avg_glmath_scr_m1 | 0.7926 | 0.0356 | 22.26 |
| avg_gender_2 | 0.0093 | 0.0129 | 0.72 |
| avg_raceth_3 | -0.1149 | 0.0502 | -2.29 |
| avg_raceth_4 | -0.1035 | 0.0495 | -2.09 |
| avg_raceth_6 | -0.0987 | 0.0499 | -1.98 |
| avg_raceth_2 | -0.0698 | 0.0508 | -1.37 |
| avg_raceth_Unknown | -0.0637 | 0.0585 | -1.09 |
| avg_raceth_5 | -0.2127 | 0.1317 | -1.62 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000200 | 0.0142 |
| Residual | 0.002540 | 0.0504 |

**ICC:** 0.0731

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -142189.46 |
| BIC | -141918.84 |
| Log-likelihood | 71125.73 |

## Convergence

- Converged: Yes
- Singular fit: No

