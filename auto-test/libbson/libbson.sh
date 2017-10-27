#!/bin/bash
. ../../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/libbson.txt"
LOGFILE="${OUTPUT}/compilation.txt"
export RESULT_FILE
pkg-cf="https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
install_pkg-config(){
    wget ${pkg-cf}
    tar xzf pkg-config-0.29.2.tar.gz
    cd pkg-config-0.29.2
    ./configure --with-internal-glib
    cd -
}
usage() {
    echo "Usage: $0  [-s true|false]" 1>&2
    exit 1
}

while getopts "s:h" o; do
    case "$o" in
        s) SKIP_INSTALL="${OPTARG}" ;;
        h|*) usage ;;
    esac
done
dist_name
case "${dist}" in
    centos) pkgs="libbson libbson-devel";;
esac
! check_root && error_msg "You need to be root to install packages!"
install_deps "${pkgs}" "${SKIP_INSTALL}"
creat_out_dir "${output}"
cd "${OUTPUT}"
install_pkg-config
cp ../hello_bson.c .
gcc -o hello_bson hello_bson.c $(pkg-config --cflags --libs libbson-1.0 ) | tee "${LOGFILE}"
command="./hello_bson | grep -x 'bson'"
skip_list="execute_binary"
run_test_case "${command}" "${skip_list}"
remove_pkg "${pkgs}"
rm -rf pkg-config-0.29.2