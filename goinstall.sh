tar zxvf src.tar
originalGOPATH=${GOPATH}
currentDir="$(pwd)"
echo ${currentDir}
export GOPATH=${currentDir}
echo ${GOPATH}

go install golang.org/x/tools/cmd/guru
go install github.com/zmb3/gogetdoc
go install github.com/davidrjenni/reftools/cmd/fillstruct
go install github.com/rogpeppe/godef
go install github.com/fatih/motion
go install github.com/kisielk/errcheck
go install github.com/nsf/gocode
go install github.com/jstemmer/gotags
go install github.com/josharian/impl
go install golang.org/x/tools/cmd/goimports
go install github.com/fatih/gomodifytags
go install github.com/dominikh/go-tools/cmd/keyify
go install golang.org/x/tools/cmd/gorename
go install github.com/klauspost/asmfmt/cmd/asmfmt
go install github.com/alecthomas/gometalinter
go install github.com/golang/lint/golint

cp -r ${currentDir}/bin/* ${originalGOPATH}/bin/
