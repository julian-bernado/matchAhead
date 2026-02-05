# Model Report: Grade 3, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + gender_2 + raceth_4 + raceth_Unknown + raceth_6 + raceth_2 + raceth_3 + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_6 + avg_raceth_2 + avg_raceth_3 + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 37808 |
| Schools | 460 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.0056 | 0.1810 | -0.03 |
| age | -0.0366 | 0.0111 | -3.29 |
| lep_ever | -0.0161 | 0.0010 | -15.82 |
| migrant_ever | 0.0032 | 0.0056 | 0.57 |
| homeless_ever | -0.0128 | 0.0019 | -6.73 |
| specialed_ever | -0.0609 | 0.0011 | -54.51 |
| attend_p0 | 0.3455 | 0.0105 | 33.02 |
| gender_2 | 0.0089 | 0.0007 | 12.48 |
| raceth_4 | -0.0088 | 0.0051 | -1.73 |
| raceth_Unknown | 0.0030 | 0.0055 | 0.54 |
| raceth_6 | 0.0105 | 0.0051 | 2.06 |
| raceth_2 | 0.0403 | 0.0054 | 7.47 |
| raceth_3 | -0.0313 | 0.0052 | -6.05 |
| raceth_5 | 0.0053 | 0.0103 | 0.52 |
| avg_age | -0.2000 | 0.1488 | -1.34 |
| avg_lep_ever | -0.0134 | 0.0070 | -1.91 |
| avg_migrant_ever | 0.0068 | 0.0742 | 0.09 |
| avg_homeless_ever | -0.0366 | 0.0127 | -2.87 |
| avg_specialed_ever | -0.0485 | 0.0176 | -2.75 |
| avg_attend_p0 | 0.9208 | 0.1203 | 7.66 |
| avg_gender_2 | 0.0174 | 0.0165 | 1.06 |
| avg_raceth_4 | 0.0184 | 0.0660 | 0.28 |
| avg_raceth_Unknown | 0.1053 | 0.0827 | 1.27 |
| avg_raceth_6 | 0.0301 | 0.0667 | 0.45 |
| avg_raceth_2 | 0.1035 | 0.0671 | 1.54 |
| avg_raceth_3 | -0.0188 | 0.0668 | -0.28 |
| avg_raceth_5 | -0.1203 | 0.2062 | -0.58 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000419 | 0.0205 |
| Residual | 0.004710 | 0.0686 |

**ICC:** 0.0818

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -94114.92 |
| BIC | -93867.26 |
| Log-likelihood | 47086.46 |

## Convergence

- Converged: Yes
- Singular fit: No

