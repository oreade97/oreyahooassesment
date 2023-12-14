//------APIS NEEDED----//

locals {
  all_project_services = concat(var.gcp_service_list, [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "cloudscheduler.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com",
    "cloudfunctions.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
}

resource "google_project_service" "enabled_apis" {
  project  = var.project_id
  for_each = toset(local.all_project_services)
  service  = each.key

  disable_on_destroy = false
}
