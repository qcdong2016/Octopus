package main

type User struct {
	ID       int    `db:"id"`
	Nickname string `db:"nickname"`
	Password string `db:"password"`
	Avatar   string `db:"avatar"`
	Online   bool   `db:"-"`
	Group    bool
}

type ReqLogin struct {
	ID       interface{}
	Password string
}

type RespLogin struct {
	Me      *User
	Friends []*User
}

type ReqChatTextP2P struct {
	Type    string
	Sender  int // 发送者
	From    int // 群id/发送者id
	To      int
	Content string
}

type ReqChatImageP2P struct {
	Type     string
	From     int
	To       int
	FileName string
}

type RespChatTextP2P struct {
	ReqChatTextP2P
}

type FileMsg struct {
	Type     string
	From     int
	To       int
	URL      string
	FileName string
}
