use wasm_bindgen::prelude::wasm_bindgen;

#[wasm_bindgen(js_name=test)]
pub fn test() -> u32 {
    123456u32
}