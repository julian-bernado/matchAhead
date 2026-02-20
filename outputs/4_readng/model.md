# Model Report: Grade 4, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_2 + raceth_3 + raceth_4 + raceth_6 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_2 + avg_raceth_3 + avg_raceth_4 + avg_raceth_6 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 397497 |
| Schools | 4561 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.1560 | 0.0333 | -4.68 |
| age | -0.0676 | 0.0033 | -20.62 |
| lep_ever | -0.0073 | 0.0002 | -34.70 |
| migrant_ever | -0.0030 | 0.0012 | -2.56 |
| homeless_ever | -0.0040 | 0.0004 | -10.45 |
| specialed_ever | -0.0177 | 0.0002 | -72.28 |
| attend_p0 | 0.0993 | 0.0022 | 46.14 |
| readng_scr_m1 | 0.6737 | 0.0012 | 551.71 |
| gender_2 | -0.0022 | 0.0001 | -14.59 |
| raceth_2 | 0.0144 | 0.0012 | 11.85 |
| raceth_3 | -0.0050 | 0.0012 | -4.27 |
| raceth_4 | 0.0025 | 0.0012 | 2.16 |
| raceth_6 | 0.0055 | 0.0012 | 4.72 |
| raceth_Unknown | 0.0031 | 0.0012 | 2.49 |
| raceth_5 | -0.0009 | 0.0022 | -0.42 |
| avg_age | 0.0257 | 0.0374 | 0.69 |
| avg_lep_ever | -0.0054 | 0.0012 | -4.60 |
| avg_migrant_ever | 0.0032 | 0.0095 | 0.33 |
| avg_homeless_ever | -0.0019 | 0.0019 | -1.02 |
| avg_specialed_ever | -0.0037 | 0.0031 | -1.20 |
| avg_attend_p0 | 0.2828 | 0.0218 | 12.96 |
| avg_readng_scr_m1 | 0.8316 | 0.0097 | 85.86 |
| avg_gender_2 | -0.0031 | 0.0028 | -1.10 |
| avg_raceth_2 | 0.0246 | 0.0157 | 1.56 |
| avg_raceth_3 | -0.0031 | 0.0156 | -0.20 |
| avg_raceth_4 | 0.0051 | 0.0155 | 0.33 |
| avg_raceth_6 | 0.0028 | 0.0156 | 0.18 |
| avg_raceth_Unknown | -0.0232 | 0.0174 | -1.33 |
| avg_raceth_5 | -0.0338 | 0.0330 | -1.02 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000101 | 0.0101 |
| Residual | 0.002133 | 0.0462 |

**ICC:** 0.0453

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -1309277.86 |
| BIC | -1308940.18 |
| Log-likelihood | 654669.93 |

## Convergence

- Converged: Yes
- Singular fit: No

