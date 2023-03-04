package main

import (
	"Octopus/pb"
	"time"
)

// docs

type File struct {
	Path string
	Date time.Time
}

type User struct {
	Id       int64
	Nickname string
	Password string
	Avatar   string
}

type Team struct {
	Id       int64
	Owner    int64
	Nickname string
	Avatar   string
}

type TeamMember struct {
	Team int64
	User int64
}

var all_docs = []interface{}{
	&User{},
	&File{},
	&Team{},
	&TeamMember{},
}

var user_id_range = []int64{10000, 99999}
var team_id_range = []int64{1000000, 9999999}
var default_team_id = int64(1000000)

// msgs

func (u *User) ToFriend() *pb.Friend {
	return &pb.Friend{
		ID:       u.Id,
		Nickname: u.Nickname,
		Avatar:   u.Avatar,
	}
}

func (u *Team) ToFriend() *pb.Friend {
	return &pb.Friend{
		ID:       u.Id,
		Nickname: u.Nickname,
		Avatar:   u.Avatar,
		Group:    true,
	}
}
