#!/usr/bin/env bash
# shellcheck disable=SC2312

TARGET=wasm32-unknown-unknown

OUTPUT_DIR="${PWD}/wasm"
CARGO_BUILD_PROFILE="${CARGO_BUILD_PROFILE:-dev}"
PROFILE_ARG="--profile ${CARGO_BUILD_PROFILE}"
PROFILE=debug

BUILD_COMMAND="cargo build --config net.git-fetch-with-cli=true --target=${TARGET} ${PROFILE_ARG}"
BINDGEN_COMMAND="wasm-bindgen --out-dir=${OUTPUT_DIR} --target=bundler --omit-default-module-path ./target/${TARGET}/${PROFILE}/wasm_bindgen_template.wasm"

if ! [[ -d ${OUTPUT_DIR} ]]; then
  mkdir -p "${OUTPUT_DIR}"
fi

if [[ "${OSTYPE}" == "darwin"* ]]; then
  AR_PATH=$(command -v llvm-ar)
  CLANG_PATH=$(command -v clang)
  AR=${AR_PATH} CC=${CLANG_PATH} ${BUILD_COMMAND}
  AR=${AR_PATH} CC=${CLANG_PATH} ${BINDGEN_COMMAND}
else
  ${BUILD_COMMAND}
  ${BINDGEN_COMMAND}
fi

if command -v wasm-opt &> /dev/null; then
  echo "Optimizing wasm using Binaryen"
  wasm-opt -tnh --flatten --rereloop -Oz --gufa -Oz --gufa -Oz  "$OUTPUT_FILE" -o "$OUTPUT_FILE"
else
  echo "wasm-opt command not found. Skipping wasm optimization."
fi