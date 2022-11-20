git clone https://github.com/terraform-google-modules/terraform-google-network
cd terraform-google-network
git checkout tags/v3.3.0 -b v3.3.0


### Retrieve Project ID
export projectid=$(gcloud config list --format 'value(core.project)')
export bucketname="${projectid}-bucket"

### Download html files
cd ~
curl https://raw.githubusercontent.com/hashicorp/learn-terraform-modules/master/modules/aws-s3-static-website-bucket/www/index.html > index.html
curl https://raw.githubusercontent.com/hashicorp/learn-terraform-modules/blob/master/modules/aws-s3-static-website-bucket/www/error.html > error.html

### Copy html files to storage bucket
gsutil cp *.html gs://${bucketname}