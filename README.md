### Yahoo Cloud Enablement Engineer Exercise 

**Quick Description**

These files deploy a set of resources on Google Cloud Platform to create, manage, and monitor cloud resources. The deployment includes the following components:
1. Cloud Storage Bucket

    Creates a Google Cloud Storage bucket to hold objects.
    A dedicated service account is created with minimal permissions for bucket creation.

2. Object Creation Cloud Function

    Creates a Cloud Function triggered by a Pub/Sub topic.
    The Cloud Function generates an object with the current timestamp in the specified Cloud Storage bucket.
    The Cloud Function is scheduled using Cloud Scheduler to trigger the Pub/Sub topic every 10 minutes.

3. HTTP Endpoint Cloud Function

    Creates another Cloud Function with an HTTP trigger.
    The function retrieves the contents of the most recent object in the specified Cloud Storage bucket.
    The Cloud Function is configured to be publicly accessible without authentication.

4. Alarm for Rate Limit Exceeded

    Sets up a notification channel for sending email alerts when rate limits are exceeded.
    Defines an alert policy in Cloud Monitoring to trigger an email when the specified conditions are met.



**Dependencies**

Before running the provided Terraform configuration, ensure that you have the following installed:

    Terraform:
        Download and install Terraform from the official website: Terraform Downloads
        Make sure the terraform binary is available in your system's PATH.

    Google Cloud SDK (gcloud):
        Install the Google Cloud SDK to interact with Google Cloud Platform services: Google Cloud SDK Installation
        Make sure the gcloud command is available in your system's PATH.

    Google Cloud Project:
        Create a Google Cloud Platform (GCP) project and set up billing: Create a project

    Service Account JSON Key File:
        Create a service account with "Editor" permissions and download the JSON key file. This key file will be used for authentication.
        Set the contents of the JSON file in the "tf.json" file included in the repository

    Google Cloud Functions Runtime Dependencies:
        Ensure that the Python 3.9 runtime is available on your system if you are using the Python 3.9 runtime for Cloud Functions.

After installing these dependencies, you should be able to run the Terraform commands to deploy the infrastructure. Make sure to replace placeholder values in the "terraform.tfvars" file with your actual values. **Please make sure the bucket names are unique or the terraform deployment will fail.**


**Deploying the Cloud resources**

- Clone the Repository by running 

    ```git clone https://github.com/oreade97/oreyahooassesment.git```

-Navigate to the Repository Directory

-Initialize Terraform and Run:


    terraform init

    terraform plan
    
    terraform apply
  
- Wait for Resources to Be Provisioned

- Link to HTTP Endpoint will be printed in terminal or Access Outputs (Optional) by running
  
```terraform output```


**TearDown Instructions**
- Run 
```terraform destroy```


**To disable the cloud apis as well, after deleteing the cloud resources, remove the "disable_on_destroy = false" attribute and run terraform destroy again** We cannot currenlty control the order that cloud resources are destroyed in terraform, and the apis are needed to delete the resources.

The cloud scheduler runs every 10 minutes. It will take 10 minutes before the first object is created in the bucket.

