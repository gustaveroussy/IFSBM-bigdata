#' Download Specific Files from a Public Google Drive Folder
#'
#' This function authenticates with Google Drive (using public access), fetches the
#' contents of a specified folder, and downloads a list of target files to a local
#' directory if they do not already exist.
#'
#' @param data_url A character string containing the URL or ID of the Google Drive folder.
#' @param output_dir A character string specifying the local directory where files
#'   should be saved. Defaults to `../data`.
#' @param files_to_sync A character vector listing the specific filenames to download.
#'
#' @return None. The function downloads files to the specified `output_dir` and
#'   prints messages to the console regarding the download status.
#'
#' @importFrom googledrive drive_deauth drive_ls as_id drive_download
#' @export
#'
#' @examples
#' \dontrun{
#' files <- c("tcga_tpm_cgc_genes.rds", "colors.csv")
#' url <- "https://drive.google.com/drive/folders/1vfL_a9Bk4rkp0tmnA3aK-ZLsBwqY65W8"
#'
#' DownloadFromGoogleDrive(
#'   data_url = url,
#'   output_dir = "my_data_folder",
#'   files_to_sync = files
#' )
#' }
DownloadFromGoogleDrive <- function(data_url, output_dir = "../data", files_to_sync) {

  # 1. Setup and Authentication
  # Use public access (no token required for public folders)
  googledrive::drive_deauth()

  # Ensure output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # 2. Get the list of ALL files in the Drive folder once
  message("Fetching folder contents from Google Drive...")

  # Wrap in tryCatch to handle invalid URLs gracefully
  drive_contents <- tryCatch({
    googledrive::drive_ls(path = googledrive::as_id(data_url))
  }, error = function(e) {
    stop("Failed to fetch Drive contents. Please check the 'data_url' and your internet connection.")
  })

  # 3. Iterate through list and download if missing locally
  for (filename in files_to_sync) {

    # Construct local path
    local_path <- file.path(output_dir, filename)

    if (!file.exists(local_path)) {
      message(paste("Local file missing. Searching for:", filename))

      # Find the specific file entry in the drive contents
      target_entry <- drive_contents[drive_contents$name == filename, ]

      if (nrow(target_entry) == 0) {
        warning(paste("File not found on Google Drive:", filename))
      } else {
        # Handle edge case: Google Drive allows multiple files with the same name
        if (nrow(target_entry) > 1) {
          warning(paste("Multiple files found for:", filename, "- downloading the first occurrence."))
          target_entry <- target_entry[1, ]
        }

        # Download using the ID found in the entry
        googledrive::drive_download(
          file = googledrive::as_id(target_entry$id),
          path = local_path,
          overwrite = TRUE
        )
      }

    } else {
      message(paste("File already exists locally:", filename))
    }
  }
}

