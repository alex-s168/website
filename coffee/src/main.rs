use axum::{
    extract::Path,
    response::Json,
    routing::get,
    Router,
};
use reqwest::Client;
use scraper::{Html, Selector};
use serde::Serialize;
use std::net::SocketAddr;

#[derive(Serialize)]
struct PriceResponse {
    price: f64,
}

async fn by_country(Path(country): Path<String>) -> Json<PriceResponse> {
    let url = format!("https://coffeestics.com/countries/{}", country);

    // Fetch the page
    let response = Client::new()
        .get(&url)
        .send()
        .await
        .expect("Failed to fetch page")
        .text()
        .await
        .expect("Failed to get text");

    // Parse HTML
    let document = Html::parse_document(&response);

    // Create selector that matches the element you want
    let selector = Selector::parse("body > div:nth-of-type(1) > div:nth-of-type(1) > section:nth-of-type(3) > div > div > div:nth-of-type(1) > div:nth-of-type(3) > a > div:nth-of-type(2)")
        .unwrap();

    // Extract text and parse as float
    let price_str = document
        .select(&selector)
        .next()
        .expect("Element not found")
        .text()
        .collect::<String>();

    let price: f64 = price_str.trim().trim_start_matches('$')
        .parse()
        .expect("Failed to parse price");

    Json(PriceResponse { price })
}

#[tokio::main]
async fn main() {
    // Build our router
    let app = Router::new()
        .route("/price/:country", get(by_country));

    // Run server
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    println!("Listening on {}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

