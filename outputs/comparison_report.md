# matchAhead vs Pimentel Comparison Report

## Treatment Effect Estimates

| Grade | Subject | MA CI Lower | MA CI Upper | Pim CI Lower | Pim CI Upper | Rel. Efficiency | Time Ratio |
|-------|---------|-------------|-------------|--------------|--------------|-----------------|------------|
| 3 | glmath | -0.0226 | 0.0093 | -0.0517 | 0.0093 | 3.666 | 12.10 |
| 3 | readng | -0.0407 | 0.0058 | -0.0481 | 0.0251 | 2.479 | 12.11 |
| 4 | glmath | -0.0011 | 0.0110 | -0.0349 | 0.0024 | 9.541 | 11.18 |
| 4 | readng | -0.0019 | 0.0131 | -0.0345 | 0.0035 | 6.395 | 14.27 |
| 5 | glmath | -0.0141 | 0.0196 | -0.0735 | -0.0068 | 3.927 | 18.41 |
| 5 | readng | -0.0070 | 0.0196 | -0.0192 | 0.0118 | 1.357 | 12.90 |

## Configuration

- **Model Year**: 2019
- **Prediction Year**: 2022
- **Max Controls**: 5
- **Alpha**: 0.50
- **Prop Treatment**: 0.03
- **Sample Prop**: 0.10
- **Seed**: 2026
- **N Cores**: 24

## Column Definitions

### Treatment Effect Estimates
- **Grade**: Grade level (3, 4, or 5)
- **Subject**: glmath or readng
- **MA CI Lower/Upper**: matchAhead 95% confidence interval bounds
- **Pim CI Lower/Upper**: Pimentel 95% confidence interval bounds
- **Rel. Efficiency**: Relative efficiency = (Pimentel SE / matchAhead SE)^2
- **Time Ratio**: pim_avg_time_per_pair / ma_avg_time_per_pair (speedup factor)

