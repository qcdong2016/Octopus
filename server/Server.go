package main

import (
	"Octopus/pb"
	"context"
	"net"
	"net/http"
	"sync"

	"github.com/golang/protobuf/proto"
	"github.com/gorilla/websocket"
	"github.com/labstack/echo/v4"
	"github.com/qcdong2016/logs"
	"google.golang.org/grpc"
)

type MsgHandler interface {
	OnRecv(conn *WsConn, msg []byte) error
}

type DescAndImpl struct {
	Desc *grpc.ServiceDesc
	Impl any
}

type Server struct {
	listener   net.Listener
	httpServer *http.Server
	upgrader   *websocket.Upgrader
	finished   chan struct{}
	waitGroup  *sync.WaitGroup
	mutex      sync.Mutex
	conns      map[int64]*WsConn

	reg *ServiceReg
}

func NewServer() *Server {
	svr := &Server{
		finished:  make(chan struct{}, 1),
		waitGroup: &sync.WaitGroup{},
		conns:     make(map[int64]*WsConn),
		upgrader: &websocket.Upgrader{
			CheckOrigin: func(_ *http.Request) bool { return true },
		},
		reg: NewServiceReg(),
	}

	return svr
}

var __key = struct{}{}

func GetConnFromCtx(ctx context.Context) *WsConn {
	return ctx.Value(__key).(*WsConn)
}

func (s *Server) OnRecv(conn *WsConn, buf []byte) error {
	pkg := pb.C2SData{}

	err := proto.Unmarshal(buf, &pkg)
	if err != nil {
		return err
	}

	service, method := s.reg.GetDesc(pkg.Method)

	df := func(v interface{}) error {
		return proto.Unmarshal(pkg.Body, v.(proto.Message))
	}

	ctx := context.WithValue(context.TODO(), __key, conn)

	resp, err := method.Handler(service.Impl, ctx, df, nil)
	if err != nil {
		return err
	}

	return conn.Send(pkg.Callback, resp)
}

func (s *Server) onNewConnection(c echo.Context) error {

	conn, err := s.upgrader.Upgrade(c.Response().Writer, c.Request(), nil)

	if err != nil {
		return err
	}

	var arg struct {
		Username    string `query:"u"`
		Password    string `query:"p"`
		IsReconnect bool   `query:"r"`
	}
	if err := c.Bind(&arg); err != nil {
		return err
	}

	connection := NewWsConn(conn, s)
	defer connection.Close()

	logs.Info("ws.from", c.QueryString())
	if user, err := dataMgr.Login(arg.Username, arg.Password); err == nil {

		connection.SetAuthed()
		connection.UserID = user.ID

		connection.Send("Login", &pb.OnLogin{
			Me:        user,
			Friends:   dataMgr.GetFriends(user.ID),
			Reconnect: arg.IsReconnect,
		})

		old := s.Del(connection.UserID, nil)

		if old != nil {
			old.SendNow("Kick", &pb.KickReq{
				Msg: "重复登录",
			})
		}

		user.Online = true

		s.BroadcastExcept("Online", &pb.OnlineReq{Who: user}, connection.UserID)

		s.Add(connection.UserID, connection)
		connection.Pump()
		s.Del(connection.UserID, connection)

		s.BroadcastExcept("Offline", &pb.OfflineReq{ID: user.ID}, user.ID)

		logs.Info("ws.close", user.ID)

	} else {
		connection.SendNow("Login", &pb.OnLogin{
			Msg:       err.Error(),
			Reconnect: arg.IsReconnect,
		})
	}

	return nil
}

func (s *Server) Add(userid int64, conn *WsConn) {
	s.mutex.Lock()
	s.conns[userid] = conn
	s.mutex.Unlock()
}

func (s *Server) Del(userid int64, conn *WsConn) *WsConn {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	one, ok := s.conns[userid]
	if ok {
		if conn != nil {
			if one != conn {
				return nil
			}
		}
		delete(s.conns, userid)
		return one
	}

	return nil
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
