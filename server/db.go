package main

import (
	"time"

	"xorm.io/xorm"
	"xorm.io/xorm/names"
)

type XormDB struct {
	*xorm.Engine
}

func NewDB(dbfile string) *XormDB {
	var err error

	db, err := xorm.NewEngine("sqlite3", dbfile)
	if err != nil {
		panic(err)
	}

	db.SetMapper(names.SameMapper{})
	db.DatabaseTZ = time.Local
	db.TZLocation = time.Local

	db.Sync2(all_docs...)

	return &XormDB{
		Engine: db,
	}
}
