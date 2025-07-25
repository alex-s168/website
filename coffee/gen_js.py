import requests
import json

response = requests.get("https://gist.githubusercontent.com/erdem/8c7d26765831d0f9a8c62f02782ae00d/raw/248037cd701af0a4957cce340dabb0fd04e38f4c/countries.json")
response.raise_for_status()
response = json.loads(response.text)

out = ""
for item in response:
    tz = item["timezones"]
    name = item["name"]
    for x in tz:
        out += f"{x}|{name}|"

print("""function userCountry() {
const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
if(tz==null) return null;
const c=\""""+out+"""\".split("|");
for(let i=0;i<c.length;i+=2){
if(c[i]===timezone){
return c[i+1];
}}
return null;
}

async function byCountry(country) {
const url = `http://127.0.0.1:3000/price/${encodeURIComponent(country)}`;

try {
const response = await fetch(url);
if(!response.ok){throw new Error(`HTTP error ${response.status}`);}
const data = await response.json();
return data.price;
} catch (error) {
console.error("Failed to fetch price:", error);
return null;
}}

const c = userCountry();
if(c!=null){
byCountry(c).then(price => console.log("coffe price: " + price));
}
""")
