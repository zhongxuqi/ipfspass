curl -X POST "http://127.0.0.1:5001/api/v0/version"
curl "http://127.0.0.1:9990/api/content"

curl -X POST "http://127.0.0.1:9990/api/content" -H "Content-Type: application/json" -d '{"content_data": "ipfspass: hello world !"}'

curl "http://127.0.0.1:8080/ipfs/QmZpcs8ga3ZsGsj5xVy7V3mXQ121TpvQQvSsE7A8W9PtQV"

curl -X POST -F file=@ipfspass.txt "http://127.0.0.1:6001/api/v0/add?hash=sha2-256&inline-limit=32"
curl -X POST -F file=@ipfspass.txt "https://3cloud.ee:5001/api/v0/add?hash=sha2-256&inline-limit=32"
curl -X POST -F file=@ipfspass.txt "https://infura-ipfs.io:5001/api/v0/add?hash=sha2-256&inline-limit=32"

curl -X POST "https://10.via0.com/api/v0/version"

# 公共读取节点
curl "https://ipfs.itargo.io/ipfs/bafybeidutlmqfu62zhn36lapfi7i5iyxvqnte7fv7zhq2rticzustk4rlq"
curl "https://ipfs.io/ipfs/bafybeidutlmqfu62zhn36lapfi7i5iyxvqnte7fv7zhq2rticzustk4rlq"
curl "https://infura-ipfs.io/ipfs/bafybeidutlmqfu62zhn36lapfi7i5iyxvqnte7fv7zhq2rticzustk4rlq"

# 公共写入节点
curl -X POST -F file=@ipfspass.txt "https://infura-ipfs.io:5001/api/v0/add?hash=sha2-256&inline-limit=32"
curl -X POST -F file=@ipfspass.txt "https://ipfs.infura.io:5001/api/v0/add?hash=sha2-256&inline-limit=32"

curl -X POST "http://127.0.0.1:6001/api/v0/cid/base32?arg=QmWBpx5xxh9GERmrhYQe8B6FyqnFLdU1vhQSvK768Ghwum"
curl -X POST "https://infura-ipfs.io:5001/api/v0/cid/base32?arg=QmWBpx5xxh9GERmrhYQe8B6FyqnFLdU1vhQSvK768Ghwum"

curl "http://127.0.0.1:9991/api/ipfs/cid/base32?arg=QmWBpx5xxh9GERmrhYQe8B6FyqnFLdU1vhQSvK768Ghwum"