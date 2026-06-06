FROM nginx:latest
COPY website/index.html /usr/share/nginx/html/index.html
EXPOSE 80