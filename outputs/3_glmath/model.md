# Model Report: Grade 3, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + gender_2 + raceth_3 + raceth_7 + raceth_2 + raceth_5 + raceth_4 + raceth_Unknown + raceth_6 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_gender_2 + avg_raceth_3 + avg_raceth_7 + avg_raceth_2 + avg_raceth_5 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_6
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 27732 |
| Schools | 1000 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.6167 | 0.0858 | 7.19 |
| age | 0.0166 | 0.0150 | 1.10 |
| specialed_ever | -0.0213 | 0.0022 | -9.78 |
| homeless_ever | 0.0035 | 0.0034 | 1.04 |
| lep_ever | -0.0105 | 0.0019 | -5.42 |
| migrant_ever | -0.0010 | 0.0039 | -0.26 |
| attend_p0 | -0.0115 | 0.0105 | -1.09 |
| gender_2 | -0.0006 | 0.0015 | -0.41 |
| raceth_3 | 0.0014 | 0.0022 | 0.64 |
| raceth_7 | 0.0021 | 0.0058 | 0.37 |
| raceth_2 | 0.0029 | 0.0019 | 1.53 |
| raceth_5 | 0.0019 | 0.0048 | 0.40 |
| raceth_4 | 0.0029 | 0.0030 | 0.96 |
| raceth_Unknown | -0.0049 | 0.0046 | -1.06 |
| raceth_6 | 0.0003 | 0.0057 | 0.04 |
| avg_age | -0.0150 | 0.0862 | -0.17 |
| avg_specialed_ever | -0.0198 | 0.0122 | -1.63 |
| avg_homeless_ever | -0.0775 | 0.0174 | -4.45 |
| avg_lep_ever | -0.0311 | 0.0102 | -3.06 |
| avg_migrant_ever | -0.0522 | 0.0211 | -2.47 |
| avg_attend_p0 | 0.0192 | 0.0575 | 0.33 |
| avg_gender_2 | 0.0143 | 0.0084 | 1.71 |
| avg_raceth_3 | 0.0104 | 0.0116 | 0.90 |
| avg_raceth_7 | 0.0266 | 0.0312 | 0.85 |
| avg_raceth_2 | 0.0145 | 0.0106 | 1.37 |
| avg_raceth_5 | 0.0343 | 0.0258 | 1.33 |
| avg_raceth_4 | 0.0329 | 0.0161 | 2.05 |
| avg_raceth_Unknown | 0.0241 | 0.0253 | 0.95 |
| avg_raceth_6 | -0.0130 | 0.0305 | -0.43 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000060 | 0.0077 |
| Residual | 0.015455 | 0.1243 |

**ICC:** 0.0039

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -36576.77 |
| BIC | -36321.63 |
| Log-likelihood | 18319.39 |

## Convergence

- Converged: Yes
- Singular fit: No

