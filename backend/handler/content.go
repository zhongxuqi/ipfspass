package handler

import (
	"io/ioutil"
	"net/http"

	files "github.com/ipfs/go-ipfs-files"
	icorepath "github.com/ipfs/interface-go-ipfs-core/path"
	"github.com/zhongxuqi/ipfspass/common"
	"github.com/zhongxuqi/ipfspass/utils"
	"github.com/zhongxuqi/mklibs/mkerr"
	"github.com/zhongxuqi/mklibs/mklog"
)

func (s *Handler) HandleContent(w http.ResponseWriter, r *http.Request) {
	ml := mklog.NewWithReq(r)
	if r.Method == http.MethodGet {
		exampleCIDStr := "QmWBpx5xxh9GERmrhYQe8B6FyqnFLdU1vhQSvK768Ghwum"
		rootNode, err := s.ipfs.Unixfs().Get(ml.Context(), icorepath.New(exampleCIDStr))
		if err != nil {
			ml.Errorf("Could not get file with CID: %s", err)
			utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorIPFSFail, common.ErrorMessageMap[common.ErrorIPFSFail], err.Error()))
			return
		}
		if ipfsFile, ok := rootNode.(files.File); ok {
			b, _ := ioutil.ReadAll(ipfsFile)
			ml.Infof("ipfsFile %+v", string(b))
		}
		utils.ReplyResp(ml.Context(), w, nil)
		return
	}
	utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorCodeHandlerNotFound, common.ErrorMessageMap[common.ErrorCodeHandlerNotFound], "Not Found"))
}
