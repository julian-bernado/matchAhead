# Model Report: Grade 3, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + lep_ever + migrant_ever + homeless_ever + specialed_ever + attend_p0 + gender_2 + raceth_4 + raceth_Unknown + raceth_6 + raceth_2 + raceth_3 + raceth_5 + avg_age + avg_lep_ever + avg_migrant_ever + avg_homeless_ever + avg_specialed_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_6 + avg_raceth_2 + avg_raceth_3 + avg_raceth_5
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 19049 |
| Schools | 230 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.4392 | 0.2793 | 1.57 |
| age | -0.0414 | 0.0160 | -2.58 |
| lep_ever | -0.0155 | 0.0015 | -10.63 |
| migrant_ever | 0.0048 | 0.0078 | 0.61 |
| homeless_ever | -0.0120 | 0.0028 | -4.33 |
| specialed_ever | -0.0644 | 0.0016 | -40.19 |
| attend_p0 | 0.3390 | 0.0149 | 22.69 |
| gender_2 | 0.0091 | 0.0010 | 8.87 |
| raceth_4 | -0.0079 | 0.0069 | -1.14 |
| raceth_Unknown | 0.0062 | 0.0076 | 0.82 |
| raceth_6 | 0.0125 | 0.0070 | 1.80 |
| raceth_2 | 0.0399 | 0.0074 | 5.40 |
| raceth_3 | -0.0276 | 0.0071 | -3.90 |
| raceth_5 | -0.0041 | 0.0138 | -0.30 |
| avg_age | -0.4513 | 0.2602 | -1.73 |
| avg_lep_ever | -0.0034 | 0.0104 | -0.33 |
| avg_migrant_ever | -0.0509 | 0.0992 | -0.51 |
| avg_homeless_ever | -0.0175 | 0.0263 | -0.66 |
| avg_specialed_ever | -0.0409 | 0.0278 | -1.47 |
| avg_attend_p0 | 0.6945 | 0.1858 | 3.74 |
| avg_gender_2 | -0.0182 | 0.0257 | -0.71 |
| avg_raceth_4 | -0.0002 | 0.0768 | -0.00 |
| avg_raceth_Unknown | 0.0628 | 0.1078 | 0.58 |
| avg_raceth_6 | 0.0163 | 0.0777 | 0.21 |
| avg_raceth_2 | 0.0409 | 0.0795 | 0.51 |
| avg_raceth_3 | -0.0420 | 0.0785 | -0.53 |
| avg_raceth_5 | 0.0509 | 0.2837 | 0.18 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000468 | 0.0216 |
| Residual | 0.004916 | 0.0701 |

**ICC:** 0.0869

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -46487.92 |
| BIC | -46260.14 |
| Log-likelihood | 23272.96 |

## Convergence

- Converged: Yes
- Singular fit: No

