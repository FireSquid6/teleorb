package main

import (
  "net/http"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/chi/v5"
)



func main() {
  r := chi.NewRouter()
  r.Use(middleware.Logger)
  r.Get("/", func(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Gatekeper is online"))
  })

  http.ListenAndServe(":3100", r)

}
