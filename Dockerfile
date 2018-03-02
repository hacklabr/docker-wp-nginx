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

VOLUME ["${DOCUMENT_ROOT}", "${CACHE_PATH}"]
COPY ["entrypoint.sh", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
