# Model Report: Grade 5, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_6 + raceth_3 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_6 + avg_raceth_3 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 303088 |
| Schools | 4305 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.3389 | 0.0300 | 11.29 |
| age | -0.0619 | 0.0074 | -8.34 |
| lep_ever | -0.0056 | 0.0002 | -23.86 |
| migrant_ever | -0.0006 | 0.0013 | -0.43 |
| homeless_ever | -0.0026 | 0.0004 | -5.91 |
| specialed_ever | -0.0195 | 0.0003 | -62.78 |
| attend_p0 | 0.0732 | 0.0023 | 31.13 |
| readng_scr_m1 | 0.5454 | 0.0014 | 394.89 |
| gender_2 | -0.0037 | 0.0002 | -23.83 |
| raceth_4 | -0.0012 | 0.0013 | -0.91 |
| raceth_2 | 0.0091 | 0.0013 | 6.85 |
| raceth_6 | 0.0042 | 0.0013 | 3.26 |
| raceth_3 | -0.0038 | 0.0013 | -2.92 |
| raceth_Unknown | 0.0024 | 0.0014 | 1.78 |
| raceth_5 | 0.0005 | 0.0024 | 0.21 |
| avg_age | -0.5663 | 0.0645 | -8.78 |
| avg_lep_ever | 0.0036 | 0.0010 | 3.58 |
| avg_migrant_ever | -0.0248 | 0.0085 | -2.90 |
| avg_homeless_ever | -0.0042 | 0.0016 | -2.67 |
| avg_specialed_ever | -0.0132 | 0.0026 | -5.03 |
| avg_attend_p0 | 0.1255 | 0.0179 | 7.02 |
| avg_readng_scr_m1 | 0.6174 | 0.0083 | 74.04 |
| avg_gender_2 | -0.0018 | 0.0023 | -0.80 |
| avg_raceth_4 | -0.0078 | 0.0149 | -0.53 |
| avg_raceth_2 | 0.0148 | 0.0151 | 0.98 |
| avg_raceth_6 | -0.0018 | 0.0150 | -0.12 |
| avg_raceth_3 | -0.0026 | 0.0150 | -0.18 |
| avg_raceth_Unknown | -0.0094 | 0.0162 | -0.58 |
| avg_raceth_5 | -0.0107 | 0.0272 | -0.39 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000050 | 0.0070 |
| Residual | 0.001794 | 0.0424 |

**ICC:** 0.0269

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -1051808.11 |
| BIC | -1051478.84 |
| Log-likelihood | 525935.06 |

## Convergence

- Converged: Yes
- Singular fit: No

