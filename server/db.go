package main

import (
	"time"

	"xorm.io/xorm"
	"xorm.io/xorm/names"

	_ "github.com/mattn/go-sqlite3"
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

	team := Team{}
	_, err = db.Where("Id=?", default_team_id).Get(&team)
	if team.Id != int64(default_team_id) {
		team = Team{
			Id:       int64(default_team_id),
			Avatar:   "fonts:/#2a4745/#2f51cc/所",
			Nickname: "所有人",
		}
		db.Insert(team)

		all := []*User{}
		err := db.Table(User{}).Find(&all)
		if err != nil {
			panic(err)
		}
		for _, v := range all {
			db.Insert(TeamMember{Team: team.Id, User: v.Id})
		}
	}

	return &XormDB{
		Engine: db,
	}
}
