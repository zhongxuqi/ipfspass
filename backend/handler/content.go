package handler

import (
	"net/http"

	"github.com/zhongxuqi/ipfspass/common"
	"github.com/zhongxuqi/ipfspass/utils"
	"github.com/zhongxuqi/mklibs/mkerr"
	"github.com/zhongxuqi/mklibs/mklog"
)

func (s *Handler) HandleContent(w http.ResponseWriter, r *http.Request) {
	ml := mklog.NewWithReq(r)
	utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorCodeHandlerNotFound, common.ErrorMessageMap[common.ErrorCodeHandlerNotFound], "Not Found"))
}
