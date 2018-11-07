#!/usr/bin/env bash

set -e

function configure() {
    PCRE_VERSION=8.41
    PCRE_SHA1=dddf0995aefe04cc6267c1448ffef0e7b0560ec0

    # OPENSSL_BRANCH=1.1.0
    # OPENSSL_VERSION=${OPENSSL_BRANCH}g
    # OPENSSL_SHA1=e8240a8be304d4317a750753321b073c664bfdd4

    OPENSSL_BRANCH=1.0.2
    OPENSSL_VERSION=${OPENSSL_BRANCH}m
    OPENSSL_SHA1=27fb00641260f97eaa587eb2b80fab3647f6013b

    OPENRESTY_VERSION=1.11.2.4
    OPENRESTY_SHA1=7449c57cf53e3ac963736b7e0333c929688b5bfc

    LUAROCKS_VERSION=2.4.3
    LUAROCKS_SHA1=bca49adca574b4a163e4fb10909fd7fc47b6c7ea

    GIT_VERSION=2.9.5
    GIT_SHA1=278eae9d50f89a519522f6b288cabcb5ca583ef6

    KONG_VERSION=0.11.1
    KONG_SHA1=dc93c2fa4582ec23060b057786fbc6102cbfd4d9
}

function main() {
    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    readonly SCRIPT_DIR
    RELEASE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
    readonly RELEASE_DIR

    configure

    mkdir -p "${RELEASE_DIR}/tmp"
    pushd "${RELEASE_DIR}/tmp" > /dev/null

        local blob_file
        set -x

        blob_file="pcre-${PCRE_VERSION}.tar.gz"
        add_blob "pcre" "${blob_file}" "openresty/${blob_file}"

        blob_file="openssl-${OPENSSL_VERSION}.tar.gz"
        add_blob "openssl" "${blob_file}" "openresty/${blob_file}"

        blob_file="openresty-${OPENRESTY_VERSION}.tar.gz"
        add_blob "openresty" "${blob_file}" "openresty/${blob_file}"

        blob_file="luarocks-${LUAROCKS_VERSION}.tar.gz"
        add_blob "luarocks" "${blob_file}" "kong/${blob_file}"

        blob_file="git-${GIT_VERSION}.tar.gz"
        add_blob "git" "${blob_file}" "kong/${blob_file}"

        blob_file="kong-${KONG_VERSION}.tar.gz"
        add_blob "kong" "${blob_file}" "kong/${blob_file}"

    popd > /dev/null
}

function add_blob() {
    local blob_name=$1
    local blob_file=$2
    local blob_path=$3

    if [[ ! -f "${blob_file}" ]]; then
        "download_${blob_name}"
    fi
    bosh add-blob --dir="${RELEASE_DIR}" "${blob_file}" "${blob_path}"
}

function download_pcre() {
    curl -fsSL "https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz" \
        -o "pcre-${PCRE_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${PCRE_SHA1}  pcre-${PCRE_VERSION}.tar.gz"
}

function download_openssl() {
    curl -fsSL "https://www.openssl.org/source/old/${OPENSSL_BRANCH}/openssl-${OPENSSL_VERSION}.tar.gz" \
        -o "openssl-${OPENSSL_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${OPENSSL_SHA1}  openssl-${OPENSSL_VERSION}.tar.gz"
}

function download_openresty() {
    curl -fsSL "https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz" \
        -o "openresty-${OPENRESTY_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${OPENRESTY_SHA1}  openresty-${OPENRESTY_VERSION}.tar.gz"
}

function download_luarocks() {
    curl -fsSL "http://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz" \
        -o "luarocks-${LUAROCKS_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${LUAROCKS_SHA1}  luarocks-${LUAROCKS_VERSION}.tar.gz"
}

function download_git() {
    curl -fsSL "https://mirrors.edge.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz" \
        -o "git-${GIT_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${GIT_SHA1}  git-${GIT_VERSION}.tar.gz"
}

function download_kong() {
    curl -fsSL "https://github.com/Kong/kong/archive/${KONG_VERSION}.tar.gz" \
        -o "kong-${KONG_VERSION}.tar.gz"
    shasum -a 256 --check <<< "${KONG_SHA1}  kong-${KONG_VERSION}.tar.gz"
}

main "$@"
