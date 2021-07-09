curl -X POST "http://127.0.0.1:5001/api/v0/version"
curl "http://127.0.0.1:9990/api/content"

curl -X POST "http://127.0.0.1:9990/api/content" -H "Content-Type: application/json" -d '{"content_data": "ipfspass: hello world !"}'

curl "http://127.0.0.1:8080/ipfs/QmZpcs8ga3ZsGsj5xVy7V3mXQ121TpvQQvSsE7A8W9PtQV"

curl -X POST -F file=@ipfspass.txt "http://127.0.0.1:6001/api/v0/add?hash=sha2-256&inline-limit=32"
curl -X POST -F file=@ipfspass.txt "https://3cloud.ee:5001/api/v0/add?hash=sha2-256&inline-limit=32"
curl -X POST -F file=@ipfspass.txt "https://ipfs.mihir.ch:5001/api/v0/add?hash=sha2-256&inline-limit=32"

curl -X POST "https://10.via0.com/api/v0/version"