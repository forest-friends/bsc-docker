FROM golang:alpine as build

WORKDIR /build
ARG VERSION
RUN apk add --no-cache make gcc musl-dev linux-headers git bash
RUN git clone --depth 1 -b "${VERSION}" --single-branch https://github.com/binance-chain/bsc.git
RUN cd bsc && make geth && cp /build/bsc/build/bin/geth /build && chmod +x /build/geth
RUN mkdir -p mainnet/data mainnet/config testnet/data testnet/config && \
    wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/mainnet.zip && \
    wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/testnet.zip && \
    unzip mainnet.zip -d mainnet/config && unzip testnet.zip -d testnet/config && rm -rf mainnet.zip testnet.zip bsc
RUN /build/geth --datadir mainnet/data init mainnet/config/genesis.json
RUN /build/geth --datadir testnet/data init testnet/config/genesis.json
RUN sed '/\[Node.LogConfig\]/d;/File[Root|Path]/d;/MaxBytesSize/d;/Level/d;/DataDir/d;/NoUSB/d;/IPCPath/d;/HTTPHost/d;/HTTPVirtualHosts/d;/InsecureUnlockAllowed/d;/HTTPPort/d;/HTTPModules/d;/WSPort/d;/WSModules/d;/\[Node\]/d;s/PriceLimit = 1000000000/PriceLimit = 2000000000/;s/GasPrice = 1000000000/GasPrice = 2000000000/' testnet/config/config.toml > testnet/config/config-pure.toml && \
    sed '/\[Node.LogConfig\]/d;/File[Root|Path]/d;/MaxBytesSize/d;/Level/d;/DataDir/d;/NoUSB/d;/IPCPath/d;/HTTPHost/d;/HTTPVirtualHosts/d;/InsecureUnlockAllowed/d;/HTTPPort/d;/HTTPModules/d;/WSPort/d;/WSModules/d;/\[Node\]/d;s/PriceLimit = 1000000000/PriceLimit = 5000000000/;s/GasPrice = 1000000000/GasPrice = 5000000000/' mainnet/config/config.toml > mainnet/config/config-pure.toml

RUN cat testnet/config/config-pure.toml
RUN cat mainnet/config/config-pure.toml

FROM alpine:latest
WORKDIR /usr/share/bsc
COPY --from=build /build .
ENTRYPOINT [ "/usr/share/bsc/geth" ]
