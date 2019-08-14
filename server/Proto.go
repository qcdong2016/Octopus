package main

type User struct {
	ID       int    `db:"id"`
	Nickname string `db:"nickname"`
	Password string `db:"password"`
	Avatar   string `db:"avatar"`
	Online   bool   `db:"-"`
}

type Group struct {
	ID       int
	Nickname string
	Owner    int
	Members  []int

	ownerUser  *User
	memberUser []*User
}

type ReqLogin struct {
	ID       int
	Password string
}

type RespLogin struct {
	Me      *User
	Friends []*User
}

type ReqChatTextP2P struct {
	Type    string
	From    int
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
