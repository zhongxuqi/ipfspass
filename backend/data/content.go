package data

type PostContentReq struct {
	ContentData string `json:"content_data"`
}

type PostContentRes struct {
	Cid string `json:"cid"`
}
