# Model Report: Grade 5, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_4 + raceth_2 + raceth_Unknown + raceth_6 + raceth_3 + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_4 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_6 + avg_raceth_3 + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 30129 |
| Schools | 430 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.1210 | 0.1019 | 1.19 |
| age | -0.0316 | 0.0085 | -3.70 |
| lep_ever | -0.0062 | 0.0007 | -8.57 |
| migrant_ever | -0.0061 | 0.0043 | -1.40 |
| homeless_ever | -0.0034 | 0.0014 | -2.47 |
| specialed_ever | -0.0205 | 0.0010 | -21.11 |
| attend_p0 | 0.0629 | 0.0076 | 8.33 |
| readng_scr_m1 | 0.5418 | 0.0043 | 126.19 |
| gender_2 | -0.0040 | 0.0005 | -8.38 |
| raceth_4 | -0.0059 | 0.0040 | -1.48 |
| raceth_2 | 0.0015 | 0.0041 | 0.37 |
| raceth_Unknown | -0.0037 | 0.0042 | -0.87 |
| raceth_6 | -0.0010 | 0.0040 | -0.26 |
| raceth_3 | -0.0095 | 0.0040 | -2.37 |
| raceth_5 | -0.0017 | 0.0070 | -0.24 |
| avg_age | -0.1921 | 0.0786 | -2.44 |
| avg_lep_ever | 0.0028 | 0.0033 | 0.84 |
| avg_migrant_ever | -0.0035 | 0.0275 | -0.13 |
| avg_homeless_ever | -0.0034 | 0.0054 | -0.63 |
| avg_specialed_ever | -0.0116 | 0.0091 | -1.27 |
| avg_attend_p0 | 0.1300 | 0.0590 | 2.20 |
| avg_readng_scr_m1 | 0.6685 | 0.0269 | 24.84 |
| avg_gender_2 | 0.0002 | 0.0076 | 0.02 |
| avg_raceth_4 | 0.1539 | 0.0613 | 2.51 |
| avg_raceth_2 | 0.1666 | 0.0618 | 2.69 |
| avg_raceth_Unknown | 0.1578 | 0.0654 | 2.41 |
| avg_raceth_6 | 0.1580 | 0.0617 | 2.56 |
| avg_raceth_3 | 0.1635 | 0.0618 | 2.65 |
| avg_raceth_5 | 0.1895 | 0.1097 | 1.73 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000053 | 0.0073 |
| Residual | 0.001701 | 0.0412 |

**ICC:** 0.0302

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -105874.31 |
| BIC | -105616.60 |
| Log-likelihood | 52968.16 |

## Convergence

- Converged: Yes
- Singular fit: No

