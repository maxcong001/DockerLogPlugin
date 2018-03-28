FROM  golang:1.9.2

#ENV http_proxy 135.245.48.34:8000
#ENV https_proxy 135.245.48.34:8000

WORKDIR /go/src/github.com/maxcong001/dockerlogplugin/

COPY . /go/src/github.com/maxcong001/dockerlogplugin/


RUN cd /go/src/github.com/maxcong001/dockerlogplugin/ && go get

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /bin/dockerlogplugin .

FROM alpine:3.7
RUN apk --no-cache add ca-certificates
COPY --from=0 /bin/dockerlogplugin /bin/
WORKDIR /bin/
ENTRYPOINT [ "/bin/dockerlogplugin" ]
