set -e
./build.sh
scp -r build/* root@195.26.251.204:/srv/http/alex
#scp -r res/* root@195.26.251.204:/srv/http/alex/res
