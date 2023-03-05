package main

import (
	"Octopus/pb"
	"context"
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sync"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type ChatServer struct {
}

type msgHold struct {
	lock sync.Mutex
	mp   map[string]*pb.Msg
}

var hold = &msgHold{mp: make(map[string]*pb.Msg)}

func (s *msgHold) hold(msg *pb.Msg) {
	s.lock.Lock()
	defer s.lock.Unlock()

	s.mp[msg.ID] = msg

}

func (s *msgHold) done(id string) {
	s.lock.Lock()
	defer s.lock.Unlock()

	msg, ok := s.mp[id]
	if !ok {
		return
	}

	delete(s.mp, id)

	dataMgr.SendTo(msg.Sender, msg.To, "OnUpload",
		&pb.OnUploadReq{ID: msg.ID, From: msg.From})
}

func (s *ChatServer) Ping(context.Context, *pb.Empty) (*pb.Empty, error) {
	return &pb.Empty{}, nil
}

func (s *ChatServer) Send(ctx context.Context, req *pb.Msg) (*pb.Msg, error) {
	conn := GetConnFromCtx(ctx)

	req.Sender = conn.UserID
	req.ID = uuid.NewString()
	req.From = req.Sender
	if IsTeam(req.To) {
		req.From = req.To
	}

	dataMgr.SendTo(conn.UserID, req.To, "OnMsg", req)

	if req.GetFile() != nil || req.GetImage() != nil {
		hold.hold(req)
	}

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

	hold.done(id)

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
