package data

type Response struct {
	ErrNo     int64       `json:"errno"`
	ErrMsg    string      `json:"errmsg"`
	ErrDetail string      `json:"errdetail"`
	Data      interface{} `json:"data"`
}
