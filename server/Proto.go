package main

import "time"

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

type Friend struct {
	ID       int64
	Nickname string
	Avatar   string
	Online   bool
	Password string
	Group    bool
}

func (u *User) ToFriend() *Friend {
	return &Friend{
		ID:       u.Id,
		Nickname: u.Nickname,
		Avatar:   u.Avatar,
	}
}

func (u *Team) ToFriend() *Friend {
	return &Friend{
		ID:       u.Id,
		Nickname: u.Nickname,
		Avatar:   u.Avatar,
		Group:    true,
	}
}

type ReqLogin struct {
	ID       interface{}
	Password string
}

type RespLogin struct {
	Me      *Friend
	Friends []*Friend
}

type ReqChatTextP2P struct {
	Type    string
	Sender  int64 // 发送者
	From    int64 // 群id/发送者id
	To      int64
	Content string
}

type ReqChatImageP2P struct {
	Type     string
	Sender   int64 // 发送者
	From     int64
	To       int64
	FileName string
}

type RespChatTextP2P struct {
	ReqChatTextP2P
}

type FileMsg struct {
	Type     string
	Sender   int64 // 发送者
	From     int64
	To       int64
	URL      string
	FileName string
}
