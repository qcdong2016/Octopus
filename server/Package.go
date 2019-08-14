package main

import (
	"bytes"
	"encoding/json"
)

type Package struct {
	Route    string `json:"route"`
	CB       int    `json:"cbid"`
	ArgsSize int    `json:"argsSize"`
	Args     []byte `json:"-"`
	UserID   int    `json:"-"`
	Data     []byte `json:"-"`
}

func NewPackage(uid int, buf []byte) (*Package, error) {

	index := bytes.IndexByte(buf, '}')

	pkg := &Package{}
	err := json.Unmarshal(buf[:index+1], pkg)

	if err != nil {
		return nil, err
	}

	pkg.UserID = uid
	pkg.Args = buf[index+1 : index+1+pkg.ArgsSize]
	if len(buf) > index+1+pkg.ArgsSize {
		pkg.Data = buf[index+1+pkg.ArgsSize:]
	}

	logger.Info("recv", "msg", string(buf[:index+1+pkg.ArgsSize]))

	return pkg, nil
}

func (p *Package) Bind(i interface{}) error {
	return json.Unmarshal(p.Args, i)
}
