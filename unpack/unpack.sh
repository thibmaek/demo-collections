#!/usr/bin/env bash
set -e

function is_macos() {
  uname -s | grep -iq "darwin"
}

function unpack_tar() { tar xvf "$1"; }
function unpack_tar_gzip() { tar xvf "$1"; }
function unpack_tar_bz2() { tar xvjf "$1"; }
function unpack_gzip() { gunzip -c "$1"; }
function unpack_bz2() { bunzip2 -c "$1"; }
function unpack_zip() { unzip "$1"; }
function unpack_dmg() { hdiutil attach -nobrowse "$1";}
function unpack_xz() {
  if command -v unzx > /dev/null; then
    unxz -c "$1"
  else
    if is_macos; then
      echo "Missing unzx. Install with brew: 'brew install xz'"
    fi
  fi
}
function unpack_rar() {
  if command -v unrar > /dev/null; then
    unrar -idp -y x "$1"
  else
    if is_macos; then
      echo "Missing unrar. Install with brew: 'brew install unrar'"
    fi
  fi
}
function unpack_7zip() {
  if command -v some_command > /dev/null; then
    p7zip -bd x "$1"
  else
    if is_macos; then
      echo "Missing unzx. Install with brew: 'brew install p7zip'"
    fi
  fi
}

function infer_by_mime_type() {
  local mimeType
  mimeType=$(file -b --mime-type "$1")

  case "$mimeType" in
    "application/x-tar") unpack_tar "$1";;
    "application/x-gzip") unpack_gzip "$1";;
    "application/x-bzip2") unpack_bz2 "$1";;
    "application/x-xz") unpack_xz "$1";;
    "application/zip") unpack_zip "$1";;
    *)
      echo "This archive is not supported."
      exit 1
      ;;
  esac
}

function infer_by_file_extension() {
  if [ -z "$1" ]; then
    echo "
No file input given. Please provide a compressed file...
    Usage: ./unpack.sh archive.zip
    "
    # echo "No file input given. Please provide a compressed file..."
    # echo ""
    # echo "    Usage: ./unpack.sh archive.zip"
    exit 1
  fi

  local fileName
  fileName=$(basename "$1")

  echo "📦 Unpacking $fileName ..."

  case "${fileName#*.}" in
    "tar") unpack_tar "$1";;
    "tar.gz"|"tgz") unpack_tar_gzip "$1";;
    "tar.bz2") unpack_tar_bz2 "$1";;
    "tar.xz"|"xz") unpack_tar_xz "$1";;
    "gz") unpack_gzip "$1";;
    "zip"|"jar"|"egg"|"whl") unpack_zip "$1";;
    "rar") unpack_rar "$1";;
    "7z") unpack_7zip "$1";;
    "dmg"|"sparseimage") unpack_dmg "$1";;
    *) infer_by_mime_type "$1";;
  esac
}

# ------------------------------------------------------------------------------
# Universal unpack. Assumes underlying commands will be available to unpack.
# Very much like https://github.com/mitsuhiko/unp/blob/master/unp.py but without
# the dependency on Python (so fully POSIX portable)
#
# Arguments:
#   $1: File path
# ------------------------------------------------------------------------------
infer_by_file_extension "$@"
