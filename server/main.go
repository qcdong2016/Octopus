package main

import (
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/labstack/echo"
	uuid "github.com/satori/go.uuid"
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
	e.POST("/upFile", handleUpFile)

	dispatcher.Add("login", onLogin)
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

	u, err := dataMgr.Regist(arg.Nickname, arg.Password, arg.Avatar)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, u.ID)
}

func handleChat(c echo.Context) error {
	return server.onNewConnection(c.Response(), c.Request())
}

func handleUpFile(c echo.Context) error {
	fmt.Println("handleupfile")
	formFile, err := c.FormFile("file")
	if err != nil {
		return err
	}

	reader, err := formFile.Open()
	if err != nil {
		return err
	}

	from := c.QueryParam("from")
	if from == "" {
		return errors.New("args error")
	}

	destPath := "./files/" + from

	err = os.MkdirAll(destPath, os.ModePerm)
	if err != nil {
		return err
	}

	fileUUID, err := uuid.NewV4()
	if err != nil {
		return err
	}

	destPath = filepath.Join(destPath, fileUUID.String()+filepath.Ext(formFile.Filename))

	destFile, err := os.Create(destPath)
	if err != nil {
		return err
	}
	defer destFile.Close()

	_, err = io.Copy(destFile, reader)
	if err != nil {
		return err
	}

	return nil
}
