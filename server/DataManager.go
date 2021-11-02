package main

import (
	"errors"
	"os"
	"sync"
	"time"

	"github.com/robfig/cron"
	"upper.io/db.v3/lib/sqlbuilder"
	"upper.io/db.v3/sqlite"
)

type DataManager struct {
	users map[int]*User

	DB sqlbuilder.Database

	lock sync.Mutex
}

func NewDataManager() *DataManager {
	d := &DataManager{}

	d.users = map[int]*User{}

	var settings = sqlite.ConnectionURL{
		Database: `./data.db`, // Path to a sqlite3 database file.
	}

	sess, err := sqlite.Open(settings)

	if err != nil {
		panic(err)
	}

	d.DB = sess

	_, err = sess.Exec(`
	CREATE TABLE IF NOT EXISTS users(
		id       integer,
		nickname varchar(50) DEFAULT NULL,
		password varchar(12) DEFAULT NULL,
		avatar   varchar(100)
	);
	CREATE TABLE IF NOT EXISTS files(
		path varchar(50),
		date DATE
	);
	`)

	if err != nil {
		panic(err)
	}

	users := []*User{}

	err = d.DB.Collection("users").Find().All(&users)
	if err != nil {
		panic(err)
	}

	for _, u := range users {
		d.users[u.ID] = u
	}

	d.startCron()

	return d
}

func (d *DataManager) Regist(nickname, password, avatar string) (*User, error) {
	d.lock.Lock()
	defer d.lock.Unlock()

	var userid int

	for {
		userid = RandomNum(10000, 99999)
		if _, ok := d.users[userid]; ok {
			continue
		}

		break
	}

	u := &User{
		Nickname: nickname,
		Password: password,
		ID:       userid,
		Avatar:   avatar,
	}

	_, err := d.DB.Collection("users").Insert(u)
	if err != nil {
		return nil, err
	}

	d.users[userid] = u

	return u, nil
}

func (d *DataManager) Logout(uid int) {
	d.lock.Lock()
	defer d.lock.Unlock()

	u, ok := d.users[uid]
	if ok {
		u.Online = false
	}
}

func (d *DataManager) Get(id int) *User {

	d.lock.Lock()
	defer d.lock.Unlock()

	u, ok := d.users[id]
	if ok {
		return u
	}

	return nil
}

func (d *DataManager) Login(msg *ReqLogin) (*User, error) {

	d.lock.Lock()
	defer d.lock.Unlock()

	u, ok := d.users[msg.ID]
	if !ok {
		return nil, errors.New("用户不存在")
	}

	if u.Password != msg.Password {
		return nil, errors.New("密码错误")
	}

	u.Online = true

	return u, nil
}

func (d *DataManager) GetFriends(user int) []*User {
	d.lock.Lock()
	defer d.lock.Unlock()

	friends := make([]*User, 0, len(d.users))

	// friends = append(friends, &User{
	// 	ID:       996,
	// 	Nickname: "所有人",
	// 	Avatar:   "fonts:/#00ffff/#fff0aa/所",
	// 	Online:   true,
	// 	Group:    true,
	// })

	for _, u := range d.users {
		if u.ID != user {
			friends = append(friends, u)
		}
	}

	return friends
}

type FileElement struct {
	Path string    `db:"path"`
	Date time.Time `db:"date"`
}

func (d *DataManager) startCron() {
	c := cron.New()
	c.AddFunc("@daily", func() {
		d.clearFiles()
	})
	c.Start()
}

func (d *DataManager) clearFiles() {
	eles := []*FileElement{}
	d.DB.Collection("files").Find().All(&eles)
	for _, e := range eles {
		os.Remove(e.Path)
	}
	d.DB.Collection("files").Truncate()
}

func (d *DataManager) AddFile(filepath string) {
	d.DB.Collection("files").Insert(&FileElement{
		Path: filepath,
		Date: time.Now(),
	})
}
