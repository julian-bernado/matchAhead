# matchAhead vs Pimentel Comparison Report

## Treatment Effect Estimates

| Grade | Subject | MA CI Lower | MA CI Upper | Pim CI Lower | Pim CI Upper | Rel. Efficiency | Time Ratio |
|-------|---------|-------------|-------------|--------------|--------------|-----------------|------------|
| 3 | glmath | 0.1797 | 0.2066 | 0.1851 | 0.2138 | 1.144 | 13.62 |
| 3 | readng | 0.1747 | 0.2053 | 0.1578 | 0.2108 | 2.986 | 12.17 |
| 4 | glmath | 0.1880 | 0.2111 | 0.1741 | 0.2128 | 2.798 | 14.37 |
| 4 | readng | 0.1949 | 0.2090 | 0.1856 | 0.2139 | 3.994 | 16.96 |
| 5 | glmath | 0.1781 | 0.2005 | 0.1640 | 0.2250 | 7.464 | 12.18 |
| 5 | readng | 0.1962 | 0.2123 | 0.1761 | 0.1946 | 1.320 | 14.87 |

## Configuration

- **Model Year**: 2019
- **Prediction Year**: 2022
- **Max Controls**: 5
- **Alpha**: 0.50
- **Prop Treatment**: 0.10
- **Sample Prop**: 0.05
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

