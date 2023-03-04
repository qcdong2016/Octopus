package main

import (
	"Octopus/pb"
	"errors"
	"net"
	"sync/atomic"
	"time"

	"github.com/gorilla/websocket"
	"github.com/qcdong2016/logs"
	"google.golang.org/protobuf/proto"
)

const (
	WRITE_WAIT   = 10 * time.Second
	READ_WAIT    = 20 * time.Second
	PONG_WAIT    = 100 * time.Second
	PING_PERIOD  = 5 * time.Second
	AUTH_TIMEOUT = 5 * time.Second
)

type Msg struct {
	Bytes []byte
	Error error
	Type  int
}

type WsConn struct {
	ws           *websocket.Conn
	sendChan     chan *Msg
	endWritePump chan struct{}
	pumpFinished chan struct{}
	authFlag     int32
	closeFlag    int32
	IP           string
	handler      MsgHandler

	UserID int64
}

func (ws *WsConn) IsClosed() bool {
	return atomic.LoadInt32(&ws.closeFlag) == 1
}

func (ws *WsConn) SetAuthed() {
	atomic.StoreInt32(&ws.authFlag, 1)
}
func (ws *WsConn) IsAuthed() bool {
	return atomic.LoadInt32(&ws.authFlag) == 1
}

func NewWsConn(ws *websocket.Conn, msgHandler MsgHandler) *WsConn {

	wc := &WsConn{
		ws:           ws,
		sendChan:     make(chan *Msg, 1024),
		endWritePump: make(chan struct{}, 2),
		pumpFinished: make(chan struct{}, 1),
		IP:           ws.RemoteAddr().String(),
		handler:      msgHandler,
	}

	wc.ws.SetReadDeadline(time.Now().Add(READ_WAIT))
	wc.ws.SetPingHandler(func(string) error {
		wc.ws.SetReadDeadline(time.Now().Add(READ_WAIT))
		err := wc.ws.WriteControl(websocket.PongMessage, []byte{}, time.Now().Add(READ_WAIT))
		if err == websocket.ErrCloseSent {
			return nil
		} else if e, ok := err.(net.Error); ok && e.Temporary() {
			return nil
		}
		return err
	})

	return wc
}

func makeMsg(method any, imsg any) ([]byte, error) {
	data := &pb.S2CData{}

	switch id := method.(type) {
	case string:
		data.Method = method.(string)
	case int64:
		data.Callback = id
	default:
		return nil, errors.New("not support")
	}

	switch msg := imsg.(type) {
	case proto.Message:
		buf, err := proto.Marshal(msg)
		if err != nil {
			return nil, err
		}
		data.Body = buf

	case error:
		data.Error = msg.Error()
	}

	return proto.Marshal(data)
}

func (ws *WsConn) SendNow(method any, imsg any) error {
	buf, err := makeMsg(method, imsg)
	if err != nil {
		return err
	}

	ws.ws.SetWriteDeadline(time.Now().Add(WRITE_WAIT))

	return ws.ws.WriteMessage(websocket.BinaryMessage, buf)
}

func (ws *WsConn) Send(method any, imsg any) error {

	buf, err := makeMsg(method, imsg)
	if err != nil {
		return err
	}

	ws.sendChan <- &Msg{
		Bytes: buf,
		Type:  websocket.BinaryMessage,
	}

	return nil
}

func (ws *WsConn) Write(bytes []byte) (int, error) {
	if err := ws.ws.WriteMessage(websocket.TextMessage, bytes); err != nil {
		return 0, err
	}
	return len(bytes), nil
}

func (ws *WsConn) Close() {
	if !ws.IsClosed() {
		ws.ws.Close()
		ws.endWritePump <- struct{}{}
		<-ws.pumpFinished
	}
}

func (ws *WsConn) readPump() {

	defer func() {
		ws.endWritePump <- struct{}{}
		ws.ws.Close()
	}()

	for {
		// _, reader, err := ws.ws.NextReader()
		ws.ws.SetReadDeadline(time.Now().Add(READ_WAIT))
		_, buf, err := ws.ws.ReadMessage()

		if err != nil {
			if websocket.IsCloseError(err, websocket.CloseNormalClosure, websocket.CloseNoStatusReceived) {
				logs.Debug("ws.read", "error", "client side closed socket.", "ip", ws.IP)
			} else if e, ok := err.(net.Error); ok && !e.Temporary() {
				logs.Debug("ws.read", "error", err.Error(), "ip", ws.IP)
			}

			return
		} else {
			if err := ws.handler.OnRecv(ws, buf); err != nil {
				logs.Error("ws.recv", "error", err.Error(), "ip", ws.IP)
				return
			}
		}
	}
}

func (ws *WsConn) writePump() {
	authTicker := time.NewTicker(AUTH_TIMEOUT)

	defer func() {
		ws.ws.Close()
		authTicker.Stop()
	}()

	for {
		select {
		case <-ws.endWritePump:
			return

		case <-authTicker.C:
			if ws.authFlag != 1 {
				logs.Debug("ws.authTicker", "ip", ws.IP)
				return
			}
			authTicker.Stop()

		case msg := <-ws.sendChan:

			ws.ws.SetWriteDeadline(time.Now().Add(WRITE_WAIT))

			msg.Error = ws.ws.WriteMessage(msg.Type, msg.Bytes)

			if msg.Error != nil {
				if websocket.IsCloseError(msg.Error, websocket.CloseNormalClosure, websocket.CloseNoStatusReceived) {
					logs.Debug("ws.send", "error", "client side closed socket", "ip", ws.IP)
				} else {
					logs.Debug("ws.send", "error", msg.Error.Error(), "ip", ws.IP)
				}
			}
		}
	}
}

func (ws *WsConn) Pump() {
	ch := make(chan struct{}, 1)
	go func() {
		ws.writePump()
		ch <- struct{}{}
	}()
	ws.readPump()
	<-ch
	ws.pumpFinished <- struct{}{}
	atomic.StoreInt32(&ws.closeFlag, 1)
	// ws.handler.OnClose(ws)
}
