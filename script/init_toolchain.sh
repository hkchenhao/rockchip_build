#!/bin/bash -e

requirement_packages=("bc" "bison" "build-essential" "cpio" "device-tree-compiler" "flex" \
                      "libelf-dev" "libncurses-dev" "libssl-dev" "lz4" "make")
install_packages=

case "$(uname -m)" in
x86_64*)
  requirement_packages+=("gcc")
  ;;
aarch64*)
  requirement_packages+=("gcc-aarch64-linux-gnu")
  ;;
*)
  echo "Error: Cannot init toolchain on $(uname -m) host."
  return 1
  ;;
esac

for package in "${requirement_packages[@]}"; do
  if ! dpkg -s "${package}" > /dev/null 2>&1; then
    install_packages="$install_packages ${install_packages}"
  fi
done

if [ -n "${install_packages}" ]; then
  sudo apt install -y "${install_packages}"
fi
