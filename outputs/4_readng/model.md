# Model Report: Grade 4, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + readng_scr_m1 + gender_2 + raceth_6 + raceth_4 + raceth_3 + raceth_2 + raceth_Unknown + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_readng_scr_m1 + avg_gender_2 + avg_raceth_6 + avg_raceth_4 + avg_raceth_3 + avg_raceth_2 + avg_raceth_Unknown + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 19564 |
| Schools | 228 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | -0.2468 | 0.1786 | -1.38 |
| age | -0.0317 | 0.0097 | -3.26 |
| lep_ever | -0.0055 | 0.0010 | -5.68 |
| migrant_ever | -0.0033 | 0.0052 | -0.63 |
| homeless_ever | -0.0054 | 0.0017 | -3.21 |
| specialed_ever | -0.0180 | 0.0011 | -17.09 |
| attend_p0 | 0.0972 | 0.0096 | 10.17 |
| readng_scr_m1 | 0.6731 | 0.0054 | 124.09 |
| gender_2 | -0.0019 | 0.0007 | -2.82 |
| raceth_6 | -0.0006 | 0.0058 | -0.11 |
| raceth_4 | -0.0042 | 0.0058 | -0.73 |
| raceth_3 | -0.0107 | 0.0058 | -1.82 |
| raceth_2 | 0.0105 | 0.0060 | 1.75 |
| raceth_Unknown | -0.0045 | 0.0061 | -0.73 |
| raceth_5 | 0.0055 | 0.0111 | 0.49 |
| avg_age | -0.0193 | 0.1124 | -0.17 |
| avg_lep_ever | -0.0036 | 0.0057 | -0.64 |
| avg_migrant_ever | 0.0126 | 0.0395 | 0.32 |
| avg_homeless_ever | -0.0049 | 0.0103 | -0.48 |
| avg_specialed_ever | 0.0041 | 0.0139 | 0.29 |
| avg_attend_p0 | 0.3093 | 0.1020 | 3.03 |
| avg_readng_scr_m1 | 0.7757 | 0.0476 | 16.29 |
| avg_gender_2 | -0.0407 | 0.0140 | -2.91 |
| avg_raceth_6 | 0.1595 | 0.1148 | 1.39 |
| avg_raceth_4 | 0.1574 | 0.1136 | 1.39 |
| avg_raceth_3 | 0.1448 | 0.1137 | 1.27 |
| avg_raceth_2 | 0.1647 | 0.1152 | 1.43 |
| avg_raceth_Unknown | 0.1526 | 0.1202 | 1.27 |
| avg_raceth_5 | 0.0764 | 0.2198 | 0.35 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000105 | 0.0102 |
| Residual | 0.002070 | 0.0455 |

**ICC:** 0.0483

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -64761.93 |
| BIC | -64517.61 |
| Log-likelihood | 32411.97 |

## Convergence

- Converged: Yes
- Singular fit: No

