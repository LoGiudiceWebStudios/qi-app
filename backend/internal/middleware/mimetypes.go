package middleware

import (
	"mime"
	"log"
)

func InitMimeTypes() {
	if err := mime.AddExtensionType(".glb", "model/gltf-binary"); err != nil {
		log.Println(err)
	}
	if err := mime.AddExtensionType(".gltf", "model/gltf+json"); err != nil {
		log.Println(err)
	}
	if err := mime.AddExtensionType(".usdz", "model/vnd.usdz+zip"); err != nil {
		log.Println(err)
	}
}
