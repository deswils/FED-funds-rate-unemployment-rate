# ============================================================
# Objective: Analyze the relationship between the federal
#            funds rate and the U.S. unemployment rate
# Author:    DeShan
# Date:      2026-03-25
# Data:      FRED - FEDFUNDS & UNRATE (monthly, 1954-2026)
# ============================================================

# ---- Libraries ---------------------------------------------

library(tidyverse)
library(zoo)
library(lmtest)
library(vars)

# ---- Working Directory & Output Folder ---------------------

setwd("C:/Users/9dlwi/Desktop/fed_funds_unemployment")
dir.create("plots", showWarnings = FALSE)

# ---- Load Data ---------------------------------------------

fedfunds <- read_csv("FEDFUNDS.csv")
unrate   <- read_csv("UNRATE.csv")

# ---- Merge & Clean -----------------------------------------

df <- inner_join(fedfunds, unrate, by = "observation_date") %>%
  rename(date      = observation_date,
         fed_rate  = FEDFUNDS,
         unem_rate = UNRATE) %>%
  mutate(unem_rate = na.approx(unem_rate, na.rm = FALSE))

# ---- Sanity Check ------------------------------------------

glimpse(df)
summary(df)
sum(is.na(df))

# ---- Time Series Plot --------------------------------------

df %>%
  pivot_longer(cols = c(fed_rate, unem_rate),
               names_to = "series",
               values_to = "value") %>%
  mutate(series = recode(series,
                         "fed_rate"  = "Federal Funds Rate",
                         "unem_rate" = "Unemployment Rate")) %>%
  ggplot(aes(x = date, y = value, color = series)) +
  geom_line(linewidth = 0.7) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Federal Funds Rate vs. Unemployment Rate (1954-2026)",
       x = NULL, y = "Percent (%)", color = NULL) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

ggsave("plots/time_series.png", width = 10, height = 5)

# ---- Lagged Correlation ------------------------------------

max_lag <- 48

lag_cors <- sapply(0:max_lag, function(k) {
  cor(df$fed_rate[1:(nrow(df) - k)],
      df$unem_rate[(k + 1):nrow(df)],
      use = "complete.obs")
})

lag_df <- data.frame(lag_months = 0:max_lag, correlation = lag_cors)

ggplot(lag_df, aes(x = lag_months, y = correlation)) +
  geom_line() +
  geom_point() +
  labs(title = "Lagged Correlation between Fed Funds Rate and Unemployment Rate",
       x = "Lag (Months)", y = "Correlation Coefficient") +
  theme_minimal(base_size = 13)

ggsave("plots/lagged_correlation.png", width = 8, height = 5)

# ---- Lag Order Selection -----------------------------------

VARselect(df[, c("fed_rate", "unem_rate")], lag.max = 48, type = "const")

# AIC recommends lag order 14 -> use order = 14 in Granger test

# ---- Granger Causality Test --------------------------------

# Does fed_rate Granger-cause unem_rate?
granger_result <- grangertest(unem_rate ~ fed_rate, order = 14, data = df)
print(granger_result)

# Does unem_rate Granger-cause fed_rate?
granger_result2 <- grangertest(fed_rate ~ unem_rate, order = 14, data = df)
print(granger_result2)

# ---- Impulse Response Function -----------------------------

var_model <- VAR(df[, c("fed_rate", "unem_rate")], p = 14, type = "const")
summary(var_model)

irf_result <- irf(var_model,
                  impulse  = "fed_rate",
                  response = "unem_rate",
                  n.ahead  = 48,
                  boot     = TRUE)

png("plots/irf.png", width = 800, height = 500)
plot(irf_result)
dev.off()
