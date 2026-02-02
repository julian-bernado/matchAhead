# Model Report: Grade 3, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + gender_2 + raceth_3 + raceth_6 + raceth_4 + raceth_2 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_3 + avg_raceth_6 + avg_raceth_4 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 17545 |
| Schools | 229 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.0321 | 0.1894 | -0.17 |
| age | -0.0076 | 0.0152 | -0.50 |
| lep_ever | -0.0198 | 0.0015 | -13.29 |
| migrant_ever | -0.0177 | 0.0095 | -1.87 |
| homeless_ever | -0.0074 | 0.0026 | -2.83 |
| specialed_ever | -0.0565 | 0.0016 | -35.45 |
| attend_p0 | 0.2031 | 0.0154 | 13.22 |
| gender_2 | -0.0059 | 0.0010 | -5.68 |
| raceth_3 | -0.0359 | 0.0070 | -5.15 |
| raceth_6 | 0.0005 | 0.0069 | 0.07 |
| raceth_4 | -0.0189 | 0.0068 | -2.76 |
| raceth_2 | 0.0109 | 0.0073 | 1.49 |
| raceth_Unknown | -0.0047 | 0.0076 | -0.62 |
| raceth_5 | -0.0310 | 0.0137 | -2.26 |
| avg_age | -0.3573 | 0.1793 | -1.99 |
| avg_lep_ever | -0.0191 | 0.0078 | -2.44 |
| avg_migrant_ever | -0.0639 | 0.0517 | -1.24 |
| avg_homeless_ever | -0.0124 | 0.0117 | -1.06 |
| avg_specialed_ever | -0.0577 | 0.0253 | -2.28 |
| avg_attend_p0 | 1.1224 | 0.1395 | 8.05 |
| avg_gender_2 | -0.0056 | 0.0200 | -0.28 |
| avg_raceth_3 | -0.0716 | 0.0649 | -1.10 |
| avg_raceth_6 | -0.0076 | 0.0647 | -0.12 |
| avg_raceth_4 | -0.0436 | 0.0635 | -0.69 |
| avg_raceth_2 | 0.0263 | 0.0658 | 0.40 |
| avg_raceth_Unknown | -0.0613 | 0.0889 | -0.69 |
| avg_raceth_5 | 0.2101 | 0.1751 | 1.20 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000269 | 0.0164 |
| Residual | 0.004562 | 0.0675 |

**ICC:** 0.0557

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -44176.14 |
| BIC | -43950.73 |
| Log-likelihood | 22117.07 |

## Convergence

- Converged: Yes
- Singular fit: No

