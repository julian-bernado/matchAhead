# Model Report: Grade 3, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + gender_2 + raceth_6 + raceth_4 + raceth_2 + raceth_3 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_6 + avg_raceth_4 + avg_raceth_2 + avg_raceth_3 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 379935 |
| Schools | 4583 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.1900 | 0.0512 | -3.71 |
| age | -0.0456 | 0.0037 | -12.16 |
| lep_ever | -0.0129 | 0.0003 | -43.60 |
| migrant_ever | -0.0058 | 0.0017 | -3.41 |
| homeless_ever | -0.0072 | 0.0005 | -13.50 |
| specialed_ever | -0.0564 | 0.0003 | -171.26 |
| attend_p0 | 0.3084 | 0.0031 | 100.61 |
| gender_2 | 0.0089 | 0.0002 | 42.10 |
| raceth_6 | 0.0093 | 0.0016 | 6.01 |
| raceth_4 | -0.0093 | 0.0015 | -6.02 |
| raceth_2 | 0.0351 | 0.0016 | 21.58 |
| raceth_3 | -0.0283 | 0.0016 | -18.02 |
| raceth_Unknown | 0.0015 | 0.0017 | 0.92 |
| raceth_5 | -0.0026 | 0.0030 | -0.86 |
| avg_age | 0.0118 | 0.0531 | 0.22 |
| avg_lep_ever | -0.0118 | 0.0020 | -5.80 |
| avg_migrant_ever | 0.0075 | 0.0184 | 0.40 |
| avg_homeless_ever | -0.0212 | 0.0034 | -6.24 |
| avg_specialed_ever | -0.0565 | 0.0053 | -10.76 |
| avg_attend_p0 | 0.9406 | 0.0345 | 27.24 |
| avg_gender_2 | 0.0009 | 0.0048 | 0.20 |
| avg_raceth_6 | 0.0102 | 0.0161 | 0.63 |
| avg_raceth_4 | -0.0104 | 0.0158 | -0.65 |
| avg_raceth_2 | 0.0896 | 0.0164 | 5.47 |
| avg_raceth_3 | -0.0411 | 0.0161 | -2.55 |
| avg_raceth_Unknown | 0.0369 | 0.0203 | 1.82 |
| avg_raceth_5 | -0.0090 | 0.0539 | -0.17 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000376 | 0.0194 |
| Residual | 0.004111 | 0.0641 |

**ICC:** 0.0838

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -999613.58 |
| BIC | -999299.00 |
| Log-likelihood | 499835.79 |

## Convergence

- Converged: Yes
- Singular fit: No

