package main

import "fmt"

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
	fmt.Println("login", msg.ID)
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
	msg := &ReqChatImageP2P{}
	if err := pkg.Bind(msg); err != nil {
		return err
	}

	msg.From = conn.UserID
	msg.Type = "image"

	to := server.Get(msg.To)
	if to != nil {
		to.Send("chat.image", msg, pkg.Data)
	}
	conn.Send(pkg.CB, msg, nil)

	return nil
}
