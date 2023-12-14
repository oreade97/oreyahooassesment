project_id               = "host-project-405420"
gcpregion                = "us-east4"
service_account_key_file = "tf.json"


account_id      = "bucket-creator"
display_name    = "Bucket Creator"
bucket_name     = "xxxx-bucket" #make this unique
bucket_location = "us-east4"
key_ring_name = "encrypt-bucket-xxxx"  #make this unique
crypto_key_name = "crypto-key-xxxx"   #make this unique


pubsubtopicname       = "your-topic-name"
functionname          = "object-trigger"
objfunctionbucketname = "xxxx-object-create-function-bucket-clean"    #make this unique
objfunctionobject     = "object-create.zip"
schedulername         = "object-schedule"

httpfunctionsaaccountid = "httpfunctionsa"
httpfunctionname        = "http-function"
httpfunctionbucketname  = "xxxx-http-create-function-object"     #make this unique
httpfunctionobjectname  = "httpendpoint.zip"

email = "enter email address here"    



