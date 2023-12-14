//------APIS NEEDED----//

resource "google_project_service" "gcp_resource_manager_api" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

locals {
  all_project_services = concat(var.gcp_service_list, [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "cloudscheduler.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com",
    "cloudfunctions.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com"
  ])
}

resource "google_project_service" "enabled_apis" {
  depends_on = [ google_project_service.gcp_resource_manager_api ]
  project  = var.project_id
  for_each = toset(local.all_project_services)
  service  = each.key

  disable_on_destroy = false
}
