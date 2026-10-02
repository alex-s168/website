import json

with open("build-input/countries.json", "r") as f:
    response = json.load(f)

out = ""
for item in response:
    tz = item["timezones"]
    name = item["name"]
    for x in tz:
        out += f"{x}|{name}|"

print("""
function userCountry() {
  const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  if(tz==null) return null;
  const c=\""""+out+"""\".split("|");
  for(let i=0;i<c.length;i+=2){
    if(c[i]===tz){
      return c[i+1];
    }
  }
  return null;
}

async function byCountry(country) {
  const url = `/coffee/price/${encodeURIComponent(country)}`;
  try {
    const response = await fetch(url);
    if(!response.ok){throw new Error(`HTTP error ${response.status}`);}
    const data = await response.json();
    return data.price;
  } catch (error) {
    console.error("Failed to fetch coffee price (assuming 1.6$):", error);
    return 1.6;
  }
}

async function usd_eur() {
  const url = `/coffee/usd_eur`;
  try {
    const response = await fetch(url);
    if(!response.ok){throw new Error(`HTTP error ${response.status}`);}
    const data = await response.json();
    return data.price;
  } catch (error) {
    console.error("Failed to fetch usd<->eur conversion rate, guessing 1$ = 0.86€:", error);
    return 0.86;
  }
}

async function ada_usd() {
  const url = `/coffee/ada_usd`;
  try {
    const response = await fetch(url);
    if(!response.ok){throw new Error(`HTTP error ${response.status}`);}
    const data = await response.json();
    return data.price;
  } catch (error) {
    console.error("Failed to fetch usd<->eur conversion rate, guessing 1 ada = 0.4$:", error);
    return 0.4;
  }
}

let coffee = ({
  country: null,
  coffee_usd: 1.6,
  usd_eur: 0.7,
  ada_usd: 0.4,
});

coffee.country = userCountry();
if (coffee.country != null){
  byCountry(coffee.country).then(price => {
    coffee.coffee_usd = price;
    on_coffee_update.forEach((x) => x(coffee));
  });
}

usd_eur().then(price => {
  coffee.usd_eur = price;
  on_coffee_update.forEach((x) => x(coffee));
});

ada_usd().then(price => {
  coffee.ada_usd = price;
  on_coffee_update.forEach((x) => x(coffee));
});

on_coffee_update.forEach((x) => x(coffee));
""")
