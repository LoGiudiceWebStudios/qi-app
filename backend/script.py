import sys
with open('internal/handlers/admin/menu.go', 'r') as f:
    content = f.read()
content = content.replace('price, _ := strconv.ParseFloat(priceStr, 64)\n\n\tvar imageURL string', 'price, _ := strconv.ParseFloat(priceStr, 64)\n\n\tvar imageURL string\n\tvar modelURL string\n\tfile3d, err3d := c.FormFile("modello_3d")\n\tif err3d == nil {\n\t\tos.MkdirAll("uploads/models3d", os.ModePerm)\n\t\tfilename3d := fmt.Sprintf("%d_%s", time.Now().Unix(), file3d.Filename)\n\t\tfilepath3d := fmt.Sprintf("uploads/models3d/%s", filename3d)\n\t\tif err := c.SaveUploadedFile(file3d, filepath3d); err == nil {\n\t\t\tmodelURL = "/" + filepath3d\n\t\t}\n\t}')
content = content.replace('Price:       price,\n\t\tImageURL:    imageURL,', 'Price:       price,\n\t\tImageURL:    imageURL,\n\t\tModel3dUrl:  modelURL,')
with open('internal/handlers/admin/menu.go', 'w') as f:
    f.write(content)
