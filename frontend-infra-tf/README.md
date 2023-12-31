# Ember Javascript SPA app deploy to AWS Cloudfront and S3


- https://chrisguitarguy.com/2023/05/17/hosting-a-single-page-application-in-aws/


## AWS Infrastructure

### folder and cloned repo

root: /TANK/DATA/MyWorkDocs/iqonda/POC/spa-awsinfra-ember


infra (terraform): /TANK/DATA/MyWorkDocs/iqonda/POC/spa-awsinfra-ember/tf

❯❯ terraform apply
...
aws_route53_record.spa: Creating...
aws_route53_record.spa: Still creating... [10s elapsed]
aws_route53_record.spa: Still creating... [20s elapsed]
aws_route53_record.spa: Still creating... [30s elapsed]
aws_route53_record.spa: Still creating... [40s elapsed]
aws_route53_record.spa: Creation complete after 47s [id=Z08387472ACI9OYLRW9TF_spa-app.ls-al.com_A]

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

account_id = "660032875792"

### manual

- added CNAME validation records for new cert
- added DNS entry point to CF
- uploaded index.html to bucket

### quick test

❯❯ curl https://spa-app.ls-al.com
<!DOCTYPE html>
<html>
<head>
</head>
<body>

<h1>Heading</h1>
<p>fake home page ....</p>
</body>
</html>



## ember bare bones app



### copy existing ember js test to this s3/cf stack

npm run build
 
example: 
    # sync versioned asset files to s3
    aws s3 sync dist/assets/ s3://example-spa-app/assets/
    
    # copy the index.html with cache control, this would point to the versionsed assets
    aws s3 cp \
        --cache-control 'max-age=1800,must-revalidate' \
        dist/index.hml \
        s3://example-spa-app/index.html
    
    # create a cloudfront invalidation for index.html
    CLOUDFRONT_DISTRIBUTION="changeme: distribution ID from the infra above"
    aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_DISTRIBUTION" \
        --paths "/index.html"

real:

    desktop01 ❯ ~/ember-test/upmon-ember on  master 
    ❯❯ aws s3 sync dist/assets s3://poc-spa-app/assets/
    ...

    ❯❯ aws s3 cp --cache-control 'max-age=1800,must-revalidate' dist/index.html s3://poc-spa-app/index.html
    upload: dist/index.html to s3://poc-spa-app/index.html        

    ❯❯ aws cloudfront create-invalidation --distribution-id EQCPI2QYJB8YC --paths "/index.html"
    {
        "Location": "https://cloudfront.amazonaws.com/2020-05-31/distribution/EQCPI2QYJB8YC/invalidation/I2MLYZMPHIRMGO1UJZKF5E40D0",
        "Invalidation": {
            "Id": "I2MLYZMPHIRMGO1UJZKF5E40D0",
            "Status": "InProgress",
            "CreateTime": "2023-12-24T15:50:48.401000+00:00",
            "InvalidationBatch": {
                "Paths": {
                    "Quantity": 1,
                    "Items": [
                        "/index.html"
                    ]
                },
                "CallerReference": "cli-1703433048-991273"
            }
        }
    }


https://spa-app.ls-al.com

>since I am working on a SPA ember js app I just deployed here also to test functionality
 see:  /home/rrosso/ember-test/upmon-ember/deploy-s3.sh
