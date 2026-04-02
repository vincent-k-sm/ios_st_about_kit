#!/bin/bash
# generate-licenses.sh
# SPM 체크아웃 디렉토리에서 LICENSE 파일을 수집하여 Licenses.json 생성
# Xcode Build Phase에서 실행:
#   bash ${BUILD_DIR%Build/*}SourcePackages/checkouts/../../../Scripts/generate-licenses.sh
# 또는 직접:
#   bash /path/to/generate-licenses.sh

set -e

# SPM 체크아웃 경로 (Xcode 빌드 환경)
if [ -n "$BUILD_DIR" ]; then
    CHECKOUTS_DIR="${BUILD_DIR%Build/*}SourcePackages/checkouts"
    OUTPUT_DIR="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
else
    echo "error: BUILD_DIR not set. Run this script from Xcode Build Phase."
    exit 1
fi

OUTPUT_FILE="${OUTPUT_DIR}/Licenses.json"

if [ ! -d "$CHECKOUTS_DIR" ]; then
    echo "warning: SPM checkouts not found at $CHECKOUTS_DIR"
    echo "[]" > "$OUTPUT_FILE"
    exit 0
fi

# JSON 배열 시작
JSON="["
FIRST=true

for PKG_DIR in "$CHECKOUTS_DIR"/*/; do
    [ -d "$PKG_DIR" ] || continue

    PKG_NAME=$(basename "$PKG_DIR")
    LICENSE_TEXT=""

    # LICENSE 파일 검색
    for CANDIDATE in LICENSE LICENSE.md LICENSE.txt LICENCE LICENCE.md License license MIT-LICENSE COPYING; do
        if [ -f "${PKG_DIR}${CANDIDATE}" ]; then
            LICENSE_TEXT=$(cat "${PKG_DIR}${CANDIDATE}")
            break
        fi
    done

    [ -z "$LICENSE_TEXT" ] && continue

    # JSON 이스케이프
    ESCAPED=$(echo "$LICENSE_TEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        JSON+=","
    fi

    JSON+=$(printf '\n  {"name": "%s", "license": %s}' "$PKG_NAME" "$ESCAPED")
done

JSON+="\n]"

# 출력
mkdir -p "$OUTPUT_DIR"
echo -e "$JSON" > "$OUTPUT_FILE"
echo "Generated $(grep -c '"name"' "$OUTPUT_FILE") licenses -> $OUTPUT_FILE"
