package main

import (
	"Octopus/pb"
	"math/rand"
	"net/http"
	"path/filepath"
	"time"

	"github.com/labstack/echo/v4"
)

var (
	server  *Server
	dataMgr *DataManager
)

func CrossOrigin(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		c.Response().Header().Add("Access-Control-Allow-Origin", "*")
		c.Response().Header().Add("Access-Control-Allow-Methods", "*")
		c.Response().Header().Add("Access-Control-Allow-Headers", "*")
		c.Response().Header().Add("Access-Control-Allow-Credentials", "true")

		if c.Request().Method == http.MethodOptions {
			return c.JSON(http.StatusOK, "ok")
		}

		return next(c)
	}
}

func wrap[T any](t T) echo.HandlerFunc {
	return GrpcHttpHandleFunc(t)
}

func main() {
	rand.Seed(time.Now().Unix())

	server = NewServer()
	dataMgr = NewDataManager()

	e := echo.New()

	e.Debug = true

	e.GET("/chat", handleChat)
	e.POST("/upFile", handleUpFile, CrossOrigin)
	e.GET("/downFile", handleDownFile)

	e.POST("/api/Public/*", wrap[pb.PublicServer](&PublicServer{}))

	dispatcher.Add("login", onLogin)
	dispatcher.Add("ping", onPing)
	dispatcher.Add("chat.text", onChatText)
	dispatcher.Add("chat.image", onChatImage)

	e.Start(":7457")
}

func handleChat(c echo.Context) error {

	return server.onNewConnection(c, c.Response(), c.Request())
}

func handleDownFile(c echo.Context) error {
	file := c.QueryParam("file")
	return c.File(filepath.Join(".", file))
}
