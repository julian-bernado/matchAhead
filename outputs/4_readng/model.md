# Model Report: Grade 4, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_3 + raceth_6 + raceth_4 + raceth_2 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_3 + avg_raceth_6 + avg_raceth_4 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 39516 |
| Schools | 457 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.1579 | 0.1192 | -1.32 |
| age | -0.0322 | 0.0070 | -4.60 |
| lep_ever | -0.0062 | 0.0007 | -9.03 |
| migrant_ever | -0.0083 | 0.0037 | -2.21 |
| homeless_ever | -0.0054 | 0.0012 | -4.46 |
| specialed_ever | -0.0183 | 0.0008 | -23.72 |
| attend_p0 | 0.0879 | 0.0068 | 12.93 |
| readng_scr_m1 | 0.6656 | 0.0038 | 173.70 |
| gender_2 | -0.0028 | 0.0005 | -5.95 |
| raceth_3 | -0.0065 | 0.0040 | -1.65 |
| raceth_6 | 0.0035 | 0.0039 | 0.89 |
| raceth_4 | 0.0001 | 0.0039 | 0.03 |
| raceth_2 | 0.0142 | 0.0041 | 3.49 |
| raceth_Unknown | -0.0001 | 0.0042 | -0.02 |
| raceth_5 | 0.0116 | 0.0086 | 1.35 |
| avg_age | -0.0279 | 0.0810 | -0.34 |
| avg_lep_ever | -0.0055 | 0.0038 | -1.45 |
| avg_migrant_ever | 0.0035 | 0.0277 | 0.13 |
| avg_homeless_ever | -0.0146 | 0.0068 | -2.15 |
| avg_specialed_ever | -0.0102 | 0.0099 | -1.02 |
| avg_attend_p0 | 0.3268 | 0.0714 | 4.57 |
| avg_readng_scr_m1 | 0.7564 | 0.0285 | 26.53 |
| avg_gender_2 | -0.0109 | 0.0090 | -1.21 |
| avg_raceth_3 | 0.0423 | 0.0618 | 0.68 |
| avg_raceth_6 | 0.0592 | 0.0620 | 0.95 |
| avg_raceth_4 | 0.0592 | 0.0615 | 0.96 |
| avg_raceth_2 | 0.0877 | 0.0621 | 1.41 |
| avg_raceth_Unknown | 0.0579 | 0.0660 | 0.88 |
| avg_raceth_5 | 0.0680 | 0.1429 | 0.48 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000100 | 0.0100 |
| Residual | 0.002136 | 0.0462 |

**ICC:** 0.0447

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -129847.86 |
| BIC | -129581.74 |
| Log-likelihood | 64954.93 |

## Convergence

- Converged: Yes
- Singular fit: No

