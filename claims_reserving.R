# Claims Reserving in R: Chain Ladder and Mack Chain Ladder
# Dataset: GenIns, provided by the ChainLadder R package.

library(ChainLadder)

# STEP 1: Load a cumulative paid-claims triangle.
data("GenIns", package = "ChainLadder")
triangle <- GenIns
print(triangle)

# Create a folder for outputs.
dir.create("results", showWarnings = FALSE)

# STEP 2: Visualise how cumulative claims develop.
png("results/claims_development.png", width = 1000, height = 650)
plot(triangle, main = "Cumulative claims development by origin period")
dev.off()

# STEP 3: Calculate volume-weighted age-to-age factors manually.
# Use only origin periods with both development ages observed.
n_dev <- ncol(triangle)
factors <- sapply(seq_len(n_dev - 1), function(j) {
  valid <- !is.na(triangle[, j]) & !is.na(triangle[, j + 1])
  sum(triangle[valid, j + 1]) / sum(triangle[valid, j])
})
names(factors) <- paste0(colnames(triangle)[-n_dev], "-to-",
                         colnames(triangle)[-1])
cat("\nAge-to-age development factors:\n")
print(round(factors, 4))

# STEP 4: Calculate cumulative development factors to ultimate.
# Assume no development beyond the final observed development age.
cdf <- sapply(seq_len(n_dev), function(j) {
  if (j == n_dev) 1 else prod(factors[j:(n_dev - 1)])
})

# STEP 5: Calculate latest paid claims, ultimate claims, and IBNR.
latest_col <- apply(!is.na(triangle), 1, function(x) max(which(x)))
latest_paid <- as.numeric(triangle[cbind(seq_len(nrow(triangle)), latest_col)])
ultimate <- latest_paid * cdf[latest_col]
ibnr <- ultimate - latest_paid

results <- data.frame(
  Origin_Period = rownames(triangle),
  Latest_Paid = latest_paid,
  CDF = cdf[latest_col],
  Estimated_Ultimate = ultimate,
  IBNR = ibnr
)
cat("\nManual Chain Ladder estimates:\n")
print(round(results[, -1], 2))
cat("\nTotal manual IBNR:", round(sum(results$IBNR), 2), "\n")
write.csv(results, "results/manual_chain_ladder.csv", row.names = FALSE)

# STEP 6: Fit the Mack Chain Ladder model for uncertainty estimates.
mack <- MackChainLadder(triangle, est.sigma = "Mack")
mack_summary <- summary(mack)
cat("\nMack Chain Ladder summary:\n")
print(mack)
write.csv(mack_summary$ByOrigin,
          "results/mack_by_origin.csv", row.names = TRUE)

# STEP 7: Check that the manual reserves match Mack's point estimates.
check <- all.equal(as.numeric(results$IBNR),
                   as.numeric(mack_summary$ByOrigin$IBNR),
                   tolerance = 1e-6)
cat("\nManual versus Mack reserve check:", check, "\n")

# STEP 8: Export an IBNR chart and model diagnostic plots.
png("results/ibnr_by_origin.png", width = 1000, height = 650)
barplot(results$IBNR / 1e6,
        names.arg = results$Origin_Period,
        col = "steelblue", main = "Estimated IBNR by origin period",
        xlab = "Origin period", ylab = "IBNR (millions)")
dev.off()

png("results/mack_diagnostics.png", width = 1200, height = 900)
plot(mack)
dev.off()

cat("\nDone! Inspect the CSV and PNG files in the results folder.\n")
