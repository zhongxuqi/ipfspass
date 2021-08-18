package handler

import (
	"net/http"

	"github.com/ipfs/go-cid"
	"github.com/spf13/viper"
	"github.com/zhongxuqi/ipfspass/common"
	"github.com/zhongxuqi/ipfspass/utils"
	"github.com/zhongxuqi/mklibs/mkerr"
	"github.com/zhongxuqi/mklibs/mklog"
)

func (s *Handler) HandleIPFS(w http.ResponseWriter, r *http.Request) {
	ml := mklog.NewWithReq(r)
	if r.Method == http.MethodGet {
		utils.ReplyResp(ml.Context(), w, map[string]interface{}{
			"read_gateway":  viper.GetStringSlice("read_gateway"),
			"write_gateway": viper.GetStringSlice("write_gateway"),
		})
		return
	}
	utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorCodeHandlerNotFound, common.ErrorMessageMap[common.ErrorCodeHandlerNotFound], "Not Found"))
}

func (s *Handler) HandleIPFSCidBase32(w http.ResponseWriter, r *http.Request) {
	ml := mklog.NewWithReq(r)
	if r.Method == http.MethodGet {
		arg := r.URL.Query().Get("arg")
		cidInfo, err := cid.Decode(arg)
		if err != nil {
			ml.Errorf("ParseRequest error %+v", err.Error())
			utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorCodeInternal, common.ErrorMessageMap[common.ErrorCodeInternal], err.Error()))
			return
		}
		utils.ReplyResp(ml.Context(), w, map[string]interface{}{
			"cid_v1": cid.NewCidV1(cidInfo.Prefix().Codec, cidInfo.Hash()).String(),
		})
		return
	}
	utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorCodeHandlerNotFound, common.ErrorMessageMap[common.ErrorCodeHandlerNotFound], "Not Found"))
}
