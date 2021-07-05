package handler

import (
	"bytes"
	"io/ioutil"
	"net/http"

	"github.com/zhongxuqi/ipfspass/common"
	"github.com/zhongxuqi/ipfspass/utils"
	"github.com/zhongxuqi/mklibs/mkerr"
	"github.com/zhongxuqi/mklibs/mklog"
)

type Handler struct {
	mux *http.ServeMux
}

func NewHandler(ml mklog.Logger) *Handler {
	handler := &Handler{
		mux: http.NewServeMux(),
	}
	return handler
}

func (s *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	ml := mklog.NewWithReq(r)
	reqRawByte, err := ioutil.ReadAll(r.Body)
	if err != nil {
		utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorCodeInvalidParam, common.ErrorMessageMap[common.ErrorCodeInvalidParam], err.Error()))
		return
	}
	ml.Infof("request url:%+v body:%+v", r.URL.String(), string(reqRawByte))
	realBody := r.Body
	defer func() {
		r.Body = realBody
	}()
	r.Body = ioutil.NopCloser(bytes.NewBuffer(reqRawByte))
	s.mux.ServeHTTP(w, r)
}

func (s *Handler) initRouter(ml mklog.Logger) {

	// api
	apiMux := http.NewServeMux()
	apiMux.HandleFunc("/api/content", s.HandleContent)
	s.mux.HandleFunc("/api/", func(w http.ResponseWriter, r *http.Request) {
		apiMux.ServeHTTP(w, r)
	})
}
