package middleware

import (
"fmt"
"net/http"
"strings"
"log"

"github.com/gin-gonic/gin"
"github.com/golang-jwt/jwt/v5"
"os"

"qi-backend/internal/database"
"qi-backend/internal/models"
)


func getJWTSecret() []byte {
    secret := os.Getenv("JWT_SECRET")
    if secret == "" {
        secret = "my_super_secret_key_change_me"
    }
    return []byte(secret)
}

func JWTAuth() gin.HandlerFunc {
return func(c *gin.Context) {
authHeader := c.GetHeader("Authorization")
if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
c.JSON(http.StatusUnauthorized, gin.H{"error": "Token mancante o non valido"})
c.Abort()
return
}

tokenString := strings.TrimPrefix(authHeader, "Bearer ")

token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
return nil, fmt.Errorf("metodo di firma inatteso: %v", token.Header["alg"])
}
return getJWTSecret(), nil
})

if err != nil || !token.Valid {
c.JSON(http.StatusUnauthorized, gin.H{"error": "Token scaduto o non valido"})
c.Abort()
return
}

if claims, ok := token.Claims.(jwt.MapClaims); ok {
c.Set("user_id", claims["sub"])
}

c.Next()
}
}

func AdminAuthCookie() gin.HandlerFunc {
return func(c *gin.Context) {
tokenString, err := c.Cookie("admin_token")
if err != nil || tokenString == "" {
log.Println("AdminAuthCookie Fail: cookie missing or empty:", err)
c.Redirect(http.StatusSeeOther, "/admin/login")
c.Abort()
return
}

token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
return getJWTSecret(), nil
})

if err != nil || !token.Valid {
log.Println("AdminAuthCookie Fail: token invalid:", err)
c.Redirect(http.StatusSeeOther, "/admin/login")
c.Abort()
return
}

var userId float64
if claims, ok := token.Claims.(jwt.MapClaims); ok {
userId = claims["sub"].(float64)
c.Set("user_id", userId)
} else {
log.Println("AdminAuthCookie Fail: sub not float64")
c.Redirect(http.StatusSeeOther, "/admin/login")
c.Abort()
return
}

var user models.User
if err := database.DB.First(&user, uint(userId)).Error; err != nil {
log.Println("AdminAuthCookie Fail: user not found:", err)
c.Redirect(http.StatusSeeOther, "/admin/login")
c.Abort()
return
}

if user.Ruolo != "admin" {
log.Println("AdminAuthCookie Fail: not admin, role is:", user.Ruolo)
c.HTML(http.StatusForbidden, "login.html", gin.H{"Error": "Accesso negato: richiesto ruolo admin"})
c.Abort()
return
}

c.Set("user_role", user.Ruolo)
c.Next()
}
}
