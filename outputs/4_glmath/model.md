# Model Report: Grade 4, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_3 + raceth_5 + raceth_6 + raceth_7 + raceth_Unknown + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_3 + avg_raceth_5 + avg_raceth_6 + avg_raceth_7 + avg_raceth_Unknown
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 28330 |
| Schools | 1000 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.1441 | 0.0633 | 2.28 |
| age | 0.0117 | 0.0119 | 0.99 |
| specialed_ever | -0.0066 | 0.0015 | -4.44 |
| homeless_ever | 0.0023 | 0.0023 | 1.01 |
| lep_ever | -0.0035 | 0.0013 | -2.69 |
| migrant_ever | 0.0040 | 0.0026 | 1.54 |
| attend_p0 | -0.0034 | 0.0067 | -0.51 |
| glmath_scr_m1 | 0.7443 | 0.0042 | 176.70 |
| gender_2 | -0.0010 | 0.0010 | -1.00 |
| raceth_4 | 0.0008 | 0.0020 | 0.38 |
| raceth_2 | 0.0008 | 0.0013 | 0.63 |
| raceth_3 | -0.0004 | 0.0015 | -0.27 |
| raceth_5 | 0.0064 | 0.0032 | 2.00 |
| raceth_6 | 0.0050 | 0.0036 | 1.38 |
| raceth_7 | 0.0056 | 0.0037 | 1.52 |
| raceth_Unknown | 0.0048 | 0.0030 | 1.57 |
| avg_age | 0.0311 | 0.0652 | 0.48 |
| avg_specialed_ever | 0.0004 | 0.0078 | 0.05 |
| avg_homeless_ever | -0.0263 | 0.0119 | -2.21 |
| avg_lep_ever | 0.0003 | 0.0069 | 0.04 |
| avg_migrant_ever | -0.0155 | 0.0134 | -1.15 |
| avg_attend_p0 | -0.0005 | 0.0356 | -0.01 |
| avg_glmath_scr_m1 | 0.7566 | 0.0207 | 36.51 |
| avg_gender_2 | -0.0003 | 0.0055 | -0.06 |
| avg_raceth_4 | 0.0045 | 0.0105 | 0.43 |
| avg_raceth_2 | -0.0072 | 0.0069 | -1.05 |
| avg_raceth_3 | -0.0144 | 0.0076 | -1.90 |
| avg_raceth_5 | -0.0231 | 0.0165 | -1.40 |
| avg_raceth_6 | 0.0008 | 0.0198 | 0.04 |
| avg_raceth_7 | -0.0106 | 0.0199 | -0.53 |
| avg_raceth_Unknown | 0.0126 | 0.0164 | 0.77 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000009 | 0.0030 |
| Residual | 0.007100 | 0.0843 |

**ICC:** 0.0013

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -59433.10 |
| BIC | -59160.79 |
| Log-likelihood | 29749.55 |

## Convergence

- Converged: Yes
- Singular fit: No

