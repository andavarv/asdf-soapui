#!/usr/bin/env bash

set -euo pipefail

# tool name
TOOL_NAME="SoapUI"
GH_REPO="https://github.com/SmartBear/soapui"


fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/v.*' | cut -d/ -f3- |
    sed 's/^v//' | grep -Ev 'beta|rc'
}

list_all_versions() {
  list_github_tags
}

get_download_url() {
  local version="$1"
  local platform="$2"
  local filename
  filename="$(get_filename "$version" "$platform")"
  url="https://dl.eviware.com/soapuios/${version}/${filename}"
  
  echo "https://dl.eviware.com/soapuios/${version}/${filename}"
}

download_release() {
  local version="$1"
  local download_path="$2"
  local -r platform=$(get_platform)
  local filename
  filename="$(get_filename "$version" "$platform")"
  url="https://dl.eviware.com/soapuios/${version}/${filename}"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$download_path/$filename" -C - "$url" || fail "Could not download $url"
  
}

get_platform() {
  local -r kernel="$(uname -s)"
  if [[ ${OSTYPE} == "msys" || ${kernel} == "CYGWIN"* || ${kernel} == "MINGW"* ]]; then
    echo windows
  else
    uname | tr '[:upper:]' '[:lower:]'
  fi
}

get_filename() {
  local version="$1"
  local platform="$2"
  
  case "${platform}" in
    linux)
      echo "${TOOL_NAME}-${version}-${platform}-bin.tar.gz"
      ;;
    windows)
      echo "${TOOL_NAME}-${version}-${platform}-bin.zip"
      ;;
    mac)
      echo "${TOOL_NAME}-${version}-${platform}-bin.zip"
      ;;
    *)
      echo "${TOOL_NAME}-${version}-linux-bin.tar.gz"
      ;;
  esac
}


install_version() {
  local -r install_type="$1"
  local -r version="$2"
  local install_path="${3%/bin}/bin"
  local -r platform=$(get_platform)
  local -r filename="$(get_filename "$version" "$platform")"
   

  if [ "$install_type" != "version" ]; then
    fail "asdf-soapui supports release installs only"
  fi

  (
    # echo "Cleaning ${TOOL_NAME} previous binaries"
    # rm -rf "${install_path:?}/${TOOL_NAME}"

    echo "Creating ${TOOL_NAME} bin directory"
    mkdir -p "${install_path}"
    
    echo "Extracting archive"
    if [[ $platform == "linux" ]] || [[ $platform == "darwin" ]]|| [[ $platform == "macos" ]]; then 
      tar zxvf "$ASDF_DOWNLOAD_PATH/$filename" -C "$ASDF_DOWNLOAD_PATH"
    else 
      unzip -qq "${ASDF_DOWNLOAD_PATH}" -d "${install_path}"
    fi
    
    
    echo "Copying binary"
    
    chmod +x "$ASDF_DOWNLOAD_PATH/$TOOL_NAME-$version"
    cp -Rv "$ASDF_DOWNLOAD_PATH/$TOOL_NAME-$version" "${install_path}"

    local tool_cmd="testrunner.sh"
    # tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    # test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."
    test -f "${install_path}/$TOOL_NAME-$version/bin/${tool_cmd}" || fail "$install_path/$TOOL_NAME-$version/bin/$tool_cmd file not found."
    
    pushd "${HOME}/.asdf/plugins"
      # echo "plugin path ==> ${ASDF_PLUGIN_PATH}"
      pwd
      ls -a
    popd
    
    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
