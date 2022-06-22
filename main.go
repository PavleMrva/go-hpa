package main

import (
	"fmt"
	"math"
	"net/http"
)

func calculate(w http.ResponseWriter, r *http.Request) {
	go func() {
		x := 0.0001
		for i := 1; i <= 1000000; i++ {
			x += math.Sqrt(x)
		}
		fmt.Println("[calculation] finished successfully")
	}()

	fmt.Println("[calculation] starting calculation")
	w.WriteHeader(http.StatusAccepted)
}

func main() {
	fmt.Println("Starting server...")
	http.HandleFunc("/", calculate)
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}
