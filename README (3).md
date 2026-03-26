# Federal Funds Rate and Unemployment Rate: A Time Series Analysis

This project examines the statistical relationship between the Federal Funds Rate and the U.S. Unemployment Rate using monthly data from 1954 to 2026. The analysis includes lagged correlation, Granger causality testing, and an Impulse Response Function (IRF) derived from a Vector Autoregression (VAR) model.

---

## Data

Both series were downloaded from the [Federal Reserve Bank of St. Louis (FRED)](https://fred.stlouisfed.org/):
- **FEDFUNDS** — Federal Funds Effective Rate
- **UNRATE** — U.S. Unemployment Rate

After merging on date, the overlapping period spans **July 1954 to February 2026**, yielding **860 matched monthly observations**. One missing UNRATE value (October 2025) was filled via linear interpolation.

---

## Libraries

```r
library(tidyverse)
library(zoo)
library(lmtest)
library(vars)
```

---

## Results

### Federal Funds Rate vs. Unemployment Rate (1954–2026)

![Federal Funds Rate vs Unemployment Rate](plots/time_series.png)

Plotting both series over time reveals several notable episodes. The most dramatic is the **Volcker era (1980–1982)**, where the Fed raised rates into the high teens to combat inflation and unemployment followed, breaching 10%. The **COVID-19 pandemic (2020)** is a clear outlier — unemployment spiked to nearly 15% due to an external shock unrelated to monetary policy, while the Fed cut rates toward zero in response. These episodes illustrate both the expected relationship between the two series and its limits.

---

### Lagged Correlation

![Lagged Correlation](plots/lagged_correlation.png)

Rather than looking at the contemporaneous correlation, the fed rate at time *t* was correlated with unemployment at time *t + k* for lags 0 through 48 months. The correlation follows an S-curve shape, accelerating through an inflection point around month 10 and peaking at **r = 0.438 at a lag of 27 months** before gradually declining. This suggests the fed rate has its strongest statistical association with unemployment roughly two years later, consistent with the slow transmission of monetary policy through credit markets, business investment, and hiring decisions. An initial window of 24 months was too short — the correlation was still climbing — so the window was extended to 48 months to capture the full shape.

---

### Impulse Response Function

![Impulse Response Function](plots/irf.png)

A two-variable VAR(14) model was estimated — lag order 14 was selected objectively using the Akaike Information Criterion (AIC) via `VARselect`. The IRF traces the response of unemployment to a one standard deviation shock in the fed rate over 48 months. The **solid black line** is the point estimate of the response at each horizon. The **dashed red lines** are the upper and lower bounds of a 95% bootstrapped confidence interval — when the band straddles the **horizontal line at zero**, the effect is not statistically distinguishable from zero at that horizon.

The IRF shows an initial negative response through roughly month 25 before turning positive, reaching approximately +0.10 by month 48. The confidence band crosses zero throughout, meaning no individual horizon produces a statistically clean effect. The initial dip likely reflects an endogeneity problem — the Fed historically raises rates during periods of economic strength when unemployment is already low, so the data conflates the Fed's reaction to conditions with the downstream effect of its actions.

---

## Granger Causality

Granger causality tests were run at lag order 14 in both directions:

| Direction | F-statistic | p-value |
|---|---|---|
| Fed rate → Unemployment | 2.30 | **0.004** |
| Unemployment → Fed rate | 0.85 | 0.611 |

The fed rate has statistically significant predictive power over future unemployment (p = 0.004), but past unemployment does not meaningfully predict the fed rate — likely because the Fed responds to many signals simultaneously, particularly inflation.

---

## Summary

The evidence points to a moderate, slow-moving relationship between the federal funds rate and unemployment. The Granger test confirms statistically significant predictive power from the fed rate to unemployment, with the lagged correlation peaking at 27 months (r = 0.438). However, the IRF indicates the effect is diffuse and statistically uncertain at any given horizon, and the initial negative response flags endogeneity concerns that limit causal interpretation. A structural VAR (SVAR) that explicitly models the Fed's reaction function would be a natural next step.
