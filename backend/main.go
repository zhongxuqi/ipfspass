package main

import (
	"context"
	"encoding/json"
	"flag"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/spf13/viper"
	"github.com/zhongxuqi/ipfspass/handler"
	"github.com/zhongxuqi/mklibs/mklog"
)

func main() {
	ml := mklog.New()
	var configPath string
	flag.StringVar(&configPath, "config", "./config/ipfspass.json", "path of config file")
	flag.Parse()

	viper.SetConfigType("json")
	viper.SetConfigFile(configPath)
	if err := viper.ReadInConfig(); err != nil {
		panic(err)
	}
	b, _ := json.Marshal(viper.GetViper().AllSettings())
	ml.Infof("%+v", string(b))

	mainHandler := handler.NewHandler(ml)
	s := &http.Server{
		Addr:           viper.GetString("addr"),
		Handler:        mainHandler,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}

	shutdownSignal := make(chan int, 0)
	go func() {
		defer func() {
			shutdownSignal <- 1
		}()
		if err := s.ListenAndServe(); err != nil {
			ml.Errorf("ListenAndServe error %+v", err)
		}
	}()
	ml.Infof("Server listen at %+v", s.Addr)

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM, syscall.SIGKILL)
	<-signalChan
	s.Shutdown(context.TODO())
	select {
	case <-shutdownSignal:
		ml.Infof("Server shutdown graceful")
	case <-time.After(10 * time.Second):
		ml.Infof("Server shutdown not graceful")
	}
}
