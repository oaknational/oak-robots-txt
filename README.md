# oak-robots-txt

## Overview
This repository hosts `robots.txt` that is used as the target for Cloudflare redirects for subdomains we cannot modify at origin. Some of our subdomains are hosted by third-party services (like Mux) where we don't have access to modify files at the origin, so we can't add a robots.txt file directly. Without a robots.txt, all bots are allowed by default.

## How It Works
Bot request: `https://<subdomain>.thenational.academy/robots.txt` -> Cloudflare origin rule proxies the request -> Cloudflare fetches content from: `https://robots.thenational.academy/robots.txt` -> Bot receives `robots.txt` content directly at: `https://<subdomain>.thenational.academy/robots.txt`

## Implementation
Proxy `robots.txt` requests using Cloudflare Origin Rules. Configure Cloudflare to serve the central robots.txt content directly from subdomain requests:

```
resource "cloudflare_ruleset" "http_request_origin" {
  zone_id     = data.cloudflare_zone.thenational.id
  name        = "default"
  description = ""
  kind        = "zone"
  phase       = "http_request_origin"

  rules {
    action = "route"

    action_parameters {
      host_header = "robots.thenational.academy"
      origin {
        host = "robots.thenational.academy"
        port = 443
      }
    }

    expression  = "(http.host eq \"<subdomain>.thenational.academy\") and (http.request.uri.path eq \"/robots.txt\")"
    description = "Route to Robots.txt"
    enabled     = true
  }
}
```

## Test
Verify the redirect is working correctly:

Test the redirect response: `curl -I https://<subdomain>.thenational.academy/robots.txt`

This should return:
``` 
HTTP/2 200
```

[What is Robots.txt?](https://www.cloudflare.com/en-gb/learning/bots/what-is-robots-txt/)