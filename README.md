# javascript spa app s3/cf/emberjs

>NOTE: for javascript apps that typically handle routing internally and serving out of s3 (static) you need CloudFront
in front of the bucket.  As well as some kind of way to route static paths back into the app routing.  This example (terraform) utilize the trick of redirecting 403/404 errors in CloudFront back into the index.html(containing the javascript) of the app.

### blocks
1. frontend application (spa-app)
   - ember framework
>NOTE: change this example app to be more generic with new API endpoint/DDB 

2. frontend infrastructure (frontend-infra-tf)
   - data.aws_caller_identity.current
   - data.aws_iam_policy_document.spa
   - aws_acm_certificate.spa
   - aws_acm_certificate_validation.spa
   - aws_cloudfront_cache_policy.spa
   - aws_cloudfront_cache_policy.spa-with-cors
   - aws_cloudfront_distribution.spa
   - aws_cloudfront_origin_access_identity.spa
   - aws_route53_record.spa
   - aws_route53_record.spa-certificate["*.spa-app.ls-al.com"]
   - aws_route53_record.spa-certificate["spa-app.ls-al.com"]
   - aws_route53_zone.spa
   - aws_s3_bucket.spa
   - aws_s3_bucket_cors_configuration.spa
   - aws_s3_bucket_policy.spa

3. backend infrastructure (backend-infra-tf)
   - api gateway endpoints
   - ddb tables


### TODO

I have not tried doing the rewrites with Lambda Edge which seems a possible better option than catching 404's.
- https://medium.com/@juniaporto/how-to-rewrite-requests-on-a-s3-cloudfront-website-e312a1cc9a78

Or instead of Lambda@Edge can CloudFront functions handle it?
- https://dev.to/aws-builders/use-aws-cloudfront-functions-for-uri-rewrites-587d
- https://github.com/aws-samples/amazon-cloudfront-functions/blob/main/url-rewrite-single-page-apps/README.md

Authentication
https://ember-simple-auth.com/
https://demo.ember-simple-auth.com/

### Terraform code used for my test
- https://chrisguitarguy.com/2023/05/17/hosting-a-single-page-application-in-aws/


### folder and cloned repo
/TANK/DATA/MyWorkDocs/iqonda/POC/spa-awsinfra-ember/frontend-infra-tf


    desktop01 ❯ …/MyWorkDocs/iqonda/POC/terraform-aws-spa 
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
    desktop01 ❯ …/MyWorkDocs/iqonda/POC/terraform-aws-spa took 15m23s 

### some manual things I did(supposed to work form terraform?)
- added CNAME validation records for new cert
- added DNS entry point to CF


### quick test
copy a little index.html to bucket

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


### copy an existing ember js app to this s3/cf stack
>NOTE: change this example app to be more generic with new API endpoint/DDB 

example pattern: 
    # npm run build

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

>NOTE: since I am already working on a SPA ember js app I just deployed it here also to test functionality

my app copy:
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


site: https://spa-app.ls-al.com