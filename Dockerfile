FROM nginx:latest

# Write hello world message
RUN echo "Hello World! nous sommes le groupe 3" > /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
