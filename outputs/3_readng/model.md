# Model Report: Grade 3, readng

## Model Formula

```
readng_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + gender_2 + raceth_2 + raceth_3 + raceth_6 + raceth_4 + raceth_Unknown + raceth_5 + raceth_7 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_2 + avg_raceth_3 + avg_raceth_6 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_5 + avg_raceth_7
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 2834 |
| Schools | 100 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 1.0183 | 0.2572 | 3.96 |
| age | -0.1068 | 0.0454 | -2.36 |
| specialed_ever | -0.0180 | 0.0068 | -2.63 |
| homeless_ever | 0.0011 | 0.0099 | 0.11 |
| lep_ever | -0.0252 | 0.0062 | -4.08 |
| migrant_ever | -0.0033 | 0.0118 | -0.28 |
| attend_p0 | 0.0110 | 0.0319 | 0.34 |
| gender_2 | 0.0077 | 0.0048 | 1.60 |
| raceth_2 | -0.0035 | 0.0061 | -0.57 |
| raceth_3 | -0.0077 | 0.0067 | -1.15 |
| raceth_6 | 0.0200 | 0.0162 | 1.24 |
| raceth_4 | -0.0064 | 0.0096 | -0.67 |
| raceth_Unknown | -0.0136 | 0.0145 | -0.94 |
| raceth_5 | -0.0205 | 0.0142 | -1.45 |
| raceth_7 | -0.0280 | 0.0188 | -1.49 |
| avg_age | -0.3475 | 0.2627 | -1.32 |
| avg_specialed_ever | -0.0219 | 0.0340 | -0.64 |
| avg_homeless_ever | -0.0426 | 0.0566 | -0.75 |
| avg_lep_ever | -0.0478 | 0.0331 | -1.45 |
| avg_migrant_ever | 0.0951 | 0.0697 | 1.37 |
| avg_attend_p0 | -0.0791 | 0.1787 | -0.44 |
| avg_gender_2 | -0.0018 | 0.0254 | -0.07 |
| avg_raceth_2 | -0.0301 | 0.0349 | -0.86 |
| avg_raceth_3 | -0.0182 | 0.0368 | -0.49 |
| avg_raceth_6 | -0.2757 | 0.1011 | -2.73 |
| avg_raceth_4 | -0.0196 | 0.0459 | -0.43 |
| avg_raceth_Unknown | -0.0126 | 0.0801 | -0.16 |
| avg_raceth_5 | -0.0237 | 0.0693 | -0.34 |
| avg_raceth_7 | -0.1009 | 0.0961 | -1.05 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000000 | 0.0000 |
| Residual | 0.015461 | 0.1243 |

**ICC:** 0.0000

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -3577.96 |
| BIC | -3393.52 |
| Log-likelihood | 1819.98 |

## Convergence

- Converged: No
- Singular fit: Yes

