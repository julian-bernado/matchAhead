# Model Report: Grade 3, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + gender_2 + raceth_6 + raceth_3 + raceth_4 + raceth_2 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_6 + avg_raceth_3 + avg_raceth_4 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 34977 |
| Schools | 458 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.1435 | 0.1423 | -1.01 |
| age | -0.0134 | 0.0107 | -1.25 |
| lep_ever | -0.0196 | 0.0010 | -18.82 |
| migrant_ever | -0.0150 | 0.0062 | -2.42 |
| homeless_ever | -0.0068 | 0.0019 | -3.55 |
| specialed_ever | -0.0556 | 0.0011 | -49.32 |
| attend_p0 | 0.1965 | 0.0107 | 18.35 |
| gender_2 | -0.0068 | 0.0007 | -9.26 |
| raceth_6 | 0.0113 | 0.0048 | 2.36 |
| raceth_3 | -0.0233 | 0.0049 | -4.81 |
| raceth_4 | -0.0064 | 0.0047 | -1.34 |
| raceth_2 | 0.0312 | 0.0051 | 6.17 |
| raceth_Unknown | 0.0064 | 0.0053 | 1.22 |
| raceth_5 | -0.0107 | 0.0102 | -1.04 |
| avg_age | -0.1478 | 0.1299 | -1.14 |
| avg_lep_ever | -0.0245 | 0.0059 | -4.17 |
| avg_migrant_ever | -0.1128 | 0.0475 | -2.37 |
| avg_homeless_ever | -0.0282 | 0.0098 | -2.89 |
| avg_specialed_ever | -0.0697 | 0.0175 | -3.99 |
| avg_attend_p0 | 1.0529 | 0.1030 | 10.22 |
| avg_gender_2 | 0.0190 | 0.0153 | 1.24 |
| avg_raceth_6 | -0.0051 | 0.0444 | -0.11 |
| avg_raceth_3 | -0.0593 | 0.0445 | -1.33 |
| avg_raceth_4 | -0.0281 | 0.0434 | -0.65 |
| avg_raceth_2 | 0.0538 | 0.0462 | 1.16 |
| avg_raceth_Unknown | -0.0413 | 0.0598 | -0.69 |
| avg_raceth_5 | 0.1350 | 0.1447 | 0.93 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000307 | 0.0175 |
| Residual | 0.004524 | 0.0673 |

**ICC:** 0.0635

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -88524.42 |
| BIC | -88279.01 |
| Log-likelihood | 44291.21 |

## Convergence

- Converged: Yes
- Singular fit: No

