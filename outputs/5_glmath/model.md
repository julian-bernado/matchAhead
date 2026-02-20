# Model Report: Grade 5, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_6 + raceth_3 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_6 + avg_raceth_3 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 302926 |
| Schools | 4303 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.0776 | 0.0482 | 1.61 |
| age | -0.0919 | 0.0076 | -12.04 |
| lep_ever | -0.0045 | 0.0002 | -18.74 |
| migrant_ever | -0.0004 | 0.0014 | -0.30 |
| homeless_ever | -0.0026 | 0.0005 | -5.88 |
| specialed_ever | -0.0133 | 0.0003 | -42.00 |
| attend_p0 | 0.1376 | 0.0024 | 56.39 |
| glmath_scr_m1 | 0.6680 | 0.0015 | 453.81 |
| gender_2 | 0.0005 | 0.0002 | 3.34 |
| raceth_4 | -0.0031 | 0.0013 | -2.34 |
| raceth_2 | 0.0129 | 0.0014 | 9.36 |
| raceth_6 | 0.0006 | 0.0013 | 0.45 |
| raceth_3 | -0.0081 | 0.0014 | -5.98 |
| raceth_Unknown | -0.0012 | 0.0014 | -0.87 |
| raceth_5 | 0.0025 | 0.0025 | 1.01 |
| avg_age | -0.4665 | 0.1028 | -4.54 |
| avg_lep_ever | -0.0046 | 0.0016 | -2.87 |
| avg_migrant_ever | -0.0152 | 0.0134 | -1.13 |
| avg_homeless_ever | -0.0036 | 0.0026 | -1.39 |
| avg_specialed_ever | -0.0065 | 0.0041 | -1.60 |
| avg_attend_p0 | 0.3186 | 0.0280 | 11.40 |
| avg_glmath_scr_m1 | 0.6883 | 0.0117 | 58.59 |
| avg_gender_2 | 0.0020 | 0.0036 | 0.55 |
| avg_raceth_4 | -0.0023 | 0.0238 | -0.10 |
| avg_raceth_2 | 0.0252 | 0.0241 | 1.05 |
| avg_raceth_6 | 0.0006 | 0.0239 | 0.02 |
| avg_raceth_3 | -0.0092 | 0.0240 | -0.38 |
| avg_raceth_Unknown | -0.0207 | 0.0259 | -0.80 |
| avg_raceth_5 | 0.0434 | 0.0444 | 0.98 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000195 | 0.0139 |
| Residual | 0.001888 | 0.0435 |

**ICC:** 0.0934

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -1031663.71 |
| BIC | -1031334.45 |
| Log-likelihood | 515862.85 |

## Convergence

- Converged: Yes
- Singular fit: No

