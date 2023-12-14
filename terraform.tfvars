project_id               = "rt11056905"
gcpregion                = "us-east4"
service_account_key_file = "tf.json"


account_id      = "bucket-creator"
display_name    = "Bucket Creator"
bucket_name     = "test-env-ore-terraform"
bucket_location = "us-east4"
key_ring_name = "encrypt-bucket-ore6"  #make this unique
crypto_key_name = "crypto-key-ore6"   #make this unique


pubsubtopicname       = "your-topic-name"
functionname          = "object-trigger"
objfunctionbucketname = "ores-object-create-function-bucket-clean"    #make this unique
objfunctionobject     = "object-create.zip"
schedulername         = "object-schedule"

httpfunctionsaaccountid = "httpfunctionsa"
httpfunctionname        = "http-function"
httpfunctionbucketname  = "ores-http-create-function-object"     #make this unique
httpfunctionobjectname  = "httpendpoint.zip"

email = "donore97@gmail.com"    



