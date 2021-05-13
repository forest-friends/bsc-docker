#/bin/sh
VERSION=v1.1.0-beta

wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/mainnet.zip
wget https://github.com/binance-chain/bsc/releases/download/${VERSION}/testnet.zip
mkdir -p mainnet testnet
unzip mainnet.zip -d mainnet
unzip testnet.zip -d testnet
rm -rf mainnet.zip testnet.zip