curl "http://127.0.0.1:9990/api/content"

curl -X POST "http://127.0.0.1:9990/api/content" -H "Content-Type: application/json" -d '{"content_data": "ipfspass: hello world !"}'


curl -X POST -F file=@ipfspass.txt "http://127.0.0.1:6001/api/v0/add?hash=sha2-256&inline-limit=32"
curl -X POST -F file=@ipfspass.txt "https://ipfs.kaleido.art/api/v0/add?hash=sha2-256&inline-limit=32"

curl -X POST "https://10.via0.com/api/v0/version"