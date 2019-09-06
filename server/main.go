package main

import (
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

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
	e.GET("/downFile", handleDownFile)

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

	fileUUID, err := uuid.NewV4()
	if err != nil {
		return err
	}

	relPath := filepath.Join("files", from, fileUUID.String()+filepath.Ext(formFile.Filename))
	absPath := filepath.Join(".", relPath)

	err = os.MkdirAll(filepath.Dir(absPath), os.ModePerm)
	if err != nil {
		return err
	}

	destFile, err := os.Create(absPath)
	if err != nil {
		return err
	}
	defer destFile.Close()

	dataMgr.AddFile(absPath)

	_, err = io.Copy(destFile, reader)
	if err != nil {
		return err
	}

	toUserId, err := strconv.Atoi(c.QueryParam("to"))
	if err != nil {
		return err
	}
	fromUserId, err := strconv.Atoi(from)
	if err != nil {
		return err
	}

	user := server.Get(toUserId)
	if user != nil {
		user.Send("chat.file", &FileMsg{
			From:     fromUserId,
			To:       toUserId,
			FileName: formFile.Filename,
			URL:      relPath,
		}, nil)
	}

	return nil
}

func handleDownFile(c echo.Context) error {
	file := c.QueryParam("file")
	return c.File(filepath.Join(".", file))
}
