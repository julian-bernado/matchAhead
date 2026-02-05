# matchAhead vs Pimentel Comparison Report

## Treatment Effect Estimates

| Grade | Subject | MA CI Lower | MA CI Upper | Pim CI Lower | Pim CI Upper | Rel. Efficiency | Time Ratio |
|-------|---------|-------------|-------------|--------------|--------------|-----------------|------------|
| 3 | glmath | 0.1843 | 0.2027 | 0.1682 | 0.1925 | 1.738 | 14.97 |
| 3 | readng | 0.1811 | 0.2033 | 0.1754 | 0.2114 | 2.630 | 13.39 |
| 4 | glmath | 0.1923 | 0.2075 | 0.1723 | 0.1930 | 1.868 | 15.23 |
| 4 | readng | 0.1985 | 0.2118 | 0.1869 | 0.2025 | 1.366 | 11.61 |
| 5 | glmath | 0.1919 | 0.2086 | 0.1629 | 0.2241 | 13.373 | 19.99 |
| 5 | readng | 0.1923 | 0.2080 | 0.1828 | 0.1998 | 1.165 | 12.83 |

## Configuration

- **Model Year**: 2019
- **Prediction Year**: 2022
- **Max Controls**: 5
- **Alpha**: 0.50
- **Prop Treatment**: 0.10
- **Sample Prop**: 0.10
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

