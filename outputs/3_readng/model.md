# Model Report: Grade 3, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + gender_2 + raceth_3 + raceth_7 + raceth_2 + raceth_5 + raceth_4 + raceth_Unknown + raceth_6 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_3 + avg_raceth_7 + avg_raceth_2 + avg_raceth_5 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_6
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 27732 |
| Schools | 1000 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.5428 | 0.0881 | 6.16 |
| age | 0.0224 | 0.0151 | 1.48 |
| specialed_ever | -0.0206 | 0.0022 | -9.42 |
| homeless_ever | -0.0012 | 0.0034 | -0.35 |
| lep_ever | -0.0101 | 0.0019 | -5.20 |
| migrant_ever | 0.0022 | 0.0039 | 0.56 |
| attend_p0 | -0.0059 | 0.0105 | -0.56 |
| gender_2 | 0.0018 | 0.0015 | 1.21 |
| raceth_3 | 0.0021 | 0.0022 | 0.96 |
| raceth_7 | 0.0103 | 0.0058 | 1.78 |
| raceth_2 | 0.0022 | 0.0019 | 1.14 |
| raceth_5 | -0.0034 | 0.0048 | -0.72 |
| raceth_4 | 0.0037 | 0.0030 | 1.25 |
| raceth_Unknown | 0.0000 | 0.0046 | 0.01 |
| raceth_6 | 0.0019 | 0.0057 | 0.34 |
| avg_age | 0.0715 | 0.0885 | 0.81 |
| avg_specialed_ever | -0.0236 | 0.0125 | -1.89 |
| avg_homeless_ever | -0.0504 | 0.0179 | -2.82 |
| avg_lep_ever | -0.0348 | 0.0104 | -3.33 |
| avg_migrant_ever | -0.0350 | 0.0217 | -1.61 |
| avg_attend_p0 | 0.0221 | 0.0591 | 0.37 |
| avg_gender_2 | 0.0010 | 0.0086 | 0.12 |
| avg_raceth_3 | 0.0200 | 0.0119 | 1.68 |
| avg_raceth_7 | 0.0060 | 0.0321 | 0.19 |
| avg_raceth_2 | 0.0269 | 0.0108 | 2.48 |
| avg_raceth_5 | 0.0330 | 0.0265 | 1.25 |
| avg_raceth_4 | 0.0480 | 0.0165 | 2.91 |
| avg_raceth_Unknown | 0.0393 | 0.0260 | 1.51 |
| avg_raceth_6 | 0.0134 | 0.0313 | 0.43 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000096 | 0.0098 |
| Residual | 0.015468 | 0.1244 |

**ICC:** 0.0061

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -36499.12 |
| BIC | -36243.98 |
| Log-likelihood | 18280.56 |

## Convergence

- Converged: Yes
- Singular fit: No

