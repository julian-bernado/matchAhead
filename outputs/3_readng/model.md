# Model Report: Grade 3, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + gender_2 + raceth_6 + raceth_4 + raceth_2 + raceth_3 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_6 + avg_raceth_4 + avg_raceth_2 + avg_raceth_3 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 379705 |
| Schools | 4583 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.1274 | 0.0476 | -2.67 |
| age | -0.0133 | 0.0039 | -3.38 |
| lep_ever | -0.0194 | 0.0003 | -62.72 |
| migrant_ever | -0.0127 | 0.0018 | -7.10 |
| homeless_ever | -0.0088 | 0.0006 | -15.71 |
| specialed_ever | -0.0555 | 0.0003 | -160.92 |
| attend_p0 | 0.2057 | 0.0032 | 64.01 |
| gender_2 | -0.0080 | 0.0002 | -36.03 |
| raceth_6 | 0.0093 | 0.0016 | 5.72 |
| raceth_4 | -0.0070 | 0.0016 | -4.33 |
| raceth_2 | 0.0256 | 0.0017 | 15.03 |
| raceth_3 | -0.0227 | 0.0016 | -13.78 |
| raceth_Unknown | 0.0027 | 0.0017 | 1.55 |
| raceth_5 | -0.0070 | 0.0032 | -2.21 |
| avg_age | -0.0641 | 0.0493 | -1.30 |
| avg_lep_ever | -0.0198 | 0.0019 | -10.51 |
| avg_migrant_ever | -0.0165 | 0.0171 | -0.96 |
| avg_homeless_ever | -0.0195 | 0.0031 | -6.22 |
| avg_specialed_ever | -0.0517 | 0.0049 | -10.53 |
| avg_attend_p0 | 0.9451 | 0.0322 | 29.31 |
| avg_gender_2 | -0.0183 | 0.0045 | -4.07 |
| avg_raceth_6 | 0.0195 | 0.0148 | 1.32 |
| avg_raceth_4 | -0.0053 | 0.0145 | -0.36 |
| avg_raceth_2 | 0.0934 | 0.0150 | 6.21 |
| avg_raceth_3 | -0.0312 | 0.0148 | -2.11 |
| avg_raceth_Unknown | 0.0303 | 0.0187 | 1.62 |
| avg_raceth_5 | 0.0080 | 0.0497 | 0.16 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000302 | 0.0174 |
| Residual | 0.004511 | 0.0672 |

**ICC:** 0.0627

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -964954.23 |
| BIC | -964639.66 |
| Log-likelihood | 482506.11 |

## Convergence

- Converged: Yes
- Singular fit: No

