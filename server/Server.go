package main

import (
	"Octopus/pb"
	"net"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/labstack/echo/v4"
	"github.com/qcdong2016/logs"
)

type MsgHandler interface {
	OnRecv(conn *WsConn, msg []byte) error
}

type Server struct {
	listener   net.Listener
	httpServer *http.Server
	upgrader   *websocket.Upgrader
	finished   chan struct{}
	waitGroup  *sync.WaitGroup
	mutex      sync.Mutex
	conns      map[int64]*WsConn
}

func NewServer() *Server {
	svr := &Server{
		finished:  make(chan struct{}, 1),
		waitGroup: &sync.WaitGroup{},
		conns:     make(map[int64]*WsConn),
		upgrader: &websocket.Upgrader{
			CheckOrigin: func(_ *http.Request) bool { return true },
		},
	}

	return svr
}

func (s *Server) OnRecv(conn *WsConn, buf []byte) error {

	pkg, err := NewPackage(conn.UserID, buf)
	if err != nil {
		return err
	}

	return dispatcher.Dispatch(conn, pkg)
}

func (s *Server) onNewConnection(c echo.Context, w http.ResponseWriter, r *http.Request) error {

	conn, err := s.upgrader.Upgrade(w, r, nil)

	if err != nil {
		return err
	}

	u := c.QueryParam("u")
	p := c.QueryParam("p")

	connection := NewWsConn(conn, s)
	defer connection.Close()

	logs.Info("ws.from", "IP", conn.RemoteAddr().String())
	if user, err := dataMgr.Login(u, p); err == nil {

		connection.SetAuthed()
		connection.UserID = user.ID

		connection.Send("Login", &pb.OnLogin{
			Me:      user,
			Friends: dataMgr.GetFriends(user.ID),
		})

		s.Del(connection.UserID)
		dataMgr.Logout(connection.UserID)
		s.BroadcastExcept("friendOffline", connection.UserID, connection.UserID)

		s.waitGroup.Add(1)
		connection.Pump()

		logs.Info("ws.close", "IP", connection.IP)
		s.waitGroup.Done()

	} else {
		connection.SendNow("Login", &pb.OnLogin{
			Msg: err.Error(),
		})
	}

	return nil
}

func (s *Server) Add(userid int64, conn *WsConn) {
	s.mutex.Lock()
	s.conns[userid] = conn
	s.mutex.Unlock()
}

func (s *Server) Del(userid int64) {
	s.mutex.Lock()
	delete(s.conns, userid)
	s.mutex.Unlock()
}

func (s *Server) Stop() {
	s.listener.Close()
	s.httpServer.Close()
	<-s.finished
	for _, conn := range s.conns {
		conn.Close()
	}
	s.waitGroup.Wait()
}

func (s *Server) Broadcast(route, msg any) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	for _, p := range s.conns {
		p.Send(route, msg)
	}
}

func (s *Server) BroadcastExcept(route, msg interface{}, except int64) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	for _, p := range s.conns {
		if p.UserID != except {
			p.Send(route, msg)
		}
	}
}

func (s *Server) Get(UserID int64) *WsConn {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	conn, ok := s.conns[UserID]
	if ok {
		return conn
	}
	return nil
}
