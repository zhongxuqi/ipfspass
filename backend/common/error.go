package common

const (
	ErrorCodeInvalidParam = 4000001

	ErrorCodeHandlerNotFound = 4040000

	ErrorCodeInternal = 5000001

	ErrorIPFSFail = 5010002
)

var (
	ErrorMessageMap = map[int]string{
		ErrorCodeInvalidParam: "invalid param",

		ErrorCodeHandlerNotFound: "handler not found",

		ErrorCodeInternal: "internal error",

		ErrorIPFSFail: "ipfs fail",
	}
)
