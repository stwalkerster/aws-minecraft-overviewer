# resource "aws_s3_bucket" "render-output" {
#   bucket = "stwalkerster-minecraft-maps"

#   tags = {
#     "Name" = "stwalkerster-minecraft-maps"
#   }

#   force_destroy = true
# }

# resource "aws_s3_bucket_website_configuration" "render-output" {
#   bucket = aws_s3_bucket.render-output.id

#   index_document {
#     suffix = "index.html"
#   }
# }

# resource "aws_s3_bucket_ownership_controls" "render_output" {
#   bucket = aws_s3_bucket.render-output.id

#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }

# resource "aws_s3_bucket_policy" "render_output" {
#   bucket = aws_s3_bucket.render-output.id
#   policy = jsonencode({
#     Version   = "2008-10-17"
#     Statement = [
#       {
#         Sid = "Public read"
#         Effect = "Allow"
#         Principal = "*"
#         Action = "s3:GetObject"
#         Resource = "arn:aws:s3:::${aws_s3_bucket.render-output.id}/*"
#       }
#     ]
#   })
# }


# resource "aws_cloudfront_distribution" "render_output" {
#   origin {
#     domain_name = aws_s3_bucket.render-output.bucket_regional_domain_name
#     # origin_access_control_id = aws_cloudfront_origin_access_control.default.id
#     origin_id = "s3"
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "Some comment"
#   default_root_object = "index.html"

#   #aliases = ["mysite.example.com", "yoursite.example.com"]

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "s3"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "allow-all"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # Cache behavior with precedence 0
#   ordered_cache_behavior {
#     path_pattern     = "/progress.json"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = "s3"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "allow-all"
#     min_ttl                = 0
#     default_ttl            = 0
#     max_ttl                = 0
#   }


#   price_class = "PriceClass_100"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#       locations        = []
#     }
#   }

#   tags = {
#     Name = "minecraft-overviewer"
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }
