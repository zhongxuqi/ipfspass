package utils

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/zhongxuqi/ipfspass/common"
	"github.com/zhongxuqi/mklibs/mkerr"
	"github.com/zhongxuqi/mklibs/mklog"
)

func ParseRequest(ctx context.Context, r *http.Request, req interface{}) error {
	ml := mklog.NewWithReq(r)
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		ml.Errorf("json.Decode error %+v", err)
		return mkerr.NewError(common.ErrorCodeInvalidParam, common.ErrorMessageMap[common.ErrorCodeInvalidParam], err.Error())
	}
	return nil
}
