# Model Report: Grade 4, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_2 + raceth_3 + raceth_4 + raceth_6 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_2 + avg_raceth_3 + avg_raceth_4 + avg_raceth_6 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 397637 |
| Schools | 4561 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.0098 | 0.0436 | 0.22 |
| age | -0.0711 | 0.0032 | -22.28 |
| lep_ever | -0.0046 | 0.0002 | -22.56 |
| migrant_ever | 0.0002 | 0.0011 | 0.15 |
| homeless_ever | -0.0029 | 0.0004 | -7.82 |
| specialed_ever | -0.0115 | 0.0002 | -48.03 |
| attend_p0 | 0.1410 | 0.0021 | 67.08 |
| glmath_scr_m1 | 0.7241 | 0.0012 | 599.00 |
| gender_2 | 0.0043 | 0.0001 | 29.81 |
| raceth_2 | 0.0195 | 0.0012 | 16.51 |
| raceth_3 | -0.0081 | 0.0011 | -7.11 |
| raceth_4 | -0.0005 | 0.0011 | -0.45 |
| raceth_6 | 0.0046 | 0.0011 | 4.06 |
| raceth_Unknown | 0.0017 | 0.0012 | 1.41 |
| raceth_5 | -0.0010 | 0.0022 | -0.47 |
| avg_age | -0.1944 | 0.0487 | -3.99 |
| avg_lep_ever | 0.0000 | 0.0015 | 0.02 |
| avg_migrant_ever | -0.0462 | 0.0121 | -3.80 |
| avg_homeless_ever | 0.0019 | 0.0025 | 0.76 |
| avg_specialed_ever | -0.0006 | 0.0039 | -0.15 |
| avg_attend_p0 | 0.2539 | 0.0284 | 8.94 |
| avg_glmath_scr_m1 | 0.7890 | 0.0115 | 68.59 |
| avg_gender_2 | 0.0052 | 0.0036 | 1.44 |
| avg_raceth_2 | 0.0340 | 0.0207 | 1.64 |
| avg_raceth_3 | -0.0042 | 0.0206 | -0.21 |
| avg_raceth_4 | 0.0026 | 0.0204 | 0.13 |
| avg_raceth_6 | 0.0065 | 0.0206 | 0.32 |
| avg_raceth_Unknown | -0.0016 | 0.0228 | -0.07 |
| avg_raceth_5 | -0.0401 | 0.0439 | -0.91 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000205 | 0.0143 |
| Residual | 0.002019 | 0.0449 |

**ICC:** 0.0924

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -1328847.61 |
| BIC | -1328509.91 |
| Log-likelihood | 664454.80 |

## Convergence

- Converged: Yes
- Singular fit: No

