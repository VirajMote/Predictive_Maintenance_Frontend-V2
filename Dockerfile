FROM nginx:alpine

# Copy static files
COPY index.html   /usr/share/nginx/html/index.html
COPY machine.html /usr/share/nginx/html/machine.html
COPY alerts.html  /usr/share/nginx/html/alerts.html

# Copy nginx config — uses $PORT injected by Railway
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Railway injects PORT at runtime
ENV PORT=8080
EXPOSE $PORT

CMD ["nginx", "-g", "daemon off;"]
