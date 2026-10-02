use std::{
    env,
    error::Error,
    net::{IpAddr, SocketAddr},
    sync::Arc,
};

use axum::{extract::Path, http::StatusCode, response::Json, routing::get, Extension, Router};
use reqwest::Client;
use scraper::{Html, Selector};
use serde::{de::DeserializeOwned, Deserialize, Serialize};

const COUNTRY_PRICE_URL: &str = "https://coffeestics.com/countries";
const USD_EUR_URL: &str = "https://api.frankfurter.dev/v1/latest?base=USD&symbols=EUR";
const ADA_USD_URL: &str =
    "https://api.diadata.org/v1/assetQuotation/Cardano/0x0000000000000000000000000000000000000000";

#[derive(Serialize)]
struct PriceResponse {
    price: f64,
}

#[derive(Deserialize)]
struct ConvRates {
    #[serde(rename = "EUR")]
    eur: f64,
}

#[derive(Deserialize)]
struct ConvResponse {
    rates: ConvRates,
}

#[derive(Deserialize)]
struct CardanoResponse {
    #[serde(rename = "Price")]
    price: f64,
}

struct AppState {
    client: Client,
}

impl AppState {
    fn new() -> Result<Self, reqwest::Error> {
        Ok(Self {
            client: Client::builder().build()?,
        })
    }
}

async fn fetch_json<T: DeserializeOwned>(
    client: &Client,
    url: &str,
) -> Result<T, (StatusCode, String)> {
    let response = client
        .get(url)
        .send()
        .await
        .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))?
        .error_for_status()
        .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))?;

    response
        .json::<T>()
        .await
        .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))
}

async fn usd_eur(
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<PriceResponse>, (StatusCode, String)> {
    let response: ConvResponse = fetch_json(&state.client, USD_EUR_URL).await?;
    Ok(Json(PriceResponse {
        price: response.rates.eur,
    }))
}

async fn ada_usd(
    Extension(state): Extension<Arc<AppState>>,
) -> Result<Json<PriceResponse>, (StatusCode, String)> {
    let response: CardanoResponse = fetch_json(&state.client, ADA_USD_URL).await?;
    Ok(Json(PriceResponse {
        price: response.price,
    }))
}

async fn by_country(
    Extension(state): Extension<Arc<AppState>>,
    Path(country): Path<String>,
) -> Result<Json<PriceResponse>, (StatusCode, String)> {
    let url = format!("{COUNTRY_PRICE_URL}/{country}");
    let response = state
        .client
        .get(url)
        .send()
        .await
        .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))?
        .error_for_status()
        .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))?
        .text()
        .await
        .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))?;

    let document = Html::parse_document(&response);
    let selector = Selector::parse(
        "body > div:nth-of-type(1) > div:nth-of-type(1) > section:nth-of-type(3) > div > div > div:nth-of-type(1) > div:nth-of-type(3) > a > div:nth-of-type(2)",
    )
    .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))?;
    let price_text = document
        .select(&selector)
        .next()
        .ok_or_else(|| (StatusCode::BAD_GATEWAY, "Coffee price not found".to_owned()))?
        .text()
        .collect::<String>();
    let price = price_text
        .trim()
        .trim_start_matches('$')
        .parse::<f64>()
        .map_err(|error| (StatusCode::BAD_GATEWAY, error.to_string()))?;

    Ok(Json(PriceResponse { price }))
}

fn parse_listen_address(ip: &str, port: &str) -> Result<SocketAddr, Box<dyn Error>> {
    Ok(SocketAddr::new(ip.parse::<IpAddr>()?, port.parse::<u16>()?))
}

fn listen_address() -> Result<SocketAddr, Box<dyn Error>> {
    let ip = env::var("COFFEE_BIND").unwrap_or_else(|_| "0.0.0.0".to_owned());
    let port = env::var("COFFEE_PORT").unwrap_or_else(|_| "3000".to_owned());
    parse_listen_address(&ip, &port)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let state = Arc::new(AppState::new()?);
    let app = Router::new()
        .route("/price/:country", get(by_country))
        .route("/usd_eur", get(usd_eur))
        .route("/ada_usd", get(ada_usd))
        .layer(Extension(state));

    let addr = listen_address()?;
    println!("Listening on {addr}");

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::parse_listen_address;

    #[test]
    fn listen_address_supports_custom_ipv4_and_port() {
        let address = parse_listen_address("127.0.0.1", "4321").expect("valid listen address");

        assert_eq!(address.to_string(), "127.0.0.1:4321");
    }

    #[test]
    fn listen_address_supports_ipv6() {
        let address = parse_listen_address("::1", "3000").expect("valid listen address");

        assert_eq!(address.to_string(), "[::1]:3000");
    }
}
