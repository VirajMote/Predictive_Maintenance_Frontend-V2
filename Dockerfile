FROM nginx:alpine

COPY index.html   /usr/share/nginx/html/index.html
COPY machine.html /usr/share/nginx/html/machine.html
COPY alerts.html  /usr/share/nginx/html/alerts.html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
