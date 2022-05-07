package main

import (
	"errors"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/qcdong2016/logs"
	"github.com/robfig/cron"
)

type DataManager struct {
	users map[int64]*Friend
	teams map[int64]*Friend

	DB *XormDB

	lock sync.Mutex
}

func NewDataManager() *DataManager {
	d := &DataManager{}

	d.users = map[int64]*Friend{}
	d.teams = map[int64]*Friend{}

	d.DB = NewDB("octopus.db")

	loadAll[*User](d, d.users, false)
	loadAll[*Team](d, d.teams, true)

	d.startCron()

	return d
}

type FriendAble interface {
	ToFriend() *Friend
}

func loadAll[T FriendAble](d *DataManager, to map[int64]*Friend, online bool) {
	all := []T{}
	err := d.DB.Find(&all)
	if err != nil {
		panic(err)
	}

	for _, u := range all {
		f := u.ToFriend()
		f.Online = online
		to[f.ID] = f
	}
}

func nextIdOf(m map[int64]*Friend, rg []int64) int64 {
	var userid int64

	for {
		userid = int64(RandomNum(rg[0], rg[1]))
		if _, ok := m[userid]; ok {
			continue
		}

		break
	}

	return userid
}

func (d *DataManager) getUserTeams(user int64) ([]*TeamMember, error) {
	all := []*TeamMember{}
	err := d.DB.Where("User=?", user).Find(&all)
	return all, err
}

func (d *DataManager) getTeamMem(team int64) ([]*TeamMember, error) {
	all := []*TeamMember{}
	err := d.DB.Where("Team=?", team).Find(&all)
	return all, err
}

func (d *DataManager) NewTeam(owner int64, nickname, avatar string) (*Team, error) {
	d.lock.Lock()
	defer d.lock.Unlock()

	u := &Team{
		Nickname: nickname,
		Id:       nextIdOf(d.teams, team_id_range),
		Avatar:   avatar,
	}

	_, err := d.DB.Insert(u)
	if err != nil {
		return nil, err
	}

	d.teams[u.Id] = u.ToFriend()

	d.SendTo(u.Id, "friendOnline", u.ToFriend())

	return u, nil
}

func (d *DataManager) Regist(nickname, password, avatar string) (*User, error) {
	d.lock.Lock()
	defer d.lock.Unlock()

	u := &User{
		Nickname: nickname,
		Password: password,
		Id:       nextIdOf(d.users, user_id_range),
		Avatar:   avatar,
	}

	_, err := d.DB.Insert(u)
	if err != nil {
		return nil, err
	}

	d.users[u.Id] = u.ToFriend()

	return u, nil
}

func (d *DataManager) Logout(uid int64) {
	d.lock.Lock()
	defer d.lock.Unlock()

	u, ok := d.users[uid]
	if ok {
		u.Online = false
	}
}

func (d *DataManager) Get(id int64) *Friend {

	d.lock.Lock()
	defer d.lock.Unlock()

	u, ok := d.users[id]
	if ok {
		return u
	}

	return nil
}

func (d *DataManager) findUserByNick(nick string) *Friend {
	for _, u := range d.users {
		if u.Nickname == nick {
			return u
		}
	}
	return nil
}

func (d *DataManager) Login(msg *ReqLogin) (*Friend, error) {

	d.lock.Lock()
	defer d.lock.Unlock()

	var userid int64 = -1

	switch val := msg.ID.(type) {
	case float64:
		userid = int64(val)
	case string:
		val = strings.TrimSpace(val)
		logs.Info(val)

		testID, err := strconv.ParseInt(val, 10, 64)
		if err != nil {
			testID = -1
		}
		_, ok := d.users[testID]
		if !ok {
			testID = -1
		} else {
			userid = testID
		}

		if testID == -1 {
			u := d.findUserByNick(strings.TrimSpace(val))
			if u != nil {
				userid = u.ID
			}
		}
	}

	f, ok := d.users[userid]
	if !ok {
		return nil, errors.New("用户不存在")
	}

	u := User{}
	err := d.DB.Where("Id=?", userid).Find(&u)

	if err != nil {
		return nil, errors.New("登陆失败")
	}

	if u.Password != msg.Password {
		return nil, errors.New("密码错误")
	}

	f.Online = true

	return f, nil
}

func (d *DataManager) GetFriends(user int64) []*Friend {
	d.lock.Lock()
	defer d.lock.Unlock()

	friends := make([]*Friend, 0, len(d.users))

	for _, u := range d.users {
		if u.ID != user {
			friends = append(friends, u)
		}
	}

	mems, _ := d.getUserTeams(user)
	for _, v := range mems {
		team := d.teams[v.Team]
		friends = append(friends, team)
	}

	return friends
}

func (d *DataManager) startCron() {
	c := cron.New()
	c.AddFunc("@daily", func() {
		d.clearFiles()
	})
	c.Start()
}

func (d *DataManager) clearFiles() {
	eles := []*File{}
	d.DB.Find(&eles)
	for _, e := range eles {
		os.Remove(e.Path)
	}
	d.DB.Table(File{}).Delete()
}

func (d *DataManager) AddFile(filepath string) {
	d.DB.Insert(&File{
		Path: filepath,
		Date: time.Now(),
	})
}

func (d *DataManager) SendTo(to int64, route, msg interface{}) {
	if to >= team_id_range[1] {
		d.SendToTeam(to, route, msg)
	} else {
		user := server.Get(to)
		if user != nil {
			user.Send(route, msg, nil)
		}
	}
}

func (d *DataManager) SendToTeam(to int64, route, msg interface{}) {

	mems, _ := d.getTeamMem(to)

	for _, one := range mems {
		user := server.Get(one.User)
		if user != nil {
			user.Send(route, msg, nil)
		}
	}
}
