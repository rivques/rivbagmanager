use std::fs;
use std::path::Path;
use std::io::Write;
use reqwest;

fn main() {
    // Fetch the .proto file from a remote URL
    let proto_url = "https://raw.githubusercontent.com/hackclub/bag/main/proto/bag.proto";
    let proto_file = reqwest::blocking::get(proto_url)
        .expect("Failed to fetch proto file")
        .text()
        .expect("Failed to read proto file");

    // Write the .proto file to the src directory
    let proto_path = Path::new("src").join("bag.proto");
    let mut file = fs::File::create(&proto_path)
        .expect("Failed to create proto file");
    file.write_all(proto_file.as_bytes())
        .expect("Failed to write proto file");

    // Generate Rust code from the .proto file
    tonic_build::configure()
        .build_server(false)
        .protoc_arg("--experimental_allow_proto3_optional")
        .compile(&[proto_path.to_str().unwrap()], &["src"])
        .expect("Failed to compile proto file");
}
