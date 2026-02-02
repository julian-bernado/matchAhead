# Model Report: Grade 4, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_3 + raceth_4 + raceth_6 + raceth_2 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_3 + avg_raceth_4 + avg_raceth_6 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 19424 |
| Schools | 228 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.0851 | 0.2070 | 0.41 |
| age | -0.0480 | 0.0106 | -4.53 |
| lep_ever | -0.0025 | 0.0010 | -2.58 |
| migrant_ever | -0.0060 | 0.0051 | -1.18 |
| homeless_ever | -0.0026 | 0.0017 | -1.50 |
| specialed_ever | -0.0139 | 0.0011 | -12.27 |
| attend_p0 | 0.1388 | 0.0103 | 13.48 |
| glmath_scr_m1 | 0.7474 | 0.0055 | 134.93 |
| gender_2 | 0.0047 | 0.0007 | 6.85 |
| raceth_3 | -0.0126 | 0.0056 | -2.23 |
| raceth_4 | -0.0041 | 0.0055 | -0.74 |
| raceth_6 | 0.0013 | 0.0056 | 0.24 |
| raceth_2 | 0.0124 | 0.0059 | 2.11 |
| raceth_Unknown | -0.0012 | 0.0059 | -0.20 |
| raceth_5 | 0.0014 | 0.0117 | 0.12 |
| avg_age | -0.0438 | 0.1462 | -0.30 |
| avg_lep_ever | 0.0061 | 0.0070 | 0.87 |
| avg_migrant_ever | -0.0403 | 0.0609 | -0.66 |
| avg_homeless_ever | -0.0036 | 0.0083 | -0.44 |
| avg_specialed_ever | -0.0082 | 0.0196 | -0.42 |
| avg_attend_p0 | 0.2740 | 0.1471 | 1.86 |
| avg_glmath_scr_m1 | 0.8392 | 0.0533 | 15.73 |
| avg_gender_2 | 0.0145 | 0.0190 | 0.76 |
| avg_raceth_3 | -0.1920 | 0.1018 | -1.89 |
| avg_raceth_4 | -0.1830 | 0.1009 | -1.81 |
| avg_raceth_6 | -0.1842 | 0.1014 | -1.82 |
| avg_raceth_2 | -0.1560 | 0.1015 | -1.54 |
| avg_raceth_Unknown | -0.0844 | 0.1099 | -0.77 |
| avg_raceth_5 | -0.3518 | 0.2760 | -1.27 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000197 | 0.0140 |
| Residual | 0.002213 | 0.0470 |

**ICC:** 0.0817

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -62901.28 |
| BIC | -62657.18 |
| Log-likelihood | 31481.64 |

## Convergence

- Converged: Yes
- Singular fit: No

