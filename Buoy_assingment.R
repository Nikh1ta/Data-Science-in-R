library(data.table)
library(lubridate)

# Function to read buoy data for a specific year
read_buoy_data <- function(year) {
  file_root <- "https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
  tail <- ".txt.gz&dir=data/historical/stdmet/"
  path <- paste0(file_root, year, tail)
  
  # Printing the current year being processed
  print(paste("Processing year:", year))
  
  # Determining how many lines to skip based on the year
  if (year >= 2007) {
    header <- scan(path, what = 'character', nlines = 1)
    buoy <- fread(path, header = FALSE, skip = 2, fill = Inf)  # Changed fill to Inf
  } else {
    header <- scan(path, what = 'character', nlines = 1)
    buoy <- fread(path, header = FALSE, skip = 1, fill = Inf)  # Changed fill to Inf
  }
  
  # Dynamically handle column count mismatches
  if (length(header) != ncol(buoy)) {
    warning(paste("Mismatch in column count for year", year, "- adjusting columns"))
    
    # Adding placeholder names for extra columns if present
    if (ncol(buoy) > length(header)) {
      colnames(buoy) <- c(header, paste0("Extra_", seq_len(ncol(buoy) - length(header))))
    } else {
      # Truncating the header if there are fewer columns
      colnames(buoy) <- header[1:ncol(buoy)]
    }
  } else {
    colnames(buoy) <- header
  }
  
  # Creating a proper date column using lubridate
  buoy$date <- make_date(buoy$YYYY, buoy$MM, buoy$DD)
  
  return(buoy)
}

# Defining the years I want to read data for
years <- 1985:2023

# Reading and combining data for all years
all_buoy_data <- rbindlist(lapply(years, read_buoy_data), fill = TRUE)

# Saving the combined data to a file
fwrite(all_buoy_data, "all_buoy_data.csv")

# Printing a sample of the combined data
print(head(all_buoy_data))
