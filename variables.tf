variable "project_id" {
  description = "The ID of the GCP project"
}

variable "gcp_service_list" {
  type        = list(string)
  description = "The list of apis needed"
  default     = []
}

variable "gcpregion" {
  description = "The REGION of the GCP project"
}

variable "service_account_key_file" {
  description = "The path to the service account key file"
}


//BUCKET VARIABLES
variable "account_id" {
  description = "Service Account ID"
}

variable "display_name" {
  description = "The bucket display name"

}


variable "bucket_name" {
  description = "The name of the storage bucket"
}

variable "bucket_location" {
  description = "The location for the storage bucket"

}

//OBJECT CREATION VARIABLES
variable "pubsubtopicname" {
  description = "The pubsub topic name"

}
variable "functionname" {
  description = "The function name"

}
variable "objfunctionbucketname" {
  description = "The function bucket name"

}

variable "objfunctionobject" {
  description = "The function zip file name (must be in format [filename.zip])"

}

variable "schedulername" {
  description = "The cloud scheduler name"

}



//HTTP ENDPOINT VARIABLES
variable "httpfunctionsaaccountid" {
  description = "The function service account id"

}

variable "httpfunctionname" {
  description = "The function name"

}

variable "httpfunctionbucketname" {
  description = "The function bucket name"
}

variable "httpfunctionobjectname" {
  description = "The function zip file name (must be in format [filename.zip])"

}


//ALARM VARIABLES

variable "email" {
  description = "The email address for the notification"
}

