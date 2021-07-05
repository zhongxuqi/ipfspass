package common

const (
	ErrorCodeInvalidParam = 4000001

	ErrorCodeHandlerNotFound = 4040000

	ErrorCodeInternal = 5000001
)

var (
	ErrorMessageMap = map[int]string{
		ErrorCodeInvalidParam: "invalid param",

		ErrorCodeHandlerNotFound: "handler not found",

		ErrorCodeInternal: "internal error",
	}
)
