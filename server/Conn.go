package main

import (
	"encoding/json"
	"errors"
	"net"
	"sync/atomic"
	"time"

	"github.com/gorilla/websocket"
)

var (
	UseClosedConn = errors.New("use closed conn")
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

	UserID int
}

func (this *WsConn) IsClosed() bool {
	return atomic.LoadInt32(&this.closeFlag) == 1
}

func (this *WsConn) SetAuthed() {
	atomic.StoreInt32(&this.authFlag, 1)
}
func (this *WsConn) IsAuthed() bool {
	return atomic.LoadInt32(&this.authFlag) == 1
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

func (this *WsConn) Send(route, d interface{}, addbytes []byte) error {

	ret := map[string]interface{}{}

	if cbid, ok := route.(int); ok {
		ret["cbid"] = cbid
	} else {
		ret["route"] = route
	}

	if err, ok := d.(error); ok {
		ret["err"] = err.Error()
	}

	bytesData, err := json.Marshal(d)
	if err != nil {
		return err
	}

	ret["size"] = len(bytesData)

	bytes, err := json.Marshal(ret)
	if err != nil {
		return err
	}

	bytes = append(bytes, bytesData...)

	logger.Info("send", "msg", string(bytes))
	if addbytes != nil {
		bytes = append(bytes, addbytes...)
		this.send(bytes, websocket.BinaryMessage)
	} else {
		this.send(bytes, websocket.TextMessage)
	}

	return nil
}

func (this *WsConn) send(msg []byte, msgtype int) *Msg {
	r := &Msg{
		Bytes: msg,
		Type:  msgtype,
	}
	this.sendChan <- r
	return r
}

func (this *WsConn) Write(bytes []byte) (int, error) {
	if err := this.ws.WriteMessage(websocket.TextMessage, bytes); err != nil {
		return 0, err
	}
	return len(bytes), nil
}

func (this *WsConn) Close() {
	if !this.IsClosed() {
		this.ws.Close()
		this.endWritePump <- struct{}{}
		<-this.pumpFinished
	}
}

func (this *WsConn) readPump() {

	defer func() {
		this.endWritePump <- struct{}{}
		this.ws.Close()
	}()

	for {
		// _, reader, err := this.ws.NextReader()
		this.ws.SetReadDeadline(time.Now().Add(READ_WAIT))
		_, buf, err := this.ws.ReadMessage()

		if err != nil {
			if websocket.IsCloseError(err, websocket.CloseNormalClosure, websocket.CloseNoStatusReceived) {
				logger.Debug("ws.read", "error", "client side closed socket.", "ip", this.IP)
			} else if e, ok := err.(net.Error); ok && !e.Temporary() {
				logger.Debug("ws.read", "error", err.Error(), "ip", this.IP)
			}

			return
		} else {
			if err := this.handler.OnRecv(this, buf); err != nil {
				logger.Error("ws.recv", "error", err.Error(), "ip", this.IP)
				return
			}
		}
	}
}

func (this *WsConn) writePump() {
	authTicker := time.NewTicker(AUTH_TIMEOUT)

	defer func() {
		this.ws.Close()
		authTicker.Stop()
	}()

	for {
		select {
		case <-this.endWritePump:
			return

		case <-authTicker.C:
			if this.authFlag != 1 {
				logger.Debug("ws.authTicker", "ip", this.IP)
				return
			}
			authTicker.Stop()

		case msg := <-this.sendChan:

			this.ws.SetWriteDeadline(time.Now().Add(WRITE_WAIT))

			msg.Error = this.ws.WriteMessage(msg.Type, msg.Bytes)

			if msg.Error != nil {
				if websocket.IsCloseError(msg.Error, websocket.CloseNormalClosure, websocket.CloseNoStatusReceived) {
					logger.Debug("ws.send", "error", "client side closed socket", "ip", this.IP)
				} else {
					logger.Debug("ws.send", "error", msg.Error.Error(), "ip", this.IP)
				}
			}
		}
	}
}

func (this *WsConn) Pump() {
	ch := make(chan struct{}, 1)
	go func() {
		this.writePump()
		ch <- struct{}{}
	}()
	this.readPump()
	<-ch
	this.pumpFinished <- struct{}{}
	atomic.StoreInt32(&this.closeFlag, 1)
	// this.handler.OnClose(this)
}
