package common

const (
	ErrorCodeInvalidParam = 4000001

	ErrorCodeInternal = 5000001
)

var (
	ErrorMessageMap = map[int]string{
		ErrorCodeInvalidParam: "invalid param",

		ErrorCodeInternal: "internal error",
	}
)
