package main

import (
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			// 读取配置文件
			configData, err := ioutil.ReadFile("/config/config.json")
			if err != nil {
				http.Error(w, "Error reading config file", http.StatusInternalServerError)
				return
			}

			// 将配置文件的内容写入响应中
			w.Header().Set("Content-Type", "application/json")
			w.Write(configData)
		} else {
			http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		}
	})

	log.Println("Server starting on port 8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
