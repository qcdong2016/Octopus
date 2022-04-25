package main

import (
	"bytes"
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

func onPing(conn *WsConn, pkg *Package) error {
	return nil
}

func onLogin(conn *WsConn, pkg *Package) error {
	msg := &ReqLogin{}

	if err := pkg.Bind(msg); err != nil {
		return err
	}

	if u, err := dataMgr.Login(msg); err != nil {
		conn.Send("login", err, nil)
		return nil
	} else {
		conn.UserID = u.ID
		conn.SetAuthed()
		conn.Send("login", RespLogin{
			Me:      u,
			Friends: dataMgr.GetFriends(u.ID),
		}, nil)

		server.Add(conn.UserID, conn)
		server.BroadcastExcept("friendOnline", u, u.ID)
	}
	return nil
}

func onChatText(conn *WsConn, pkg *Package) error {
	msg := &ReqChatTextP2P{}
	if err := pkg.Bind(msg); err != nil {
		return err
	}

	msg.Type = "text"
	msg.From = conn.UserID

	to := server.Get(msg.To)
	if to != nil {
		to.Send("chat.text", msg, nil)
	}
	conn.Send(pkg.CB, msg, nil)

	return nil
}

func onChatImage(conn *WsConn, pkg *Package) error {
	req := &ReqChatImageP2P{}
	if err := pkg.Bind(req); err != nil {
		return err
	}

	relPath, err := saveFile(bytes.NewReader(pkg.Data), filepath.Ext(req.FileName))
	if err != nil {
		return err
	}

	msgFile := &FileMsg{
		Type:     "image",
		From:     conn.UserID,
		To:       req.To,
		FileName: req.FileName,
		URL:      relPath,
	}

	user := server.Get(req.To)
	if user != nil {
		user.Send("chat.file", msgFile, nil)
	}

	conn.Send(pkg.CB, msgFile, nil)

	return nil
}

func saveFile(reader io.Reader, ext string) (string, error) {
	var err error

	fileUUID := uuid.NewString()
	if err != nil {
		return "", err
	}

	relPath := filepath.Join("files", fileUUID+ext)
	absPath := filepath.Join(".", relPath)

	err = os.MkdirAll(filepath.Dir(absPath), os.ModePerm)
	if err != nil {
		return "", err
	}

	destFile, err := os.Create(absPath)
	if err != nil {
		return "", err
	}
	defer destFile.Close()

	dataMgr.AddFile(absPath)

	_, err = io.Copy(destFile, reader)
	if err != nil {
		return "", err
	}

	return relPath, nil
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

	relPath, err := saveFile(reader, filepath.Ext(formFile.Filename))
	if err != nil {
		return err
	}

	from := c.QueryParam("from")
	if from == "" {
		return errors.New("args error")
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

	msgType := c.QueryParam("type")
	if msgType == "" {
		msgType = "file"
	}

	msg := &FileMsg{
		Type:     msgType,
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
