FROM golang:buster

WORKDIR /app
COPY . .
RUN go build -o /usr/local/bin/go-hpa

EXPOSE 8080
CMD ["/usr/local/bin/go-hpa"]