# Model Report: Grade 4, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_3 + raceth_5 + raceth_6 + raceth_7 + raceth_Unknown + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_3 + avg_raceth_5 + avg_raceth_6 + avg_raceth_7 + avg_raceth_Unknown
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 28330 |
| Schools | 1000 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.1733 | 0.0637 | 2.72 |
| age | 0.0108 | 0.0118 | 0.92 |
| specialed_ever | -0.0059 | 0.0015 | -3.97 |
| homeless_ever | 0.0017 | 0.0023 | 0.76 |
| lep_ever | -0.0057 | 0.0013 | -4.36 |
| migrant_ever | 0.0017 | 0.0026 | 0.65 |
| attend_p0 | -0.0102 | 0.0067 | -1.52 |
| readng_scr_m1 | 0.7347 | 0.0042 | 176.07 |
| gender_2 | 0.0021 | 0.0010 | 2.06 |
| raceth_4 | -0.0017 | 0.0020 | -0.85 |
| raceth_2 | -0.0002 | 0.0013 | -0.14 |
| raceth_3 | 0.0008 | 0.0015 | 0.54 |
| raceth_5 | 0.0033 | 0.0032 | 1.03 |
| raceth_6 | -0.0070 | 0.0036 | -1.93 |
| raceth_7 | 0.0001 | 0.0037 | 0.03 |
| raceth_Unknown | 0.0027 | 0.0030 | 0.88 |
| avg_age | -0.0294 | 0.0657 | -0.45 |
| avg_specialed_ever | -0.0000 | 0.0079 | -0.00 |
| avg_homeless_ever | -0.0320 | 0.0120 | -2.67 |
| avg_lep_ever | -0.0121 | 0.0070 | -1.73 |
| avg_migrant_ever | -0.0087 | 0.0135 | -0.65 |
| avg_attend_p0 | 0.0159 | 0.0358 | 0.44 |
| avg_readng_scr_m1 | 0.7563 | 0.0202 | 37.46 |
| avg_gender_2 | -0.0080 | 0.0055 | -1.46 |
| avg_raceth_4 | 0.0128 | 0.0106 | 1.21 |
| avg_raceth_2 | 0.0059 | 0.0069 | 0.85 |
| avg_raceth_3 | -0.0006 | 0.0077 | -0.08 |
| avg_raceth_5 | 0.0213 | 0.0166 | 1.28 |
| avg_raceth_6 | -0.0060 | 0.0199 | -0.30 |
| avg_raceth_7 | 0.0287 | 0.0200 | 1.43 |
| avg_raceth_Unknown | 0.0021 | 0.0165 | 0.13 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000014 | 0.0037 |
| Residual | 0.007074 | 0.0841 |

**ICC:** 0.0019

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -59518.06 |
| BIC | -59245.75 |
| Log-likelihood | 29792.03 |

## Convergence

- Converged: Yes
- Singular fit: No

