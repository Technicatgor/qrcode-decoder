# Use an official Node.js runtime as a parent image
FROM oven/bun:1.2.2 AS build

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and bun.lock files
COPY package.json bun.lock ./

# Install dependencies using Bun
RUN bun install

# Copy the rest of the application code
COPY . .

# Build the Vue.js app using Bun
RUN bun run build

# Use a lightweight web server to serve the built files
FROM nginx:alpine

# Copy the built files from the build stage to the nginx html directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
