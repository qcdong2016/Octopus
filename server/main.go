package main

import (
	"net/http"

	"github.com/labstack/echo"
)

var (
	logger  *Logger
	server  *Server
	dataMgr *DataManager
)

func main() {
	logger = NewLogger()
	server = NewServer()
	dataMgr = NewDataManager()

	e := echo.New()

	e.Debug = true

	e.POST("/regist", handleRegist)
	e.GET("/chat", handleChat)

	dispatcher.Add("login", onLogin)
	dispatcher.Add("chat.text", onChatText)
	dispatcher.Add("chat.image", onChatImage)

	e.Start(":7456")
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

	u, err := dataMgr.Regist(arg.Nickname, arg.Password, arg.Avatar)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, u.ID)
}

func handleChat(c echo.Context) error {
	return server.onNewConnection(c.Response(), c.Request())
}
