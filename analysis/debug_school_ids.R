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

# ---- 8. Reproduce the pivot that fails in match_schools ----
cat("\n=== 8. Reproducing distances_to_matrix() for Pimentel ===\n")
tryCatch({
  dist_wide <- reshape(
    dist_pim[, c("school_1", "school_2", "distance")],
    idvar = "school_1",
    timevar = "school_2",
    direction = "wide"
  )
  cat("reshape succeeded: ", nrow(dist_wide), "rows x", ncol(dist_wide), "cols\n")

  row_names <- dist_wide$school_1
  dist_mat <- as.matrix(dist_wide[, -1])
  rownames(dist_mat) <- row_names
  colnames(dist_mat) <- sub("^distance\\.", "", colnames(dist_mat))

  t_in_rows <- intersect(t_schools, rownames(dist_mat))
  c_in_cols <- intersect(c_schools, colnames(dist_mat))
  cat("treatment schools in rows:", length(t_in_rows), "/", length(t_schools), "\n")
  cat("control schools in cols: ", length(c_in_cols), "/", length(c_schools), "\n")

  if (length(t_in_rows) == 0 || length(c_in_cols) == 0) {
    cat("** PROBLEM: empty matrix after subsetting — IDs don't match **\n")
  }

  dist_mat <- dist_mat[t_in_rows, c_in_cols, drop = FALSE]
  cat("final matrix dim:", dim(dist_mat), "\n")

  # Check for all-Inf rows/cols
  all_inf_rows <- apply(dist_mat, 1, function(x) all(is.infinite(x)))
  all_inf_cols <- apply(dist_mat, 2, function(x) all(is.infinite(x)))
  cat("rows where all distances are Inf:", sum(all_inf_rows), "\n")
  cat("cols where all distances are Inf:", sum(all_inf_cols), "\n")

  # Try pairmatch
  cat("\n=== 9. Attempting pairmatch on Pimentel distances ===\n")
  max_finite <- max(dist_mat[is.finite(dist_mat)], na.rm = TRUE)
  large_val <- max_finite * 1000
  dist_mat[!is.finite(dist_mat)] <- large_val

  nt <- nrow(dist_mat)
  nc <- ncol(dist_mat)
  cat("nt (treatment):", nt, " nc (control):", nc, "\n")

  dist_obj <- optmatch::match_on(dist_mat)
  pm <- optmatch::pairmatch(dist_obj, controls = 1, data = NULL)
  cat("pairmatch succeeded! n matched:", sum(!is.na(pm)), "\n")

}, error = function(e) {
  cat("** ERROR during reproduction:", conditionMessage(e), "**\n")
})

cat("\nDone.\n")
