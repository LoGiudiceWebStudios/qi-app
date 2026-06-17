package services

import (
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"

	"github.com/disintegration/imaging"
)

// CompressAndSaveImage ridimensiona e comprime un'immagine salvandola ad alta efficienza.
// Ritorna il percorso finale (che potrebbe avere l'estensione .jpg invece di quella originale) e un eventuale errore.
func CompressAndSaveImage(file *multipart.FileHeader, destPath string) (string, error) {
	// 1. Apriamo il file originario in memoria
	src, err := file.Open()
	if err != nil {
		return destPath, err
	}
	defer src.Close()

	// 2. Decodifichiamo l'immagine
	img, err := imaging.Decode(src)
	if err != nil {
		// Fallback: se il file non e' decodificabile da imaging, salviamo l'originale.
		// Questo evita che upload validi vengano scartati silenziosamente.
		srcFallback, openErr := file.Open()
		if openErr != nil {
			return destPath, err
		}
		defer srcFallback.Close()

		out, createErr := os.Create(destPath)
		if createErr != nil {
			return destPath, err
		}
		defer out.Close()

		if _, copyErr := io.Copy(out, srcFallback); copyErr != nil {
			return destPath, err
		}

		return destPath, nil
	}

	// 3. Ridimensioniamo l'immagine (massimo larghezza 1024px mantenendo le proporzioni)
	resizedImg := imaging.Resize(img, 1024, 0, imaging.Lanczos)

	// 4. Forziamo l'estensione a .jpg se non è .jpg/.jpeg
	ext := strings.ToLower(filepath.Ext(destPath))
	if ext != ".jpg" && ext != ".jpeg" {
		destPath = strings.TrimSuffix(destPath, ext) + ".jpg"
	}

	// 5. Salviamo l'immagine compressa (qualità passata a 75)
	err = imaging.Save(resizedImg, destPath, imaging.JPEGQuality(75))
	return destPath, err
}
