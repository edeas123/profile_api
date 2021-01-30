locals {
  source_code_dir = "../../profile"
}

data "archive_file" "record_visit" {
  type        = "zip"
  source_dir = local.source_code_dir
  output_path = ".archive/record_visit.zip"
}
