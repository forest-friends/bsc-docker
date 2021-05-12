FROM alpine:latest as fetcher
ARG VERSION
RUN wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/geth_linux && \
    wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/mainnet.zip && \
    wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/testnet.zip && \
    chmod +x geth_linux
RUN mkdir mainnet testnet && unzip mainnet.zip -d mainnet && unzip testnet.zip -d testnet

FROM alpine:latest
COPY --from=fetcher . .
ENTRYPOINT [ "geth_linux" ]