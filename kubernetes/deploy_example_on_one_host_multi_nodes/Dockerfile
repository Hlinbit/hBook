FROM golang:1.19.1

# Step 2: Copy main.go to the Docker image
COPY main.go /app/

# Set the working directory
WORKDIR /app

RUN go mod init http_server && go mod tidy

# Step 3: Build the Go program
RUN go build -o main .

# Step 4: Set the startup command
CMD ["./main"]