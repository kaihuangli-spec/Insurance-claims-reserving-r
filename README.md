# Claims reserving: Chain Ladder and Mack Chain Ladder (R)

Educational general-insurance claims reserving using `GenIns`, a cumulative paid-claims triangle included with the R package `ChainLadder`.

## Project outputs

The analysis in `claims_reserving.R` is designed to produce:

- `results/manual_chain_ladder.csv` — latest paid claims, cumulative development factors, ultimate claims and estimated IBNR by origin period.
- `results/mack_by_origin.csv` — Mack Chain Ladder reserving estimates and uncertainty statistics.
- `results/claims_development.png` — cumulative paid claims development chart.
- `results/ibnr_by_origin.png` — estimated IBNR by origin period.
- `results/mack_diagnostics.png` — model diagnostic plots.

These outputs are generated when the script is run; results should be reviewed before drawing conclusions.

## Methods

1. Visualise a cumulative paid-claims triangle.
2. Compute volume-weighted age-to-age link ratios.
3. Multiply subsequent link ratios to form cumulative development factors (CDFs).
4. Estimate ultimate claims = latest cumulative paid × CDF.
5. Estimate IBNR = ultimate claims − latest cumulative paid.
6. Fit `MackChainLadder` for reserve standard errors; inspect model assumptions with diagnostics.

## Data and limitations

- Dataset is `GenIns` from the `ChainLadder` package. Its origin periods are illustrative historical data, not current calendar years.
- Project assumes no further loss development beyond the final observed development period (tail factor = 1).
- Classical Chain Ladder assumes historical claim development is suitably predictive of future claim emergence, with no unmodelled material change in claims handling, inflation, or portfolio composition.
- Mack standard errors quantify estimation uncertainty under model assumptions; they are not a guarantee or a confidence interval on their own.
- These are **paid-claims reserve** estimates and do not separately estimate case reserves.

## References

- [ChainLadder package guide](https://mages.github.io/ChainLadder/articles/ChainLadder.html)
- [MackChainLadder function reference](https://mages.github.io/ChainLadder/reference/MackChainLadder.html)
