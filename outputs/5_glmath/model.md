# Model Report: Grade 5, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_2 + raceth_3 + raceth_6 + raceth_4 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_2 + avg_raceth_3 + avg_raceth_6 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 15512 |
| Schools | 214 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.1361 | 0.2712 | 0.50 |
| age | -0.0230 | 0.0129 | -1.78 |
| lep_ever | -0.0021 | 0.0011 | -1.90 |
| migrant_ever | -0.0033 | 0.0066 | -0.49 |
| homeless_ever | -0.0010 | 0.0021 | -0.46 |
| specialed_ever | -0.0158 | 0.0014 | -11.18 |
| attend_p0 | 0.1588 | 0.0112 | 14.12 |
| glmath_scr_m1 | 0.6809 | 0.0066 | 103.75 |
| gender_2 | 0.0015 | 0.0007 | 2.09 |
| raceth_2 | 0.0215 | 0.0067 | 3.19 |
| raceth_3 | 0.0026 | 0.0067 | 0.39 |
| raceth_6 | 0.0105 | 0.0066 | 1.59 |
| raceth_4 | 0.0074 | 0.0066 | 1.12 |
| raceth_Unknown | 0.0095 | 0.0069 | 1.37 |
| raceth_5 | 0.0105 | 0.0120 | 0.87 |
| avg_age | -0.0969 | 0.1875 | -0.52 |
| avg_lep_ever | 0.0031 | 0.0081 | 0.38 |
| avg_migrant_ever | 0.0383 | 0.0553 | 0.69 |
| avg_homeless_ever | 0.0156 | 0.0158 | 0.99 |
| avg_specialed_ever | -0.0087 | 0.0184 | -0.47 |
| avg_attend_p0 | 0.4058 | 0.1271 | 3.19 |
| avg_glmath_scr_m1 | 0.7585 | 0.0587 | 12.92 |
| avg_gender_2 | -0.0091 | 0.0189 | -0.48 |
| avg_raceth_2 | -0.2268 | 0.1879 | -1.21 |
| avg_raceth_3 | -0.2489 | 0.1867 | -1.33 |
| avg_raceth_6 | -0.2438 | 0.1866 | -1.31 |
| avg_raceth_4 | -0.2371 | 0.1858 | -1.28 |
| avg_raceth_Unknown | -0.1546 | 0.1920 | -0.81 |
| avg_raceth_5 | -0.5533 | 0.3573 | -1.55 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000249 | 0.0158 |
| Residual | 0.001986 | 0.0446 |

**ICC:** 0.1114

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -51784.31 |
| BIC | -51547.18 |
| Log-likelihood | 25923.15 |

## Convergence

- Converged: Yes
- Singular fit: No

