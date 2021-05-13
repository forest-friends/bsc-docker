FROM golang:alpine as build

WORKDIR /build
ARG VERSION
RUN apk add --no-cache make gcc musl-dev linux-headers git bash
RUN git clone --depth 1 -b "${VERSION}" --single-branch https://github.com/binance-chain/bsc.git
RUN cd bsc && make geth && cp /build/bsc/build/bin/geth /build && chmod +x /build/geth
RUN mkdir mainnet testnet && \
    wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/mainnet.zip && \
    wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/testnet.zip && \
    unzip mainnet.zip -d mainnet && unzip testnet.zip -d testnet && rm -rf mainnet.zip testnet.zip bsc
RUN /build/geth --datadir mainnet init mainnet/genesis.json && \
    /build/geth --datadir testnet init testnet/genesis.json
RUN sed '/\[Node.LogConfig\]/d;/File[Root|Path]/d;/MaxBytesSize/d;/Level/d;/DataDir/d;/NoUSB/d;/IPCPath/d;/HTTPHost/d;/HTTPVirtualHosts/d;/InsecureUnlockAllowed/d;/HTTPPort/d;/HTTPModules/d;/WSPort/d;/WSModules/d;/\[Node\]/d' testnet/config.toml > testnet/config-pure.toml && \
    sed '/\[Node.LogConfig\]/d;/File[Root|Path]/d;/MaxBytesSize/d;/Level/d;/DataDir/d;/NoUSB/d;/IPCPath/d;/HTTPHost/d;/HTTPVirtualHosts/d;/InsecureUnlockAllowed/d;/HTTPPort/d;/HTTPModules/d;/WSPort/d;/WSModules/d;/\[Node\]/d' mainnet/config.toml > mainnet/config-pure.toml

FROM alpine:latest
WORKDIR /usr/share/bsc
COPY --from=build /build .
ENTRYPOINT [ "/usr/share/bsc/geth" ]