package main

import (
	"github.com/robfig/cron"
)

type FileManager struct {
}

func NewFileManager() *FileManager {
	f := &FileManager{}

	c := cron.New()
	c.AddFunc("@daily", func() {
		f.Clear()
	})
	c.Start()

	return f
}

func (fm *FileManager) Add(filepath string) {

}

func (fm *FileManager) Clear() {

}

var fileMgr = NewFileManager()
