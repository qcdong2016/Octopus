package main

import (
	"errors"
	"math/rand"
	"net/http"
	"path/filepath"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/qcdong2016/logs"
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

func main() {
	rand.Seed(time.Now().Unix())

	server = NewServer()
	dataMgr = NewDataManager()

	e := echo.New()

	e.Debug = true

	e.Any("/regist", handleRegist, CrossOrigin)
	e.GET("/chat", handleChat)
	e.POST("/upFile", handleUpFile, CrossOrigin)
	e.GET("/downFile", handleDownFile)

	dispatcher.Add("login", onLogin)
	dispatcher.Add("ping", onPing)
	dispatcher.Add("chat.text", onChatText)
	dispatcher.Add("chat.image", onChatImage)

	e.Start(":7457")
}

func handleRegist(c echo.Context) error {

	arg := struct {
		Nickname string
		Password string
		Avatar   string
	}{}

	if err := c.Bind(&arg); err != nil {
		return err
	}

	if arg.Nickname == "" || arg.Password == "" {
		return errors.New("empty")
	}

	if arg.Avatar == "" {
		arg.Avatar = RandAvatar(arg.Nickname)
	}

	logs.Info("regist", arg)

	u, err := dataMgr.Regist(arg.Nickname, arg.Password, arg.Avatar)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, u.Id)
}

func handleChat(c echo.Context) error {
	return server.onNewConnection(c.Response(), c.Request())
}

func handleDownFile(c echo.Context) error {
	file := c.QueryParam("file")
	return c.File(filepath.Join(".", file))
}
