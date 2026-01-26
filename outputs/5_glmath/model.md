# Model Report: Grade 5, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_2 + raceth_3 + raceth_7 + raceth_4 + raceth_5 + raceth_Unknown + raceth_6 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_2 + avg_raceth_3 + avg_raceth_7 + avg_raceth_4 + avg_raceth_5 + avg_raceth_Unknown + avg_raceth_6
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 28002 |
| Schools | 1000 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.1404 | 0.0637 | 2.20 |
| age | -0.0053 | 0.0125 | -0.42 |
| specialed_ever | -0.0088 | 0.0015 | -5.81 |
| homeless_ever | 0.0015 | 0.0023 | 0.66 |
| lep_ever | -0.0052 | 0.0013 | -3.93 |
| migrant_ever | 0.0026 | 0.0026 | 1.00 |
| attend_p0 | -0.0019 | 0.0070 | -0.28 |
| glmath_scr_m1 | 0.7402 | 0.0042 | 174.74 |
| gender_2 | 0.0008 | 0.0010 | 0.77 |
| raceth_2 | -0.0010 | 0.0013 | -0.76 |
| raceth_3 | -0.0001 | 0.0015 | -0.08 |
| raceth_7 | -0.0001 | 0.0038 | -0.02 |
| raceth_4 | -0.0020 | 0.0021 | -0.99 |
| raceth_5 | -0.0028 | 0.0032 | -0.86 |
| raceth_Unknown | -0.0002 | 0.0031 | -0.07 |
| raceth_6 | -0.0003 | 0.0037 | -0.09 |
| avg_age | -0.0088 | 0.0642 | -0.14 |
| avg_specialed_ever | -0.0163 | 0.0078 | -2.10 |
| avg_homeless_ever | -0.0146 | 0.0114 | -1.29 |
| avg_lep_ever | -0.0134 | 0.0065 | -2.07 |
| avg_migrant_ever | -0.0100 | 0.0129 | -0.78 |
| avg_attend_p0 | 0.0282 | 0.0354 | 0.80 |
| avg_glmath_scr_m1 | 0.7579 | 0.0207 | 36.59 |
| avg_gender_2 | -0.0003 | 0.0055 | -0.06 |
| avg_raceth_2 | 0.0083 | 0.0070 | 1.20 |
| avg_raceth_3 | 0.0122 | 0.0077 | 1.58 |
| avg_raceth_7 | 0.0279 | 0.0197 | 1.42 |
| avg_raceth_4 | 0.0101 | 0.0111 | 0.90 |
| avg_raceth_5 | 0.0210 | 0.0168 | 1.25 |
| avg_raceth_Unknown | -0.0064 | 0.0159 | -0.40 |
| avg_raceth_6 | -0.0223 | 0.0198 | -1.13 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000000 | 0.0000 |
| Residual | 0.007225 | 0.0850 |

**ICC:** 0.0000

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -58289.04 |
| BIC | -58017.12 |
| Log-likelihood | 29177.52 |

## Convergence

- Converged: No
- Singular fit: Yes

