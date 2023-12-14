project_id               = "rt11056905"
gcpregion                = "us-east4"
service_account_key_file = "tf.json"


account_id      = "bucket-creator"
display_name    = "Bucket Creator"
bucket_name     = "test-env-ore-terraform"
bucket_location = "us-east4"


pubsubtopicname       = "your-topic-name"
functionname          = "object-trigger"
objfunctionbucketname = "ores-object-create-function-bucket-clean"
objfunctionobject     = "object-create.zip"
schedulername         = "object-schedule"

httpfunctionsaaccountid = "httpfunctionsa"
httpfunctionname        = "http-function"
httpfunctionbucketname  = "ores-http-create-function-object"
httpfunctionobjectname  = "httpendpoint.zip"

email = "donore97@gmail.com"



