# Use a Swift base image (choose the appropriate version)
FROM swift:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Swift server code from the host to the container
COPY . /app

# Build the Swift server
RUN swift build

# Expose the port the server will be listening on
EXPOSE 8888

# Run the Swift server
CMD ["swift", "run", "swiftyServer"]

