# matchAhead vs Pimentel Comparison Report

## Treatment Effect Estimates

| Grade | Subject | MA CI Lower | MA CI Upper | Pim CI Lower | Pim CI Upper | Rel. Efficiency | Time Ratio |
|-------|---------|-------------|-------------|--------------|--------------|-----------------|------------|
| 3 | glmath | 0.1658 | 0.1860 | 0.1637 | 0.2083 | 4.862 | 9.99 |
| 3 | readng | 0.1779 | 0.2236 | 0.1778 | 0.2241 | 1.025 | 9.92 |
| 4 | glmath | 0.1810 | 0.2225 | 0.1863 | 0.2154 | 0.492 | 13.91 |
| 4 | readng | 0.1866 | 0.2250 | 0.1937 | 0.2241 | 0.630 | 13.65 |
| 5 | glmath | 0.1791 | 0.2185 | 0.1779 | 0.2115 | 0.728 | 13.63 |
| 5 | readng | 0.1901 | 0.2182 | 0.1745 | 0.2172 | 2.303 | 13.41 |

## Configuration

- **Model Year**: 2019
- **Prediction Year**: 2021
- **Max Controls**: 5
- **Alpha**: 0.50
- **Prop Treatment**: 0.10
- **Sample Prop**: 1.00
- **Seed**: 2026
- **N Cores**: 8

## Column Definitions

### Treatment Effect Estimates
- **Grade**: Grade level (3, 4, or 5)
- **Subject**: glmath or readng
- **MA CI Lower/Upper**: matchAhead 95% confidence interval bounds
- **Pim CI Lower/Upper**: Pimentel 95% confidence interval bounds
- **Rel. Efficiency**: Relative efficiency = (Pimentel SE / matchAhead SE)^2
- **Time Ratio**: pim_avg_time_per_pair / ma_avg_time_per_pair (speedup factor)

