package main

import (
	"Octopus/pb"
	"math/rand"
	"net/http"
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

	e.GET("/chat", server.onNewConnection)
	e.POST("/upFile", handleUpFile, CrossOrigin)
	e.GET("/downFile", handleDownFile)

	e.POST("/api/Public/*", wrap[pb.PublicServer](&PublicServer{}))

	pb.RegisterChatServer(server.reg, &ChatServer{})

	e.Start(":7457")
}
