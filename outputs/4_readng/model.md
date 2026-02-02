# Model Report: Grade 4, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_Unknown + raceth_3 + raceth_5 + raceth_6 + raceth_7 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_3 + avg_raceth_5 + avg_raceth_6 + avg_raceth_7
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 2861 |
| Schools | 100 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.3265 | 0.2133 | 1.53 |
| age | 0.0014 | 0.0355 | 0.04 |
| specialed_ever | -0.0090 | 0.0047 | -1.93 |
| homeless_ever | 0.0057 | 0.0072 | 0.79 |
| lep_ever | -0.0043 | 0.0041 | -1.04 |
| migrant_ever | -0.0005 | 0.0083 | -0.05 |
| attend_p0 | -0.0068 | 0.0215 | -0.32 |
| readng_scr_m1 | 0.7332 | 0.0131 | 55.95 |
| gender_2 | 0.0032 | 0.0033 | 0.99 |
| raceth_4 | -0.0014 | 0.0068 | -0.21 |
| raceth_2 | -0.0077 | 0.0041 | -1.88 |
| raceth_Unknown | -0.0088 | 0.0098 | -0.89 |
| raceth_3 | -0.0035 | 0.0046 | -0.77 |
| raceth_5 | 0.0060 | 0.0099 | 0.61 |
| raceth_6 | -0.0044 | 0.0117 | -0.38 |
| raceth_7 | 0.0059 | 0.0114 | 0.52 |
| avg_age | -0.2372 | 0.1985 | -1.20 |
| avg_specialed_ever | 0.0139 | 0.0233 | 0.59 |
| avg_homeless_ever | -0.0601 | 0.0413 | -1.46 |
| avg_lep_ever | -0.0077 | 0.0217 | -0.35 |
| avg_migrant_ever | -0.0056 | 0.0403 | -0.14 |
| avg_attend_p0 | -0.0017 | 0.1228 | -0.01 |
| avg_readng_scr_m1 | 0.8118 | 0.0675 | 12.02 |
| avg_gender_2 | 0.0156 | 0.0197 | 0.79 |
| avg_raceth_4 | -0.0238 | 0.0380 | -0.63 |
| avg_raceth_2 | -0.0071 | 0.0243 | -0.29 |
| avg_raceth_Unknown | -0.0903 | 0.0616 | -1.47 |
| avg_raceth_3 | 0.0093 | 0.0302 | 0.31 |
| avg_raceth_5 | 0.1011 | 0.0527 | 1.92 |
| avg_raceth_6 | -0.0370 | 0.0599 | -0.62 |
| avg_raceth_7 | 0.0464 | 0.0668 | 0.69 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000000 | 0.0000 |
| Residual | 0.007332 | 0.0856 |

**ICC:** 0.0000

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -5715.41 |
| BIC | -5518.76 |
| Log-likelihood | 2890.70 |

## Convergence

- Converged: No
- Singular fit: Yes

