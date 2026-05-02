FROM nginx:alpine

RUN apk add --no-cache bash

COPY . /usr/share/nginx/html/

CMD ["/bin/sh", "-c", "envsubst < /usr/share/nginx/html/index.template.html > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
