package handler

import (
	"net/http"

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
