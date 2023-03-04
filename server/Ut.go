package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"reflect"
	"runtime/debug"
	"strings"
	"sync"

	"github.com/labstack/echo/v4"
	"github.com/qcdong2016/logs"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/proto"
)

func RandomString(len int) string {
	bytes := make([]byte, len)
	for i := 0; i < len; i++ {
		b := rand.Intn(26) + 'a'
		bytes[i] = byte(b)
	}
	return string(bytes)
}

func RandomNum(minNum int64, maxNum int64) int64 {
	if minNum == maxNum {
		return minNum
	}

	return rand.Int63n(maxNum-minNum+1) + minNum
}

func RandAvatar(name string) string {
	v := []rune(name)
	return fmt.Sprintf("fonts:/#%x%x%x/#%x%x%x/%v",
		RandomNum(20, 255), RandomNum(20, 255), RandomNum(20, 255),
		RandomNum(20, 255), RandomNum(20, 255), RandomNum(20, 255),
		string(v[0]),
	)
}

type handler struct {
	val reflect.Value
	typ reflect.Type
}

type HttpContext struct {
	context.Context
	Request *http.Request
}

func (h *handler) doHandleHttp(path string, server any, httpReq *http.Request) any {

	defer func() {
		// 捕捉崩溃。并返回错误到调用者
		if x := recover(); x != nil {
			logs.Info("PANIC", httpReq.URL.Path, x)
			logs.Info(debug.Stack())
		}
	}()

	mtype, ok := h.typ.MethodByName(path)

	if !ok {
		return errors.New("no method")
	}

	bytes, err := io.ReadAll(httpReq.Body)
	if err != nil {
		return err
	}

	reqType := mtype.Type.In(2)
	req := reflect.New(reqType.Elem())

	dst, err := base64.StdEncoding.DecodeString(string(bytes))
	if err != nil {
		return err
	}

	err = proto.Unmarshal(dst, req.Interface().(proto.Message))
	if err != nil {
		return err
	}

	ctx := &HttpContext{
		Context: context.Background(),
		Request: httpReq,
	}

	vs := make([]reflect.Value, 2)
	vs[0] = reflect.ValueOf(ctx)
	vs[1] = req

	method := h.val.MethodByName(path)
	ret := method.Call(vs)

	if !ret[1].IsNil() {
		return ret[1].Interface()
	}

	return ret[0].Interface()
}

func HttpReturn(w http.ResponseWriter, value interface{}) {
	w.Header().Add("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)
	w.Write(MakeMsg(value))
}

func MakeMsg(value any) []byte {
	resp := map[string]any{}
	resp["code"] = 0

	switch msg := value.(type) {
	case error:
		resp["code"] = 1
		resp["data"] = msg.Error()

	default:
		buf, err := proto.Marshal(msg.(proto.Message))
		if err != nil {
			logs.Info("json错误")
			logs.Info(debug.Stack())
		}

		resp["data"] = base64.StdEncoding.EncodeToString(buf)
	}

	buf, _ := json.Marshal(resp)

	return buf
}

func GrpcHttpHandleFunc(grpcServer any) echo.HandlerFunc {
	h := handler{
		val: reflect.ValueOf(grpcServer),
		typ: reflect.TypeOf(grpcServer),
	}

	return func(c echo.Context) error {
		resp := h.doHandleHttp(strings.TrimLeft(c.Param("*"), "/"), nil, c.Request())
		HttpReturn(c.Response().Writer, resp)
		return nil
	}

}

type ServiceReg struct {
	lock sync.Mutex
	mp   map[string]*DescAndImpl
}

func NewServiceReg() *ServiceReg {
	return &ServiceReg{mp: map[string]*DescAndImpl{}}
}

func (s *ServiceReg) RegisterService(desc *grpc.ServiceDesc, impl interface{}) {
	s.mp[desc.ServiceName] = &DescAndImpl{Desc: desc, Impl: impl}
}

func (s *ServiceReg) GetDesc(path string) (*DescAndImpl, *grpc.MethodDesc) {
	s.lock.Lock()
	defer s.lock.Unlock()

	pos := strings.LastIndex(path, "/")
	if pos == -1 {
		return nil, nil
	}

	service := path[:pos]
	method := path[pos+1:]

	sdesc, ok := s.mp[service]
	if !ok {
		return nil, nil
	}

	for _, v := range sdesc.Desc.Methods {
		if v.MethodName == method {
			return sdesc, &v
		}
	}

	return nil, nil
}
