# Model Report: Grade 5, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_2 + raceth_3 + raceth_7 + raceth_4 + raceth_5 + raceth_Unknown + raceth_6 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_2 + avg_raceth_3 + avg_raceth_7 + avg_raceth_4 + avg_raceth_5 + avg_raceth_Unknown + avg_raceth_6
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 28002 |
| Schools | 1000 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.2354 | 0.0662 | 3.55 |
| age | -0.0038 | 0.0125 | -0.30 |
| specialed_ever | -0.0078 | 0.0015 | -5.19 |
| homeless_ever | 0.0037 | 0.0023 | 1.59 |
| lep_ever | -0.0038 | 0.0013 | -2.85 |
| migrant_ever | 0.0005 | 0.0026 | 0.18 |
| attend_p0 | -0.0004 | 0.0070 | -0.06 |
| readng_scr_m1 | 0.7418 | 0.0042 | 175.42 |
| gender_2 | 0.0014 | 0.0010 | 1.37 |
| raceth_2 | 0.0010 | 0.0013 | 0.80 |
| raceth_3 | 0.0013 | 0.0015 | 0.85 |
| raceth_7 | -0.0013 | 0.0038 | -0.35 |
| raceth_4 | 0.0018 | 0.0021 | 0.86 |
| raceth_5 | -0.0030 | 0.0032 | -0.93 |
| raceth_Unknown | 0.0076 | 0.0032 | 2.40 |
| raceth_6 | 0.0012 | 0.0037 | 0.31 |
| avg_age | -0.0562 | 0.0669 | -0.84 |
| avg_specialed_ever | -0.0022 | 0.0081 | -0.28 |
| avg_homeless_ever | -0.0176 | 0.0118 | -1.49 |
| avg_lep_ever | -0.0095 | 0.0067 | -1.42 |
| avg_migrant_ever | 0.0158 | 0.0135 | 1.17 |
| avg_attend_p0 | -0.0214 | 0.0368 | -0.58 |
| avg_readng_scr_m1 | 0.7471 | 0.0212 | 35.25 |
| avg_gender_2 | -0.0039 | 0.0057 | -0.68 |
| avg_raceth_2 | 0.0056 | 0.0072 | 0.78 |
| avg_raceth_3 | 0.0093 | 0.0080 | 1.16 |
| avg_raceth_7 | -0.0309 | 0.0205 | -1.50 |
| avg_raceth_4 | 0.0055 | 0.0116 | 0.48 |
| avg_raceth_5 | -0.0006 | 0.0175 | -0.03 |
| avg_raceth_Unknown | -0.0252 | 0.0166 | -1.51 |
| avg_raceth_6 | -0.0071 | 0.0206 | -0.35 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000020 | 0.0045 |
| Residual | 0.007260 | 0.0852 |

**ICC:** 0.0028

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -58078.87 |
| BIC | -57806.95 |
| Log-likelihood | 29072.43 |

## Convergence

- Converged: Yes
- Singular fit: No

