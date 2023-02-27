#!/usr/bin/env bash

set -euo pipefail

# tool name
TOOL_NAME="SoapUI"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

# get_download_url() {
#   local version="$1"
#   local platform="$2"
#   local filename
#   filename="$(get_filename "$version" "$platform")"
#   url="https://dl.eviware.com/soapuios/${version}/${filename}"
#   echo "URL ==> $url"
#   echo "* Downloading $TOOL_NAME release $version..."
#   curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
#   # echo "https://dl.eviware.com/soapuios/${version}/${filename}"
# }

download_release() {
  local version="$1"
  local download_path="$2"
  local -r platform=$(get_platform)
  local filename
  filename="$(get_filename "$version" "$platform")"
  url="https://dl.eviware.com/soapuios/${version}/${filename}"
  echo "URL ==> $url"
  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$download_path" -C - "$url" || fail "Could not download $url"
  # curl -Lo "$download_path" "$url"
}


list_all_versions() {
  
  # Refered form here https://github.com/webofmars/asdf-velero/

  soapui_versions=smartbear/soapui
  releases_path="https://api.github.com/repos/${soapui_versions}/releases"
  echo "RELEASE PATH $releases_path"
  cmd="curl -s"
  
  cmd="$cmd $releases_path"

  function sort_versions() {
    sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' | \
      LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
  }

  # Fetch all tag names, and get only second column. Then remove all unnecesary characters.
  versions=$(eval "$cmd" | grep -oE "tag_name\": *\".{1,15}\"," | sed 's/tag_name\": *\"//;s/\",//' | sort_versions)
  # shellcheck disable=SC2086
  echo $versions
}


# get_binary_path_in_archive(){
#   local archive_dir=$1
#   local version=$2
#   local platform=$3

#   echo "$archive_dir/$TOOL_NAME-${version}-${platform}"
# }

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
  
   # make a temporary download directory with a cleanup hook
  # TMP_DOWNLOAD_DIR="$(mktemp -d -t "asdf_${TOOL_NAME}_XXXXXX")"
  # readonly TMP_DOWNLOAD_DIR
  # trap 'rm -rf "${TMP_DOWNLOAD_DIR?}"' EXIT


  if [ "$install_type" != "version" ]; then
    fail "asdf-soapui supports release installs only"
  fi

  # local -r bin_install_path="${install_path}/bin"
  # local -r platform=$(get_platform)
  # local -r download_url=$(get_download_url "$version" "$platform")
  # local -r download_path="${TMP_DOWNLOAD_DIR}/${version}"

  # echo "Downloading [${TOOL_NAME} $version] from ${download_url} to ${download_path}"
  # curl -Lo "$download_path" "$download_url"
  # tar -zxvf SoapUI-5.7.0-linux-bin.tar.gz -C /Users/andavar.veeramalai/repos/asdf-soapui/bin/temp
  (
    # echo "Cleaning ${TOOL_NAME} previous binaries"
    # rm -rf "${install_path:?}/${TOOL_NAME}"

    echo "Creating ${TOOL_NAME} bin directory"
    mkdir -p "${install_path}"
    chmod +x "$ASDF_DOWNLOAD_PATH/$TOOL_NAME-$version"
    echo "Extracting archive"
    if [[ $platform == "linux" ]] || [[ $platform == "darwin" ]]|| [[ $platform == "macos" ]]; then 
      tar -zxvf "$ASDF_DOWNLOAD_PATH" -C "$ASDF_DOWNLOAD_PATH/$TOOL_NAME-$version"
    else 
      unzip -qq "${ASDF_DOWNLOAD_PATH}" -d "${install_path}"
    fi
      
    echo "Copying binary"
    # echo "${TMP_DOWNLOAD_DIR}"
    # echo "${download_path}"
    # echo "${bin_install_path}"
    pwd
    # cp "${TMP_DOWNLOAD_DIR}" "${bin_install_path}"
    
    cp "$ASDF_DOWNLOAD_PATH/$TOOL_NAME-$version" "${install_path}"
    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
