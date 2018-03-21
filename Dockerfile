FROM nginx
MAINTAINER Hacklab <contato@hacklab.com.br>

ENV VIRTUAL_HOST="localhost"
ENV DOCUMENT_ROOT="/var/www/html"

ENV UPSTREAM="wordpress:9000"

ENV CACHE_PATH="/var/cache/nginx"
ENV CACHE_KEY="\$scheme://\$host\$request_uri"
ENV CACHE_IGNORE_COOKIE="comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in"
ENV CACHE_IGNORE_URI="/wp-admin"
ENV CACHE_VALID="200 60m"
ENV CACHE_USE_STALE="error timeout http_500 http_503"

ENV WP_UPLOADS_LOCATION="/wp-content/uploads"

RUN apt-get update \
    && apt-get install -y iproute2 \
    && userdel www-data \
    && groupmod --gid 33 nginx \
    && usermod --uid 33 --gid 33 nginx \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

VOLUME ["${DOCUMENT_ROOT}", "${CACHE_PATH}"]
COPY ["wp-nginx", "/wp-nginx"]
ENTRYPOINT ["/wp-nginx/entrypoint.sh"]
WORKDIR "${DOCUMENT_ROOT}"
CMD ["nginx", "-g", "daemon off;"]
