package utils

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"

	"github.com/spf13/viper"
	"github.com/zhongxuqi/ipfspass/common"
	"github.com/zhongxuqi/ipfspass/data"
	"github.com/zhongxuqi/mklibs/mkerr"
	"github.com/zhongxuqi/mklibs/mklog"
)

func ReplyResp(ctx context.Context, w http.ResponseWriter, resp interface{}) {
	ml := mklog.NewWithContext(ctx)
	bf := bytes.NewBuffer([]byte{})
	jsonEncoder := json.NewEncoder(bf)
	jsonEncoder.SetEscapeHTML(false)
	jsonEncoder.Encode(data.Response{
		Data: resp,
	})
	w.Header().Set("Content-Type", "application/json")
	w.Write(bf.Bytes())
	ml.Infof("response body:%+v", bf.String())
}

func ReplyError(ctx context.Context, w http.ResponseWriter, err error) {
	ml := mklog.NewWithContext(ctx)
	var resp data.Response
	if errDetail, ok := err.(mkerr.Error); ok {
		resp.ErrNo = errDetail.ErrNo()
		resp.ErrMsg = errDetail.Error()
		if viper.GetViper().GetString("env") != "online" {
			resp.ErrDetail = errDetail.ErrDetail()
		}
	} else {
		resp.ErrNo = common.ErrorCodeInternal
		resp.ErrMsg = common.ErrorMessageMap[common.ErrorCodeInternal]
		if viper.GetViper().GetString("env") != "online" {
			resp.ErrDetail = err.Error()
		}
	}
	respByte, _ := json.Marshal(resp)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(int(resp.ErrNo / 10000))
	w.Write(respByte)
	ml.Infof("response body:%+v", string(respByte))
}
