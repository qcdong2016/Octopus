package main

import (
	"Octopus/pb"
	"context"
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type ChatServer struct{}

func (ChatServer) Ping(context.Context, *pb.Empty) (*pb.Empty, error) {
	return &pb.Empty{}, nil
}

func (ChatServer) Send(ctx context.Context, req *pb.Msg) (*pb.Msg, error) {
	conn := GetConnFromCtx(ctx)

	req.Sender = conn.UserID
	req.ID = uuid.NewString()

	dataMgr.SendTo(conn.UserID, req.To, "OnMsg", req)

	return req, nil
}

func handleDownFile(c echo.Context) error {
	file := c.QueryParam("file")
	absPath := filepath.Join("./files", file)
	return c.File(absPath)
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

	id := c.QueryParam("id")
	if id == "" {
		return errors.New("args error")
	}

	err = saveFile(reader, id, filepath.Ext(formFile.Filename))
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, map[string]any{})
}

func saveFile(reader io.Reader, id, ext string) error {
	var err error

	absPath := filepath.Join("./files", id+ext)

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

	return nil
}
