use tonic::transport::Channel;
use dotenv;

use crate::bag::{bag_service_client::BagServiceClient, GetInventoryRequest};

// Import the generated code
pub mod bag {
    tonic::include_proto!("bag");
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv::dotenv().ok();
    let app_id: i32 = std::env::var("APP_ID").expect("APP_ID must be set in .env").parse().expect("APP_ID must be a number");
    let app_key = std::env::var("APP_KEY").expect("APP_KEY must be set in .env");

    // Connect to the server
    let channel = Channel::from_static("https://bag-7oiuqlq3ba-uk.a.run.app")
        .connect()
        .await?;
    println!("Connected to the server!");

    // Create a client
    let mut client = BagServiceClient::new(channel);
    println!("Client created!");

    // Prepare the request
    let request = tonic::Request::new(GetInventoryRequest{
        app_id: app_id,
        key: app_key,
        identity_id: "U05PYFCJXV0".to_string(),
        available: true,
    });
    println!("Request prepared!");
    // Send the request to the server
    let response = client.get_inventory(request).await?;

    // Process the response
    println!("RESPONSE: {:?}", response);

    Ok(())
}