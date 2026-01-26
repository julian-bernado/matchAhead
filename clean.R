# clean.R
# Remove all intermediate products and cached data
# Run with: Rscript clean.R

# Clear targets cache
print("Dumping targets..")
targets::tar_destroy()
print("Targets dumped")

# Clear output reports
print("Checking for output files to remove")
if (dir.exists("outputs")) {
  unlink("outputs", recursive = TRUE)
  print("Removed outputs")
} else {
  print("No outputs to remove, moving on.")
}

print("Clean complete")
