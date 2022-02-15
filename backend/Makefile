.PHONY: default
default:
	go run main.go

.PHONY: windows-release
windows-release:
	go env -w GOOS=linux && go build -o ipfspass && go env -w GOOS=windows

.PHONY: build
build:
	GOOS=linux GOARCH=amd64 go build -o ipfspass

.PHONY: deploy
deploy: build
	scp ipfspass zhongxuqi@47.97.68.46:~/ipfspass/backend

.PHONY: deploy-hk
deploy-hk: build
	scp ipfspass zhongxuqi@8.210.76.226:~/ipfspass/backend