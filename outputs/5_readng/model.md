# Model Report: Grade 5, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_Unknown + raceth_6 + raceth_3 + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_6 + avg_raceth_3 + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 14516 |
| Schools | 216 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.1363 | 0.1484 | 0.92 |
| age | -0.0507 | 0.0121 | -4.18 |
| lep_ever | -0.0064 | 0.0010 | -6.24 |
| migrant_ever | -0.0025 | 0.0059 | -0.42 |
| homeless_ever | -0.0036 | 0.0021 | -1.73 |
| specialed_ever | -0.0210 | 0.0014 | -15.13 |
| attend_p0 | 0.0490 | 0.0111 | 4.42 |
| readng_scr_m1 | 0.5378 | 0.0061 | 87.70 |
| gender_2 | -0.0043 | 0.0007 | -6.22 |
| raceth_4 | -0.0082 | 0.0055 | -1.51 |
| raceth_2 | -0.0004 | 0.0057 | -0.07 |
| raceth_Unknown | -0.0065 | 0.0059 | -1.10 |
| raceth_6 | -0.0035 | 0.0055 | -0.63 |
| raceth_3 | -0.0120 | 0.0056 | -2.16 |
| raceth_5 | -0.0065 | 0.0087 | -0.74 |
| avg_age | -0.1832 | 0.1115 | -1.64 |
| avg_lep_ever | 0.0106 | 0.0047 | 2.26 |
| avg_migrant_ever | 0.0114 | 0.0416 | 0.27 |
| avg_homeless_ever | -0.0108 | 0.0104 | -1.03 |
| avg_specialed_ever | -0.0242 | 0.0122 | -1.98 |
| avg_attend_p0 | 0.0516 | 0.0911 | 0.57 |
| avg_readng_scr_m1 | 0.6753 | 0.0389 | 17.34 |
| avg_gender_2 | -0.0011 | 0.0106 | -0.10 |
| avg_raceth_4 | 0.2023 | 0.0930 | 2.18 |
| avg_raceth_2 | 0.2246 | 0.0936 | 2.40 |
| avg_raceth_Unknown | 0.2205 | 0.0964 | 2.29 |
| avg_raceth_6 | 0.2087 | 0.0937 | 2.23 |
| avg_raceth_3 | 0.2118 | 0.0938 | 2.26 |
| avg_raceth_5 | 0.1855 | 0.1382 | 1.34 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000055 | 0.0074 |
| Residual | 0.001658 | 0.0407 |

**ICC:** 0.0319

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -51238.71 |
| BIC | -51003.64 |
| Log-likelihood | 25650.36 |

## Convergence

- Converged: Yes
- Singular fit: No

