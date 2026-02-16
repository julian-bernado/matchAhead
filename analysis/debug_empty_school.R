# analysis/debug_empty_school.R
# Investigate the phantom school with ID "" that breaks matrix subscripting.
#
# Run: Rscript analysis/debug_empty_school.R

library(targets)

s <- "3_glmath_a05"

cat("=== 1. Where does school \"\" appear? ===\n")

treatment <- tar_read_raw(paste0("treatment_", s))
stu_preds <- tar_read_raw(paste0("student_preds_", s))
sch_preds <- tar_read_raw(paste0("school_preds_", s))
dist_pim  <- tar_read_raw(paste0("dist_pimentel_", s))
dist_ma   <- tar_read_raw(paste0("dist_matchahead_", s))

cat("\"\" in treatment$school_id:", "" %in% treatment$school_id, "\n")
cat("\"\" in stu_preds$school_id:", "" %in% stu_preds$school_id, "\n")
cat("\"\" in sch_preds$school_id:", "" %in% sch_preds$school_id, "\n")
cat("\"\" in dist_pim$school_1:  ", "" %in% dist_pim$school_1, "\n")
cat("\"\" in dist_pim$school_2:  ", "" %in% dist_pim$school_2, "\n")
cat("\"\" in dist_ma$school_1:   ", "" %in% dist_ma$school_1, "\n")
cat("\"\" in dist_ma$school_2:   ", "" %in% dist_ma$school_2, "\n")

cat("\n=== 2. Treatment status of school \"\" ===\n")
empty_row <- treatment[treatment$school_id == "", ]
if (nrow(empty_row) > 0) {
  cat("treatment assignment:", empty_row$treatment, "\n")
  cat("  (0 = control, 1 = treatment)\n")
} else {
  cat("school \"\" NOT in treatment assignment\n")
}

cat("\n=== 3. Students in school \"\" ===\n")
empty_students <- stu_preds[stu_preds$school_id == "", ]
cat("n students with school_id == \"\":", nrow(empty_students), "\n")
if (nrow(empty_students) > 0) {
  cat("student_score summary:\n")
  print(summary(empty_students$student_score))
  # Don't print study_ids (restricted data)
  cat("columns:", paste(names(empty_students), collapse = ", "), "\n")
}

cat("\n=== 4. School-level prediction for school \"\" ===\n")
empty_school <- sch_preds[sch_preds$school_id == "", ]
if (nrow(empty_school) > 0) {
  cat("school_score:", empty_school$school_score, "\n")
} else {
  cat("school \"\" NOT in school predictions\n")
}

cat("\n=== 5. Distances involving school \"\" ===\n")
pim_as_s1 <- dist_pim[dist_pim$school_1 == "", ]
pim_as_s2 <- dist_pim[dist_pim$school_2 == "", ]
cat("Pimentel pairs where school_1 == \"\":", nrow(pim_as_s1), "\n")
cat("Pimentel pairs where school_2 == \"\":", nrow(pim_as_s2), "\n")
if (nrow(pim_as_s1) > 0) {
  cat("  distance summary (as school_1):\n")
  print(summary(pim_as_s1$distance))
  cat("  n Inf:", sum(is.infinite(pim_as_s1$distance)), "\n")
}
if (nrow(pim_as_s2) > 0) {
  cat("  distance summary (as school_2):\n")
  print(summary(pim_as_s2$distance))
  cat("  n Inf:", sum(is.infinite(pim_as_s2$distance)), "\n")
}

ma_as_s1 <- dist_ma[dist_ma$school_1 == "", ]
ma_as_s2 <- dist_ma[dist_ma$school_2 == "", ]
cat("matchAhead pairs where school_1 == \"\":", nrow(ma_as_s1), "\n")
cat("matchAhead pairs where school_2 == \"\":", nrow(ma_as_s2), "\n")

cat("\n=== 6. Trace back to cleaned data ===\n")
# Load the cleaned 2022 data (prediction year) to check the raw school ID column
data_2022 <- tar_read_raw(paste0("cleaned_data_", s, "_2022"))
cat("class(dstschid_state_enroll_p0):", class(data_2022$dstschid_state_enroll_p0), "\n")

# Check for empty/blank/NA in the school ID column
sch_col <- data_2022$dstschid_state_enroll_p0
if (is.factor(sch_col)) {
  cat("factor levels containing \"\":", "" %in% levels(sch_col), "\n")
  cat("n observations at \"\" level:", sum(as.character(sch_col) == "", na.rm = TRUE), "\n")
  cat("n NA observations:", sum(is.na(sch_col)), "\n")
  cat("total factor levels:", nlevels(sch_col), "\n")

  # Check for blank-ish levels (whitespace, etc.)
  suspect_levels <- levels(sch_col)[nchar(trimws(levels(sch_col))) == 0]
  cat("blank/whitespace-only levels:", length(suspect_levels), "\n")
  if (length(suspect_levels) > 0) {
    cat("  values (repr):", sapply(suspect_levels, function(x) sprintf("'%s' (nchar=%d)", x, nchar(x))), "\n")
  }

  # What does the "" level look like as raw bytes?
  if ("" %in% levels(sch_col)) {
    cat("  charToRaw(\"\"):", paste(charToRaw(""), collapse = " "), "\n")
    # Check if it's truly zero-length or has invisible chars
    empty_level <- levels(sch_col)[levels(sch_col) == ""]
    cat("  nchar of empty level:", nchar(empty_level), "\n")
  }
} else {
  cat("(not a factor — class:", class(sch_col), ")\n")
  cat("n empty strings:", sum(sch_col == "", na.rm = TRUE), "\n")
  cat("n NA values:", sum(is.na(sch_col)), "\n")
}

# Also check 2019 (model year)
cat("\n=== 7. Check 2019 data too ===\n")
data_2019 <- tar_read_raw(paste0("cleaned_data_", s, "_2019"))
sch_col_19 <- data_2019$dstschid_state_enroll_p0
if (is.factor(sch_col_19)) {
  cat("2019 factor levels containing \"\":", "" %in% levels(sch_col_19), "\n")
  cat("2019 n observations at \"\" level:", sum(as.character(sch_col_19) == "", na.rm = TRUE), "\n")
} else {
  cat("2019 n empty strings:", sum(sch_col_19 == "", na.rm = TRUE), "\n")
}

cat("\n=== 8. Provenance: how does \"\" enter treatment assignment? ===\n")
# Reproduce assign_treatment_from_data logic
school_ids_2022 <- as.character(unique(data_2022$dstschid_state_enroll_p0))
cat("n unique school IDs from 2022 data:", length(school_ids_2022), "\n")
cat("\"\" in school_ids_2022:", "" %in% school_ids_2022, "\n")

# Check: is it a factor-to-character conversion artifact?
# as.character on a factor with NA level
cat("any NA in as.character(unique(...)):", any(is.na(school_ids_2022)), "\n")

# If dstschid is numeric-ish, check for 0 or NA that becomes ""
if (is.factor(sch_col)) {
  raw_levels <- levels(sch_col)
  cat("first 5 levels:", head(raw_levels, 5), "\n")
  cat("last 5 levels:", tail(raw_levels, 5), "\n")
  # Position of "" in sorted levels
  pos <- which(raw_levels == "")
  cat("position of \"\" in levels:", pos, "\n")
  if (length(pos) > 0 && pos > 1) {
    cat("  level before \"\":", sprintf("'%s'", raw_levels[pos - 1]), "\n")
  }
  if (length(pos) > 0 && pos < length(raw_levels)) {
    cat("  level after \"\":", sprintf("'%s'", raw_levels[pos + 1]), "\n")
  }
}

cat("\nDone.\n")
