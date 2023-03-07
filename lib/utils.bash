#!/usr/bin/env bash

set -euo pipefail

# tool name
GH_REPO="https://github.com/SmartBear/soapui"
DL_URL="https://dl.eviware.com/soapuios"
TOOL_NAME="SoapUI"
TOOL_TEST="bin/testrunner.sh"

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

download_release() {
  local version="$1"
  local download_path="$2"

  local -r platform=$(get_platform)
  local -r url="$(get_download_url "$version" "$platform")"
  local -r filename="$(get_filename "$version" "$platform")"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$download_path/$filename" -C - "$url" || fail "Could not download $url"

  (
    if [[ $platform == "linux" ]] || [[ $platform == "darwin" ]] || [[ $platform == "macos" ]]; then
      tar zxf "$ASDF_DOWNLOAD_PATH/$filename" -C "$ASDF_DOWNLOAD_PATH" --strip-components=1
    else
      unzip -qq "${ASDF_DOWNLOAD_PATH}/$filename" -d "${install_path}"
    fi
  ) || fail "Could not extract $ASDF_DOWNLOAD_PATH/$filename"
}

get_download_url() {
  local version="$1"
  local platform="$2"

  local -r filename="$(get_filename "$version" "$platform")"

  url="$DL_URL/$version/$filename"
  echo "$url"
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
    echo "${TOOL_NAME}-${version}-linux-bin.tar.gz"
    ;;
  windows)
    echo "${TOOL_NAME}-${version}-windows-bin.zip"
    ;;
  darwin | macos)
    echo "${TOOL_NAME}-${version}-mac-bin.zip"
    ;;
  *)
    echo "${TOOL_NAME}-${version}-linux-bin.tar.gz"
    ;;
  esac
}

install_version() {
  local -r install_type="$1"
  local -r version="$2"
  local install_path="$3"

  local -r platform=$(get_platform)
  local -r filename="$(get_filename "$version" "$platform")"

  if [ "$install_type" != "version" ]; then
    fail "asdf-soapui supports release installs only"
  fi

  (
    mkdir -p "${install_path}"
    # echo $install_path
    # echo $ASDF_DOWNLOAD_PATH

    cp -R "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."
    echo "$TOOL_NAME $version installation was successful!"
    pwd
    ls -aR
    if [ "$platform" != "linux" ]; then
      echo "DOWNload path $ASDF_DOWNLOAD_PATH"
      echo "INStall path $install_path"
      echo "INStall HOME path ${HOME}"
      pushd "${HOME}/.asdf/installs"
      pwd
    
      popd
    fi


  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
