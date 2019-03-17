#!/bin/sh

#install protoc
#https://github.com/protocolbuffers/protobuf/releases/

OS=`uname`
OS=$(echo "$OS" | tr '[A-Z]' '[a-z]')

if [ "$OS" = "darwin" ]; then
    platform="osx"
else
    platform="linux"
fi

TAG="3.7.0"
wget https://github.com/protocolbuffers/protobuf/releases/download/v${TAG}/protoc-${TAG}-${platform}-x86_64.zip -O protoc.zip

if [ $? -eq 0 ]; then
    unzip protoc.zip -d ${GOPATH}/bin/
    rm -f protoc.zip
else
    echo "wget protoc failed."
    exit 1
fi

#GIT_TAG="v1.2.0" # change as needed
#git -C "$(go env GOPATH)"/src/github.com/golang/protobuf checkout $GIT_TAG
go get -d -u github.com/golang/protobuf/protoc-gen-go
go install github.com/golang/protobuf/protoc-gen-go

