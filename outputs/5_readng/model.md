# Model Report: Grade 5, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_2 + raceth_7 + raceth_3 + raceth_5 + raceth_4 + raceth_Unknown + raceth_6 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_2 + avg_raceth_7 + avg_raceth_3 + avg_raceth_5 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_6
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 2722 |
| Schools | 100 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.4726 | 0.2405 | 1.97 |
| age | 0.0225 | 0.0382 | 0.59 |
| specialed_ever | -0.0104 | 0.0047 | -2.19 |
| homeless_ever | 0.0141 | 0.0076 | 1.85 |
| lep_ever | -0.0072 | 0.0042 | -1.73 |
| migrant_ever | 0.0007 | 0.0086 | 0.08 |
| attend_p0 | 0.0128 | 0.0232 | 0.55 |
| readng_scr_m1 | 0.7405 | 0.0135 | 54.80 |
| gender_2 | 0.0013 | 0.0033 | 0.39 |
| raceth_2 | 0.0044 | 0.0042 | 1.05 |
| raceth_7 | -0.0052 | 0.0129 | -0.40 |
| raceth_3 | 0.0044 | 0.0047 | 0.94 |
| raceth_5 | 0.0121 | 0.0103 | 1.18 |
| raceth_4 | 0.0073 | 0.0064 | 1.14 |
| raceth_Unknown | -0.0033 | 0.0099 | -0.34 |
| raceth_6 | 0.0081 | 0.0119 | 0.68 |
| avg_age | -0.0278 | 0.2278 | -0.12 |
| avg_specialed_ever | -0.0296 | 0.0262 | -1.13 |
| avg_homeless_ever | 0.0067 | 0.0393 | 0.17 |
| avg_lep_ever | -0.0378 | 0.0231 | -1.63 |
| avg_migrant_ever | -0.0193 | 0.0420 | -0.46 |
| avg_attend_p0 | -0.2677 | 0.1323 | -2.02 |
| avg_readng_scr_m1 | 0.6684 | 0.0648 | 10.31 |
| avg_gender_2 | 0.0185 | 0.0186 | 0.99 |
| avg_raceth_2 | 0.0484 | 0.0229 | 2.11 |
| avg_raceth_7 | -0.0504 | 0.0723 | -0.70 |
| avg_raceth_3 | 0.0485 | 0.0297 | 1.63 |
| avg_raceth_5 | 0.0107 | 0.0593 | 0.18 |
| avg_raceth_4 | 0.0356 | 0.0336 | 1.06 |
| avg_raceth_Unknown | -0.0243 | 0.0566 | -0.43 |
| avg_raceth_6 | 0.0216 | 0.0656 | 0.33 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000013 | 0.0036 |
| Residual | 0.007191 | 0.0848 |

**ICC:** 0.0018

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -5476.50 |
| BIC | -5281.50 |
| Log-likelihood | 2771.25 |

## Convergence

- Converged: Yes
- Singular fit: No

