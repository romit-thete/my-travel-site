FROM nginx:alpine

RUN apk add --no-cache bash

COPY index.html /usr/share/nginx/html/index.template.html
COPY health.html /usr/share/nginx/html/health.html

CMD ["/bin/sh", "-c", "envsubst < /usr/share/nginx/html/index.template.html > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
