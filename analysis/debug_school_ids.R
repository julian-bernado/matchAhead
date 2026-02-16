# analysis/debug_school_ids.R
# Diagnostic script: inspect school identifiers across the targets store
# for type mismatches, missing IDs, or structural irregularities that
# could cause school_match_pim to fail.
#
# Run: Rscript analysis/debug_school_ids.R
# (from the project root, with a populated _targets store)

library(targets)

s <- "3_glmath_a05"  # the chain that errored

cat("=== 1. Error message from school_match_pim ===\n")
err_meta <- tar_meta(
  names = tidyselect::all_of(paste0("school_match_pim_", s)),
  fields = c("error", "warnings")
)
print(err_meta)

# ---- Load the relevant objects ----
cat("\n=== 2. Loading stored objects ===\n")
treatment   <- tar_read_raw(paste0("treatment_", s))
stu_preds   <- tar_read_raw(paste0("student_preds_", s))
sch_preds   <- tar_read_raw(paste0("school_preds_", s))
dist_ma     <- tar_read_raw(paste0("dist_matchahead_", s))
dist_pim    <- tar_read_raw(paste0("dist_pimentel_", s))

# ---- 3. Treatment assignment IDs ----
cat("\n=== 3. Treatment assignment ===\n")
cat("class(treatment$school_id):", class(treatment$school_id), "\n")
cat("n schools:", nrow(treatment), "\n")
cat("n treatment:", sum(treatment$treatment == 1), "\n")
cat("n control:  ", sum(treatment$treatment == 0), "\n")
cat("any NA in school_id:", any(is.na(treatment$school_id)), "\n")
cat("any duplicated school_id:", any(duplicated(treatment$school_id)), "\n")
cat("sample IDs:", head(treatment$school_id, 5), "\n")

t_schools <- treatment$school_id[treatment$treatment == 1]
c_schools <- treatment$school_id[treatment$treatment == 0]

# ---- 4. Student predictions IDs ----
cat("\n=== 4. Student predictions ===\n")
cat("class(stu_preds$school_id):", class(stu_preds$school_id), "\n")
cat("n rows:", nrow(stu_preds), "\n")
cat("n unique schools:", length(unique(stu_preds$school_id)), "\n")
cat("sample IDs:", head(unique(stu_preds$school_id), 5), "\n")

stu_schools <- unique(stu_preds$school_id)
cat("treatment schools missing from student_preds:",
    sum(!t_schools %in% stu_schools), "/", length(t_schools), "\n")
cat("control schools missing from student_preds:",
    sum(!c_schools %in% stu_schools), "/", length(c_schools), "\n")

# ---- 5. School predictions IDs ----
cat("\n=== 5. School predictions ===\n")
cat("class(sch_preds$school_id):", class(sch_preds$school_id), "\n")
cat("n schools:", nrow(sch_preds), "\n")
cat("any NA:", any(is.na(sch_preds$school_id)), "\n")

# ---- 6. Distance data frames — structure ----
inspect_distances <- function(label, dists) {
  cat(sprintf("\n=== 6%s. %s distances ===\n",
              ifelse(label == "matchAhead", "a", "b"), label))
  cat("dim:", nrow(dists), "x", ncol(dists), "\n")
  cat("colnames:", paste(names(dists), collapse = ", "), "\n")
  cat("class(school_1):", class(dists$school_1), "\n")
  cat("class(school_2):", class(dists$school_2), "\n")

  s1 <- unique(dists$school_1)
  s2 <- unique(dists$school_2)
  cat("n unique school_1:", length(s1), "\n")
  cat("n unique school_2:", length(s2), "\n")

  # Check for overlap (school appearing on both sides)
  overlap <- intersect(s1, s2)
  cat("school_1 ∩ school_2 overlap:", length(overlap), "\n")

  # Compare to treatment/control
  cat("school_1 in treatment:", sum(s1 %in% t_schools), "/", length(s1), "\n")
  cat("school_1 in control:  ", sum(s1 %in% c_schools), "/", length(s1), "\n")
  cat("school_2 in treatment:", sum(s2 %in% t_schools), "/", length(s2), "\n")
  cat("school_2 in control:  ", sum(s2 %in% c_schools), "/", length(s2), "\n")

  # IDs in distances but NOT in treatment assignment
  unknown_s1 <- setdiff(s1, treatment$school_id)
  unknown_s2 <- setdiff(s2, treatment$school_id)
  cat("school_1 IDs unknown to treatment:", length(unknown_s1), "\n")
  if (length(unknown_s1) > 0) cat("  examples:", head(unknown_s1, 5), "\n")
  cat("school_2 IDs unknown to treatment:", length(unknown_s2), "\n")
  if (length(unknown_s2) > 0) cat("  examples:", head(unknown_s2, 5), "\n")

  # Distance values
  cat("distance range:", range(dists$distance, na.rm = TRUE), "\n")
  cat("n Inf distances:", sum(is.infinite(dists$distance)), "\n")
  cat("n NA distances: ", sum(is.na(dists$distance)), "\n")
  cat("n NaN distances:", sum(is.nan(dists$distance)), "\n")
  cat("n zero distances:", sum(dists$distance == 0, na.rm = TRUE), "\n")

  # Expected vs actual row count
  expected <- length(t_schools) * length(c_schools)
  cat("expected rows (n_treat x n_ctrl):", expected, "\n")
  cat("actual rows:", nrow(dists), "\n")
  if (nrow(dists) != expected) {
    cat("** MISMATCH: missing", expected - nrow(dists), "pairs **\n")
  }

  # Check for duplicate pairs
  pair_key <- paste(dists$school_1, dists$school_2, sep = "_")
  n_dup <- sum(duplicated(pair_key))
  cat("duplicate (school_1, school_2) pairs:", n_dup, "\n")
}

inspect_distances("matchAhead", dist_ma)
inspect_distances("Pimentel", dist_pim)

# ---- 7. Type consistency check ----
cat("\n=== 7. Type consistency across objects ===\n")
id_types <- data.frame(
  object = c("treatment$school_id", "stu_preds$school_id",
             "sch_preds$school_id",
             "dist_ma$school_1", "dist_ma$school_2",
             "dist_pim$school_1", "dist_pim$school_2"),
  class = c(class(treatment$school_id), class(stu_preds$school_id),
            class(sch_preds$school_id),
            class(dist_ma$school_1), class(dist_ma$school_2),
            class(dist_pim$school_1), class(dist_pim$school_2))
)
print(id_types)

all_char <- all(id_types$class == "character")
cat("All character?", all_char, "\n")
if (!all_char) cat("** WARNING: mixed types may cause matching failures **\n")

# ---- 8. Pimentel Inf analysis ----
# 322,747 Inf distances is 50% — very suspicious for an uncalipered method
cat("\n=== 8. Pimentel Inf distance analysis ===\n")

# Which component (bias, ess) is causing the Inf?
cat("Pimentel bias Inf count:", sum(is.infinite(dist_pim$bias)), "\n")
cat("Pimentel ess Inf count: ", sum(is.infinite(dist_pim$ess)), "\n")
cat("Pimentel bias == 0 count:", sum(dist_pim$bias == 0, na.rm = TRUE), "\n")
cat("Pimentel ess == 0 count: ", sum(dist_pim$ess == 0, na.rm = TRUE), "\n")

# distance = sqrt(bias^alpha * ess^(1-alpha)), so Inf if either component is Inf
# bias is Inf when total_weighted_diff == 0 (perfect match) — see lines 109-113
# ess is Inf when ess_sum == 0 (no matched members) — see lines 115-118

# Per-treatment-school: how many controls have Inf distance?
cat("\nPer-treatment-school Inf rates:\n")
inf_by_treat <- tapply(is.infinite(dist_pim$distance), dist_pim$school_1, sum)
cat("treatment schools where ALL controls are Inf:",
    sum(inf_by_treat == length(c_schools)), "/", length(t_schools), "\n")
cat("treatment schools with >50% Inf controls:",
    sum(inf_by_treat > length(c_schools) / 2), "/", length(t_schools), "\n")
cat("distribution of Inf counts per treatment school:\n")
print(summary(as.numeric(inf_by_treat)))

# Compare: which component is driving it?
both_inf <- sum(is.infinite(dist_pim$bias) & is.infinite(dist_pim$ess))
only_bias_inf <- sum(is.infinite(dist_pim$bias) & !is.infinite(dist_pim$ess))
only_ess_inf <- sum(!is.infinite(dist_pim$bias) & is.infinite(dist_pim$ess))
cat("\nboth bias & ess Inf:", both_inf, "\n")
cat("only bias Inf:", only_bias_inf, "\n")
cat("only ess Inf: ", only_ess_inf, "\n")

# ---- 9. Step-by-step reproduction of match_schools() for Pimentel ----
cat("\n=== 9. Step-by-step match_schools() reproduction ===\n")

# Step 9a: distances_to_matrix
cat("9a. reshape...\n")
dist_wide <- reshape(
  dist_pim[, c("school_1", "school_2", "distance")],
  idvar = "school_1",
  timevar = "school_2",
  direction = "wide"
)
cat("  reshape: ", nrow(dist_wide), "rows x", ncol(dist_wide), "cols\n")

row_names <- dist_wide$school_1
dist_mat <- as.matrix(dist_wide[, -1])
rownames(dist_mat) <- row_names
colnames(dist_mat) <- sub("^distance\\.", "", colnames(dist_mat))

t_in_rows <- intersect(t_schools, rownames(dist_mat))
c_in_cols <- intersect(c_schools, colnames(dist_mat))
cat("  treatment in rows:", length(t_in_rows), "\n")
cat("  control in cols:  ", length(c_in_cols), "\n")

dist_mat <- dist_mat[t_in_rows, c_in_cols, drop = FALSE]
cat("  final dim:", nrow(dist_mat), "x", ncol(dist_mat), "\n")

# Step 9b: Inf replacement
cat("\n9b. Inf replacement...\n")
n_inf <- sum(!is.finite(dist_mat))
cat("  non-finite entries:", n_inf, "/", length(dist_mat), "\n")

any_finite <- any(is.finite(dist_mat))
cat("  any finite values?", any_finite, "\n")
if (any_finite) {
  max_finite <- max(dist_mat[is.finite(dist_mat)], na.rm = TRUE)
  cat("  max finite:", max_finite, "\n")
  large_val <- max_finite * 1000
  dist_mat[!is.finite(dist_mat)] <- large_val
} else {
  cat("  ** ALL values are non-finite — this will break pairmatch **\n")
}

nt <- nrow(dist_mat)
nc <- ncol(dist_mat)

# Step 9c: match_on
cat("\n9c. optmatch::match_on...\n")
tryCatch({
  dist_obj <- optmatch::match_on(dist_mat)
  cat("  match_on succeeded\n")
}, error = function(e) {
  cat("  ** match_on ERROR:", conditionMessage(e), "**\n")
})

# Step 9d: pairmatch
cat("\n9d. optmatch::pairmatch...\n")
pm <- NULL
tryCatch({
  pm <- optmatch::pairmatch(dist_obj, controls = 1, data = NULL)
  cat("  pairmatch succeeded, length:", length(pm), "\n")
  cat("  n matched:", sum(!is.na(pm)), "\n")
  cat("  n unmatched:", sum(is.na(pm)), "\n")
}, error = function(e) {
  cat("  ** pairmatch ERROR:", conditionMessage(e), "**\n")
})

# Step 9e: parse results (where the actual subscript error likely lives)
if (!is.null(pm)) {
  cat("\n9e. Parsing matched pairs...\n")
  matched <- !is.na(pm)
  strata <- unique(pm[matched])
  cat("  n strata:", length(strata), "\n")
  cat("  strata sample:", head(strata, 5), "\n")
  cat("  names(pm) sample:", head(names(pm), 10), "\n")
  cat("  names(pm) in dist_mat rownames:", sum(names(pm) %in% rownames(dist_mat)), "\n")
  cat("  names(pm) in dist_mat colnames:", sum(names(pm) %in% colnames(dist_mat)), "\n")

  # Check: do pm names match the matrix row/col names?
  pm_names <- names(pm)
  expected_names <- c(rownames(dist_mat), colnames(dist_mat))
  missing_from_expected <- setdiff(pm_names, expected_names)
  cat("  pm names NOT in matrix row/colnames:", length(missing_from_expected), "\n")
  if (length(missing_from_expected) > 0) {
    cat("    examples:", head(missing_from_expected, 5), "\n")
    cat("    ** This is likely the cause of 'subscript out of bounds' **\n")
  }

  # Try the for loop one iteration at a time
  cat("\n  Testing for-loop parsing (first 5 strata):\n")
  treatment_school <- character(length(strata))
  control_school <- character(length(strata))
  match_distance <- numeric(length(strata))

  for (i in seq_along(strata)) {
    tryCatch({
      members <- names(pm)[pm == strata[i] & !is.na(pm)]
      t_member <- members[members %in% rownames(dist_mat)]
      c_member <- members[members %in% colnames(dist_mat)]

      if (i <= 5) {
        cat(sprintf("    stratum %s: %d members, %d treat, %d ctrl\n",
                    strata[i], length(members), length(t_member), length(c_member)))
      }

      if (length(t_member) == 1 && length(c_member) == 1) {
        treatment_school[i] <- t_member
        control_school[i] <- c_member
        match_distance[i] <- dist_mat[t_member, c_member]
      }
    }, error = function(e) {
      cat(sprintf("    ** stratum %s ERROR: %s **\n", strata[i], conditionMessage(e)))
    })
  }

  valid <- treatment_school != ""
  cat("\n  valid pairs:", sum(valid), "/", length(strata), "\n")
}

cat("\nDone.\n")
