package main

import (
	"net"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
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

func (this *Server) OnRecv(conn *WsConn, buf []byte) error {

	pkg, err := NewPackage(conn.UserID, buf)
	if err != nil {
		return err
	}

	return dispatcher.Dispatch(conn, pkg)
}

func (this *Server) onNewConnection(w http.ResponseWriter, r *http.Request) error {

	conn, err := this.upgrader.Upgrade(w, r, nil)

	if err != nil {
		return err
	}

	connection := NewWsConn(conn, this)
	defer connection.Close()

	logs.Info("ws.from", "IP", connection.IP)

	this.waitGroup.Add(1)
	connection.Pump()

	if connection.UserID != 0 {
		this.Del(connection.UserID)
		dataMgr.Logout(connection.UserID)
		this.BroadcastExcept("friendOffline", connection.UserID, connection.UserID)
	}

	logs.Info("ws.close", "IP", connection.IP)
	this.waitGroup.Done()

	return nil
}

func (this *Server) Add(userid int64, conn *WsConn) {
	this.mutex.Lock()
	this.conns[userid] = conn
	this.mutex.Unlock()
}

func (this *Server) Del(userid int64) {
	this.mutex.Lock()
	delete(this.conns, userid)
	this.mutex.Unlock()
}

func (this *Server) Stop() {
	this.listener.Close()
	this.httpServer.Close()
	<-this.finished
	for _, conn := range this.conns {
		conn.Close()
	}
	this.waitGroup.Wait()
}

func (this *Server) Broadcast(route, msg interface{}, data []byte) {
	this.mutex.Lock()
	defer this.mutex.Unlock()

	for _, p := range this.conns {
		p.Send(route, msg, data)
	}
}

func (this *Server) BroadcastExcept(route, msg interface{}, except int64) {
	this.mutex.Lock()
	defer this.mutex.Unlock()

	for _, p := range this.conns {
		if p.UserID != except {
			p.Send(route, msg, nil)
		}
	}
}

func (this *Server) Get(UserID int64) *WsConn {
	this.mutex.Lock()
	defer this.mutex.Unlock()

	conn, ok := this.conns[UserID]
	if ok {
		return conn
	}
	return nil
}
