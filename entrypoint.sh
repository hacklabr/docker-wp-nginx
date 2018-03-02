#!/bin/bash

export RESOLVER="${RESOLVER:-$(awk '/^nameserver/{ print $2; exit; }' /etc/resolv.conf)}"

cat > /etc/nginx/conf.d/default.conf << EOF
fastcgi_cache_path $CACHE_PATH levels=1:2 keys_zone=php_cache:100m inactive=1d;
fastcgi_cache_key "$CACHE_KEY";
resolver $RESOLVER;

server {
    listen 80;

    root $DOCUMENT_ROOT;
    index index.php index.html;

    set \$no_cache 0;
    if (\$request_uri ~* "$CACHE_IGNORE_URI") {
        set \$no_cache 1;
    }

    if (\$http_cookie ~* "$CACHE_IGNORE_COOKIE")  {
        set \$no_cache 1;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        return 200 "User-agent: *\nDisallow: /wp-admin";
    }

    location ^~ /xmlrpc.php {
        deny all;
    }

    location ^~ $WP_UPLOADS_LOCATION {
        expires max;
    }

    location ^~ /status/ {
        stub_status on;
        allow 127.0.0.1;
        deny all;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include fastcgi_params;

        fastcgi_pass_header "X-Accel-Redirect";
        fastcgi_pass_header "X-Accel-Expires";

        ##
        ## Sometime you need to force
        ##
        #fastcgi_hide_header "Set-Cookie";
        #fastcgi_ignore_headers "Cache-Control" "Expires" "Set-Cookie";

        fastcgi_cache php_cache;
        fastcgi_cache_valid $CACHE_VALID;
        fastcgi_cache_bypass \$no_cache;
        fastcgi_no_cache \$no_cache;
        fastcgi_cache_use_stale $CACHE_USE_STALE;
        add_header X-Cache \$upstream_cache_status;

        set \$wp_upstream "$UPSTREAM";
        fastcgi_pass \$wp_upstream;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found on;
    }
}
EOF

echo "$@"
exec "$@"
