// build.rs
//
fn main() {
    println!("cargo:rerun-if-changed=src/mach.c");
    cc::Build::new()
        .file("src/mach.c")
        .flag("-Wno-unused-parameter")
        .flag("-Wno-unused-function")
        .compile("mach");
}
