# Golang Load Test Service

This directory contains a simple Go (Golang) HTTP server for load testing purposes. You can use it to run two types of tests:

- **Normal Request Test:** Send regular HTTP requests to the endpoint to verify basic functionality and response.
- **Burst Load Test:** Simulate high traffic by sending a large number of requests in a short period to observe how the service handles load.

## Usage

1. Implement a basic HTTP server in Go (see example below).
2. Use tools like `curl`, `ab` (ApacheBench), or `hey` to send requests for normal and burst load tests.

## Example Go Server

```go
package main

import (
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, this is a load test endpoint!")
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8080", nil)
}
```

## Running Tests

- **Normal Request:**
  ```sh
  curl http://localhost:8080/
  ```
- **Burst Load Test:**
  ```sh
  hey -n 10000 -c 100 http://localhost:8080/
  # or
  ab -n 10000 -c 100 http://localhost:8080/
  ```

## Notes
- Keep the implementation simple for easy testing and modification.
- You can expand the server to add more endpoints or logging as needed.
