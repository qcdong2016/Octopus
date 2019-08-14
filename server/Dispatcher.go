package main

import "errors"

type HandleFunc func(conn *WsConn, pkg *Package) error
type Dispatcher struct {
	handlers map[string]HandleFunc
}

func NewDispatcher() *Dispatcher {
	d := &Dispatcher{}

	d.handlers = map[string]HandleFunc{}

	return d
}

func (d *Dispatcher) Add(k string, fn HandleFunc) {
	d.handlers[k] = fn
}

func (d *Dispatcher) Dispatch(conn *WsConn, pkg *Package) error {

	fn, ok := d.handlers[pkg.Route]

	if !ok {
		return errors.New("no handler for key `" + pkg.Route)
	}

	return fn(conn, pkg)
}

var dispatcher = NewDispatcher()
