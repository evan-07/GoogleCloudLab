# Set variables to be used in the exercise
BUCKET_NAME=qwiklabs-gcp-02-b2f87995e756
PROJECT_NAME=my-project
STORAGE_CLASS=Standard
LOCATION=US-EAST1
OBJECT_NAME=ada.jpg




# Create Storage Bucket
gcloud storage buckets create gs://$BUCKET_NAME \
--project $PROJECT_NAME \
--default-storage-class $STORAGE_CLASS \
--location $LOCATION \
--uniform-bucket-level-access

#Upload object into bucket
curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output $OBJECT_NAME

gsutil cp $OBJECT_NAME gs://$BUCKET_NAME

# Remove downloaded image
rm $OBJECT_NAME

# List contents
gsutil ls gs://$BUCKET_NAME

# List details of an object
gsutil ls -l gs://$BUCKET_NAME/$OBJECT_NAME

# Download image from bucket
gsutil cp -r gs://$BUCKET_NAME/$OBJECT_NAME .

# Copy an object to a folder in the bucket
gsutil cp gs://$BUCKET_NAME/$OBJECT_NAME gs://$BUCKET_NAME/image-folder/

# Make object publicly accessible
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/$OBJECT_NAME

# Remove public access on an object
gsutil acl ch -d AllUsers gs://$BUCKET_NAME/$OBJECT_NAME

# Delete objects
gsutil rm gs://$BUCKET_NAME/$OBJECT_NAME






