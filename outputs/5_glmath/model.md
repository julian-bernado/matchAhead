# Model Report: Grade 5, glmath

## Model Formula

```
glmath_scr_p0 ~ (1 | dstschid_state_enroll_p0) + age + specialed_ever + homeless_ever + lep_ever + migrant_ever + attend_p0 + glmath_scr_m1 + gender_2 + raceth_2 + raceth_7 + raceth_3 + raceth_5 + raceth_4 + raceth_Unknown + raceth_6 + avg_age + avg_specialed_ever + avg_homeless_ever + avg_lep_ever + avg_migrant_ever + avg_attend_p0 + avg_glmath_scr_m1 + avg_gender_2 + avg_raceth_2 + avg_raceth_7 + avg_raceth_3 + avg_raceth_5 + avg_raceth_4 + avg_raceth_Unknown + avg_raceth_6
```

## Sample Size

| Metric | Value |
|--------|-------|
| Students | 2722 |
| Schools | 100 |

## Fixed Effects

| Term | Estimate | SE | t-value |
|------|----------|-----|---------|
| (Intercept) | 0.6300 | 0.2442 | 2.58 |
| age | -0.0243 | 0.0392 | -0.62 |
| specialed_ever | -0.0104 | 0.0049 | -2.14 |
| homeless_ever | 0.0067 | 0.0078 | 0.86 |
| lep_ever | -0.0010 | 0.0043 | -0.23 |
| migrant_ever | -0.0030 | 0.0088 | -0.34 |
| attend_p0 | -0.0024 | 0.0238 | -0.10 |
| glmath_scr_m1 | 0.7408 | 0.0138 | 53.66 |
| gender_2 | -0.0001 | 0.0034 | -0.03 |
| raceth_2 | 0.0061 | 0.0043 | 1.42 |
| raceth_7 | -0.0077 | 0.0132 | -0.58 |
| raceth_3 | 0.0023 | 0.0048 | 0.48 |
| raceth_5 | 0.0043 | 0.0105 | 0.41 |
| raceth_4 | 0.0094 | 0.0065 | 1.44 |
| raceth_Unknown | 0.0110 | 0.0101 | 1.09 |
| raceth_6 | 0.0179 | 0.0122 | 1.47 |
| avg_age | -0.3718 | 0.2274 | -1.63 |
| avg_specialed_ever | -0.0248 | 0.0262 | -0.95 |
| avg_homeless_ever | -0.0489 | 0.0391 | -1.25 |
| avg_lep_ever | -0.0244 | 0.0232 | -1.06 |
| avg_migrant_ever | -0.0231 | 0.0418 | -0.55 |
| avg_attend_p0 | -0.1459 | 0.1337 | -1.09 |
| avg_glmath_scr_m1 | 0.7696 | 0.0699 | 11.01 |
| avg_gender_2 | -0.0174 | 0.0186 | -0.94 |
| avg_raceth_2 | -0.0142 | 0.0228 | -0.62 |
| avg_raceth_7 | 0.1256 | 0.0733 | 1.71 |
| avg_raceth_3 | -0.0033 | 0.0298 | -0.11 |
| avg_raceth_5 | 0.0403 | 0.0593 | 0.68 |
| avg_raceth_4 | 0.0230 | 0.0336 | 0.69 |
| avg_raceth_Unknown | 0.0733 | 0.0556 | 1.32 |
| avg_raceth_6 | 0.0201 | 0.0655 | 0.31 |

## Random Effects

| Component | Variance | SD |
|-----------|----------|-----|
| School (Intercept) | 0.000000 | 0.0000 |
| Residual | 0.007534 | 0.0868 |

**ICC:** 0.0000

## Model Fit

| Metric | Value |
|--------|-------|
| AIC | -5355.04 |
| BIC | -5160.04 |
| Log-likelihood | 2710.52 |

## Convergence

- Converged: No
- Singular fit: Yes

