# matchAhead vs Pimentel Comparison Report

## Treatment Effect Estimates

| Grade | Subject | MA CI Lower | MA CI Upper | Pim CI Lower | Pim CI Upper | Rel. Efficiency | Time Ratio |
|-------|---------|-------------|-------------|--------------|--------------|-----------------|------------|
| 3 | glmath | -0.0032 | 0.0064 | -0.0316 | 0.0006 | 11.423 | 14.20 |
| 3 | readng | -0.0112 | 0.0005 | -0.0251 | 0.0020 | 5.368 | 13.49 |
| 4 | glmath | 0.0008 | 0.0096 | -0.0407 | -0.0138 | 9.284 | 17.95 |
| 4 | readng | 0.0015 | 0.0079 | -0.0322 | -0.0131 | 9.068 | 17.85 |
| 5 | glmath | -0.0009 | 0.0087 | -0.0413 | -0.0132 | 8.637 | 17.24 |
| 5 | readng | -0.0038 | 0.0034 | -0.0350 | -0.0125 | 9.644 | 17.75 |

## Configuration

- **Model Year**: 2019
- **Prediction Year**: 2022
- **Max Controls**: 5
- **Alpha**: 0.50
- **Prop Treatment**: 0.03
- **Sample Prop**: 1.00
- **Seed**: 2026
- **N Cores**: 14

## Column Definitions

### Treatment Effect Estimates
- **Grade**: Grade level (3, 4, or 5)
- **Subject**: glmath or readng
- **MA CI Lower/Upper**: matchAhead 95% confidence interval bounds
- **Pim CI Lower/Upper**: Pimentel 95% confidence interval bounds
- **Rel. Efficiency**: Relative efficiency = (Pimentel SE / matchAhead SE)^2
- **Time Ratio**: pim_avg_time_per_pair / ma_avg_time_per_pair (speedup factor)

