package main

import (
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

type Logger struct {
	lg *zap.SugaredLogger
}

func NewLogger() *Logger {
	config := zap.NewDevelopmentConfig()
	config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	// config.EncoderConfig.EncodeCaller = zapcore.FullCallerEncoder
	l, _ := config.Build(zap.AddCallerSkip(1))

	lg := &Logger{}
	lg.lg = l.Sugar()

	return lg
}

func (l *Logger) Use(lg *zap.SugaredLogger) {
	l.lg = lg
}

func (l *Logger) Info(msg string, kv ...interface{}) {
	l.lg.Infow(msg, kv...)
}

func (l *Logger) Error(msg string, kv ...interface{}) {
	l.lg.Errorw(msg, kv...)
}

func (l *Logger) Debug(msg string, kv ...interface{}) {
	l.lg.Debugw(msg, kv...)
}

func (l *Logger) Warn(msg string, kv ...interface{}) {
	l.lg.Warnw(msg, kv...)
}

func (l *Logger) Fatal(msg string, kv ...interface{}) {
	l.lg.Fatalw(msg, kv...)
}
