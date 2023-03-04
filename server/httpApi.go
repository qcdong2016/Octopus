package main

import (
	"Octopus/pb"
	"context"
	"errors"
)

type PublicServer struct{}

func (PublicServer) Regist(ctx context.Context, req *pb.RegistReq) (*pb.Empty, error) {

	if req.Nickname == "" || req.Password == "" {
		return nil, errors.New("参数错误")
	}

	if req.Avatar == "" {
		req.Avatar = RandAvatar(req.Nickname)
	}

	_, err := dataMgr.Regist(req.Nickname, req.Password, req.Avatar)
	if err != nil {
		return nil, err
	}

	return &pb.Empty{}, nil
}
