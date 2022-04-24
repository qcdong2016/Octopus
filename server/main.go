package main

import (
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/google/uuid"
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

	fileUUID := uuid.NewString()
	if err != nil {
		return err
	}

	relPath := filepath.Join("files", from, fileUUID+filepath.Ext(formFile.Filename))
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

	msg := &FileMsg{
		Type:     "file",
		From:     fromUserId,
		To:       toUserId,
		FileName: formFile.Filename,
		URL:      relPath,
	}

	if user != nil {
		user.Send("chat.file", msg, nil)
	}

	return c.JSON(http.StatusOK, msg)
}

func handleDownFile(c echo.Context) error {
	file := c.QueryParam("file")
	return c.File(filepath.Join(".", file))
}
