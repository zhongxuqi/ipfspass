package handler

import (
	"io/ioutil"
	"net/http"
	"os"

	files "github.com/ipfs/go-ipfs-files"
	icorepath "github.com/ipfs/interface-go-ipfs-core/path"
	"github.com/zhongxuqi/ipfspass/common"
	"github.com/zhongxuqi/ipfspass/data"
	"github.com/zhongxuqi/ipfspass/utils"
	"github.com/zhongxuqi/mklibs/mkerr"
	"github.com/zhongxuqi/mklibs/mklog"
)

func getUnixfsNode(path string) (files.Node, error) {
	st, err := os.Stat(path)
	if err != nil {
		return nil, err
	}

	f, err := files.NewSerialFile(path, false, st)
	if err != nil {
		return nil, err
	}

	return f, nil
}

func (s *Handler) HandleContent(w http.ResponseWriter, r *http.Request) {
	ml := mklog.NewWithReq(r)
	if r.Method == http.MethodGet {
		exampleCIDStr := "QmPY91BeXjRHxQtUn11zxBLUJ8EcYQzwPSMYG18DpV7qar"
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
	} else if r.Method == http.MethodPost {
		var req data.PostContentReq
		if err := utils.ParseRequest(ml.Context(), r, &req); err != nil {
			ml.Errorf("ParseRequest error %+v", err)
			utils.ReplyError(ml.Context(), w, err)
			return
		}
		someFile, err := getUnixfsNode("/Users/xuqizhong/workspace/ipfs/ipfspass.txt")
		if err != nil {
			ml.Errorf("ParseRequest error %+v", err)
			utils.ReplyError(ml.Context(), w, err)
			return
		}
		cidFile, err := s.ipfs.Unixfs().Add(ml.Context(), someFile)
		if err != nil {
			ml.Errorf("ParseRequest error %+v", err)
			utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorIPFSFail, common.ErrorMessageMap[common.ErrorIPFSFail], err.Error()))
			return
		}
		utils.ReplyResp(ml.Context(), w, data.PostContentRes{
			Cid: cidFile.String(),
		})
		return
	}
	utils.ReplyError(ml.Context(), w, mkerr.NewError(common.ErrorCodeHandlerNotFound, common.ErrorMessageMap[common.ErrorCodeHandlerNotFound], "Not Found"))
}
