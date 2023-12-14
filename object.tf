//-----START HERE------//
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.9.0"
    }
  }
}

provider "google" {
  credentials = file(var.service_account_key_file)
  project     = var.project_id
  region      = var.gcpregion # Replace with your desired region

}

//-----------------------------------------------------------------------------------------------------------//
//CREATING BUCKET TO HOLD THE OBJECT

#Create Service Account for the buket creation
resource "google_service_account" "bucket_creator" {
  account_id   = var.account_id
  display_name = var.display_name
  description  = "Service account associated with creating the Bucket"
  project      = var.project_id

  depends_on = [
    google_project_service.enabled_apis,
  ]
}

# Bind Role to SA
resource "google_project_iam_member" "service_account_role_binding" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.bucket_creator.email}"
}

resource "google_project_iam_member" "kms_crypto_key_permission_cssa" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypter"
  member  = "serviceAccount:${google_service_account.bucket_creator.email}"
}

//permissions for cloud storage service account to encrypt the bucket
data "google_project" "project" {

}


resource "google_project_iam_member" "kms_crypto_key_permission" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}


#create CMEK Key
resource "google_kms_key_ring" "crypto_key_ring" {
  name     = var.key_ring_name
  location = var.gcpregion
}

resource "google_kms_crypto_key" "crypto_key" {
  name       = var.crypto_key_name
  key_ring   = google_kms_key_ring.crypto_key_ring.id
  purpose    = "ENCRYPT_DECRYPT"
  
}


resource "google_storage_bucket" "bucket" {
  depends_on = [ google_kms_crypto_key.crypto_key, google_project_iam_member.kms_crypto_key_permission ]
  name                        = var.bucket_name
  location                    = var.bucket_location
  uniform_bucket_level_access = true
  lifecycle_rule {
    condition {
      age = 10
    }
    action {
      type = "Delete"
    }
  }
  force_destroy = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.crypto_key.id
}
}

//Limititing the SA to bucket creation only and nothing else
resource "google_project_iam_binding" "bucket_creation_only" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  members = ["serviceAccount:${google_service_account.bucket_creator.email}"]
}

//-----------------------------------------------------------------------------------------------------------//
//CREATING OBJECT TO GET THE CURRENT TIMESTAMP


#creating the pubsub topic to trigger the function
resource "google_pubsub_topic" "topic" {
  name = var.pubsubtopicname
}

#creating the function for object creation
resource "google_cloudfunctions_function" "function" {
  depends_on            = [google_project_service.enabled_apis]
  name                  = var.functionname
  runtime               = "python39"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  entry_point           = "hello_pubsub"


  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.topic.name
  }

  available_memory_mb = 256
  timeout             = 300

  environment_variables = {
    "BUCKET_NAME" = google_storage_bucket.bucket.name
  }
}

resource "google_storage_bucket" "function_bucket" {
  name     = var.objfunctionbucketname
  location = var.gcpregion
}

resource "google_storage_bucket_object" "function_zip" {
  name   = var.objfunctionobject
  bucket = google_storage_bucket.function_bucket.name
  source = "object.zip"
}

#cloud scheduler to trigger the pubsub topic
resource "google_cloud_scheduler_job" "scheduler_job" {
  depends_on = [google_cloudfunctions_function.function]
  name       = var.schedulername
  project    = var.project_id
  schedule   = "*/10 * * * *"
  time_zone  = "UTC"

  pubsub_target {
    topic_name = google_pubsub_topic.topic.id
    data       = base64encode("terraform")
  }
}



//-----------------------------------------------------------------------------------------------------------//
//CREATING HTTP ENDPOINT

#service account for creating the function
resource "google_service_account" "http_function_sa" {
  account_id   = var.httpfunctionsaaccountid
  display_name = "HTTTP Function Service Account"

}

#role for sa
resource "google_project_iam_binding" "http_function_sa_role" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.http_function_sa.email}"]
}

#https function endpoint
resource "google_cloudfunctions_function" "http_function" {
  depends_on            = [google_cloud_scheduler_job.scheduler_job]
  name                  = var.httpfunctionname
  runtime               = "python39"
  source_archive_bucket = google_storage_bucket.function_bucket2.name
  source_archive_object = google_storage_bucket_object.function_zip2.name
  entry_point           = "get_last_object_content"
  trigger_http          = true
  available_memory_mb   = 256
  timeout               = 300
  service_account_email = google_service_account.http_function_sa.email
  environment_variables = google_cloudfunctions_function.function.environment_variables
}

#outputs the url to curl or access in the web browser
output "function_url" {
  value = google_cloudfunctions_function.http_function.https_trigger_url
}

#bucket to store the function code 
resource "google_storage_bucket" "function_bucket2" {
  name     = var.httpfunctionbucketname
  location = "us-east4" # Replace with your desired bucket location
}

#name of the function code (zip)
resource "google_storage_bucket_object" "function_zip2" {
  name   = var.httpfunctionobjectname
  bucket = google_storage_bucket.function_bucket2.name
  source = "httpendpoint.zip"
}

#public endpoint so allow unauthenticated users to access
resource "google_cloudfunctions_function_iam_member" "allow_unauthenticated" {
  depends_on     = [google_cloudfunctions_function.http_function]
  project        = var.project_id
  region         = var.gcpregion
  cloud_function = google_cloudfunctions_function.http_function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}


//-----------------------------------------------------------------------------------------------------------//
//CREATING ALARM WHEN RATE LIMIT IS EXCEEDED

#setting up a notification channel for alerts 
resource "google_monitoring_notification_channel" "email-me" {
  display_name = "Rate Limit Exceeded"
  type         = "email"
  labels = {
    email_address = var.email
  }
}

#setting up an alert policy in cloud monitoring to trigger the email when conditions are met
resource "google_monitoring_alert_policy" "alarm" {
  depends_on   = [google_cloudfunctions_function.http_function]
  display_name = "Alarm alert policy"
  combiner     = "OR"
  conditions {
    display_name = "Error condition"
    condition_matched_log {
      filter = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"http-function\" AND SEARCH(429)"
    }
  }
  notification_channels = [google_monitoring_notification_channel.email-me.name]
  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}