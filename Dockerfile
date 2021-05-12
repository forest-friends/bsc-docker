FROM golang:alpine as build

WORKDIR /usr/share/bsc
ARG VERSION
RUN apk add --no-cache make gcc musl-dev linux-headers git bash
RUN git clone --depth 1 -b "${VERSION}" --single-branch https://github.com/binance-chain/bsc.git
RUN cd bsc && make geth
RUN wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/mainnet.zip && \
    wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/testnet.zip
RUN mkdir mainnet testnet && unzip mainnet.zip -d mainnet && unzip testnet.zip -d testnet
RUN chmod +x /usr/share/bsc/bsc/build/bin/geth

FROM alpine:latest
WORKDIR /usr/share/bsc
COPY --from=build /usr/share/bsc/bsc/build/bin/geth /usr/share/bsc/geth
COPY --from=build /usr/share/bsc/mainnet /usr/share/bsc/mainnet
COPY --from=build /usr/share/bsc/testnet /usr/share/bsc/testnet
CMD [ "/usr/share/bsc/geth" ]