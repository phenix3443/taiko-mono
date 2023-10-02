#!/bin/bash

# Generate go contract bindings.
# ref: https://geth.ethereum.org/docs/dapp/native-bindings

set -eou pipefail

script_dir="$(realpath "$(dirname $0)")"
protocol_dir="$(realpath "${script_dir}/..")"
go_bindings_dir=$(realpath "${protocol_dir}/bindings")

function compile_protocol() {
    cd "${protocol_dir}" &&
        pnpm install &&
        pnpm compile &&
        cd -
}

function extract_abi_json() {
    l1_abi_json="${script_dir}/l1_abi.json"
    l2_abi_json="${script_dir}/l2_abi.json"
    taiko_token_abi_json="${script_dir}/token_abi.json"
    jq .abi "${protocol_dir}/out/TaikoL1.sol/TaikoL1.json" >"${l1_abi_json}"
    jq .abi "${protocol_dir}/out/TaikoL2.sol/TaikoL2.json" >"${l2_abi_json}"
    jq .abi "${protocol_dir}/out/TaikoToken.sol/TaikoToken.json" >"${taiko_token_abi_json}"
}

function gen_go_bindings() {
    abigen --abi "${l1_abi_json}" --type TaikoL1Client --pkg bindings --out "${go_bindings_dir}/gen_taiko_l1.go.go"
    abigen --abi "${l2_abi_json}" --type TaikoL2Client --pkg bindings --out "${go_bindings_dir}/gen_taiko_l2.go.go"
    abigen --abi "${taiko_token_abi_json}" --type TaikoToken --pkg bindings --out "${go_bindings_dir}/gen_taiko_token.go"

    echo "🍻 Go contract bindings generated!"
}

function clean() {
    rm "${l1_abi_json}" "${l2_abi_json}" "${taiko_token_abi_json}"
}

echo ""
echo "Start generating go contract bindings..."
echo ""

if [ ! "$(command -v abigen)" ]; then
    echo "command \"abigen\" not exists on system"
fi

compile_protocol
extract_abi_json
gen_go_bindings
clean
