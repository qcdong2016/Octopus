package main

import (
	"Octopus/pb"
	"errors"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/robfig/cron"
)

type DataManager struct {
	users map[int64]*pb.Friend
	teams map[int64]*pb.Friend

	DB *XormDB

	lock sync.Mutex
}

func NewDataManager() *DataManager {
	d := &DataManager{}

	d.users = map[int64]*pb.Friend{}
	d.teams = map[int64]*pb.Friend{}

	d.DB = NewDB("octopus.db")

	loadAll[*User](d, d.users, false)
	loadAll[*Team](d, d.teams, true)

	d.startCron()

	return d
}

type FriendAble interface {
	ToFriend() *pb.Friend
}

func loadAll[T FriendAble](d *DataManager, to map[int64]*pb.Friend, online bool) {
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

func nextIdOf(m map[int64]*pb.Friend, rg []int64) int64 {
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

func (d *DataManager) teamAddMem(team, mem int64) {
	d.DB.Insert(TeamMember{Team: team, User: mem})
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

	// d.SendTo(0, u.Id, "friendOnline", u.ToFriend())

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

	d.teamAddMem(default_team_id, u.Id)

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

func (d *DataManager) Get(id int64) *pb.Friend {

	d.lock.Lock()
	defer d.lock.Unlock()

	u, ok := d.users[id]
	if ok {
		return u
	}

	return nil
}

func (d *DataManager) findUserByNick(nick string) *pb.Friend {
	for _, u := range d.users {
		if u.Nickname == nick {
			return u
		}
	}
	return nil
}

func (d *DataManager) Login(idtxt, p string) (*pb.Friend, error) {

	d.lock.Lock()
	defer d.lock.Unlock()

	var userid int64 = -1

	val := strings.TrimSpace(idtxt)

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

	f, ok := d.users[userid]
	if !ok {
		return nil, errors.New("用户不存在")
	}

	u := User{}
	_, err = d.DB.Table(u).Where("Id=?", userid).Get(&u)

	if err != nil {
		return nil, errors.New("登陆失败")
	}

	if u.Password != p {
		return nil, errors.New("密码错误")
	}

	f.Online = true

	return f, nil
}

func (d *DataManager) GetFriends(user int64) []*pb.Friend {
	d.lock.Lock()
	defer d.lock.Unlock()

	friends := make([]*pb.Friend, 0, len(d.users))

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

func IsTeam(id int64) bool {
	return id >= team_id_range[0]
}

func (d *DataManager) SendTo(sender, to int64, route string, msg any) {
	if to >= team_id_range[0] {
		d.SendToTeam(sender, to, route, msg)
	} else {
		user := server.Get(to)
		if user != nil {
			user.Send(route, msg)
		}
	}
}

func (d *DataManager) SendToTeam(sender, to int64, route string, msg any) {

	mems, _ := d.getTeamMem(to)

	for _, one := range mems {
		if one.User != sender {
			user := server.Get(one.User)
			if user != nil {
				user.Send(route, msg)
			}
		}
	}
}
