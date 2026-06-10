- By using the dockerfile we will be creating a docker image. Docker daemon will use the instructions the Docker file and create the docker image.
- without base image we can't build the docker image.
- Assume we need to run nodejs application, for that we will create a base image (ubuntu) and install node on that. However instead of that we can directly use nodejs base image, which will have all the dependencies.

- using the `Run` command we can execute the commands.


```bash
# Use the official Node.js 20 Alpine Linux image as the base image
FROM node:20-alpine

# Set /app as the working directory inside the container
# Any subsequent commands will run from this directory
WORKDIR /app

# Copy package.json and package-lock.json (if present)
# This helps Docker cache the dependency installation layer
COPY package*.json .

# Install all dependencies mentioned in package.json
RUN npm install

# Copy the remaining application source code into the container
COPY . .

# Inform Docker that the application listens on port 3000
# This is mainly for documentation and does not actually publish the port
EXPOSE 3000

# Default command executed when the container starts
# Equivalent to running: node app.js
CMD ["node", "app.js"]
```
