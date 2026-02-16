# analysis/debug_reshape_fix.R
# Demonstrates the reshape() bug and validates the tapply fix.
#
# Run: Rscript analysis/debug_reshape_fix.R

library(targets)

s <- "3_glmath_a05"
dist_pim  <- tar_read_raw(paste0("dist_pimentel_", s))
treatment <- tar_read_raw(paste0("treatment_", s))

tc <- list(
  treatment_schools = treatment$school_id[treatment$treatment == 1],
  control_schools   = treatment$school_id[treatment$treatment == 0]
)

# ============================================================
# METHOD A: reshape() — the current code (BROKEN)
# ============================================================
cat("=== METHOD A: reshape() ===\n")

dist_wide <- reshape(
  dist_pim[, c("school_1", "school_2", "distance")],
  idvar = "school_1",
  timevar = "school_2",
  direction = "wide"
)
cat("dist_wide dim:", nrow(dist_wide), "x", ncol(dist_wide), "\n")

# Show the artifact column
cat("Column [2]:", sprintf("'%s'", names(dist_wide)[2]), "\n")
cat("  → reshape() injects a phantom 'distance.' column with no school ID\n")
cat("  → after sub() this becomes an empty-string colname\n")

row_names <- dist_wide$school_1
mat_a <- as.matrix(dist_wide[, -1])
rownames(mat_a) <- row_names
colnames(mat_a) <- sub("^distance\\.", "", colnames(mat_a))

cat("Matrix dim:", nrow(mat_a), "x", ncol(mat_a), "\n")
cat("Empty colname present:", any(colnames(mat_a) == ""), "\n")

t_schools <- intersect(tc$treatment_schools, rownames(mat_a))
c_schools <- intersect(tc$control_schools, colnames(mat_a))

tryCatch({
  result_a <- mat_a[t_schools, c_schools, drop = FALSE]
  cat("Character indexing: OK\n")
}, error = function(e) {
  cat("Character indexing: FAILED —", conditionMessage(e), "\n")
})

# ============================================================
# METHOD B: tapply() — proposed fix
# ============================================================
cat("\n=== METHOD B: tapply() ===\n")

mat_b <- tapply(dist_pim$distance,
                list(dist_pim$school_1, dist_pim$school_2),
                FUN = identity)

cat("Matrix dim:", nrow(mat_b), "x", ncol(mat_b), "\n")
cat("Empty colname present:", any(colnames(mat_b) == ""), "\n")

t_schools_b <- intersect(tc$treatment_schools, rownames(mat_b))
c_schools_b <- intersect(tc$control_schools, colnames(mat_b))

tryCatch({
  result_b <- mat_b[t_schools_b, c_schools_b, drop = FALSE]
  cat("Character indexing: OK\n")
  cat("Result dim:", nrow(result_b), "x", ncol(result_b), "\n")
}, error = function(e) {
  cat("Character indexing: FAILED —", conditionMessage(e), "\n")
})

# ============================================================
# Verify equivalence (excluding the artifact column)
# ============================================================
cat("\n=== Equivalence check ===\n")

# Get the valid columns from method A using numeric indexing
valid_cols <- which(colnames(mat_a) != "")
mat_a_clean <- mat_a[, valid_cols, drop = FALSE]

# Align to the same row/col order
shared_rows <- intersect(rownames(mat_a_clean), rownames(mat_b))
shared_cols <- intersect(colnames(mat_a_clean), colnames(mat_b))

a_aligned <- mat_a_clean[shared_rows, shared_cols]
b_aligned <- mat_b[shared_rows, shared_cols]

diffs <- sum(abs(a_aligned - b_aligned) > 1e-12, na.rm = TRUE)
cat("Shared rows:", length(shared_rows), "\n")
cat("Shared cols:", length(shared_cols), "\n")
cat("Values differing:", diffs, "\n")

if (diffs == 0) {
  cat("\ntapply() produces identical values without the artifact column.\n")
  cat("Safe to replace reshape() with tapply() in distances_to_matrix().\n")
} else {
  cat("\nWARNING: values differ — investigate before replacing.\n")
}

# ============================================================
# Full end-to-end: run match_schools logic with tapply matrix
# ============================================================
cat("\n=== End-to-end: pairmatch with tapply matrix ===\n")

dist_mat <- result_b
max_finite <- max(dist_mat[is.finite(dist_mat)], na.rm = TRUE)
dist_mat[!is.finite(dist_mat)] <- max_finite * 1000

dist_obj <- optmatch::match_on(dist_mat)
pm <- optmatch::pairmatch(dist_obj, controls = 1, data = NULL)

matched <- !is.na(pm)
strata <- unique(pm[matched])

cat("pairmatch succeeded\n")
cat("n strata (pairs):", length(strata), "\n")
cat("n matched units:", sum(matched), "\n")

cat("\nDone.\n")
