# Predictive Maintenance System — Frontend Dashboard

Industrial fleet monitoring dashboard for the Predictive Maintenance API. Built with vanilla HTML, Tailwind CSS, and vanilla JS. No build step, no framework — deploys as a static site via Nginx on Railway.

**Live Dashboard:** `https://predictivemaintenancefrontend-v2-production.up.railway.app`  
**Backend API:** `https://predictivemaintenance-v2-production.up.railway.app`  
**API Docs:** `https://predictivemaintenance-v2-production.up.railway.app/docs`

---

## What it does

A real-time fleet monitoring dashboard that calls the live ML backend and displays predictions for every machine. No mock data — every health score, RUL, and failure probability on screen comes directly from the Random Forest model running on Railway.

---

## Screenshots

| Fleet Overview | Machine Detail | Alerts Center |
|---|---|---|
| Health gauges, RUL, failure risk per machine | Full failure mode breakdown + re-prediction form | All machines ranked by severity |

---

## Pages

### Fleet Overview (`index.html`)
- Grid of 4 machine cards — circular health gauge, RUL in cycles, failure risk %, status badge
- Summary strip — average fleet health score, total active alerts, average RUL
- Click **Diagnostics** on any card → prediction modal with live API call
- Modal pre-fills sensor values from machine defaults; user can edit and re-run
- **View Full Diagnostics** passes result to machine detail page via URL params
- Auto-refreshes every 60 seconds

### Machine Detail (`machine.html`)
- Large circular health gauge (0–100, colour coded green/amber/red)
- All 6 failure mode probabilities as animated progress bars
- RUL and service status displayed prominently
- Active alerts panel with full alert messages
- Live re-prediction form — change any sensor value, submit, page updates instantly
- Receives initial data via URL params from fleet overview (zero extra API calls on load)

### Alerts Center (`alerts.html`)
- All machines loaded and ranked: Critical → Warning → Healthy
- Summary badge counts per severity level
- Full alert messages per machine with failure risk and RUL
- Direct link to machine detail for every machine

---

## Project Structure

```
├── index.html      # Fleet overview dashboard
├── machine.html    # Machine detail + re-prediction form
├── alerts.html     # Alert center sorted by severity
├── nginx.conf      # Nginx static file server (port 80)
├── Dockerfile      # Nginx alpine container
└── railway.toml    # Railway deployment config
```

---

## Running Locally

No install needed:

```bash
python -m http.server 3000
```

Then open `http://localhost:3000`

> ⚠️ Do not open `index.html` directly as `file://` — browsers block cross-origin API calls from local files.

---

## Configuration

### Changing the API endpoint

All three pages share one constant at the top of their `<script>` tag:

```javascript
const API = 'https://predictivemaintenance-v2-production.up.railway.app';
```

Change this to point to any other running instance of the backend (e.g. `http://localhost:8000` for local dev).

### Adding or removing machines

The machine list is defined in `index.html` and `alerts.html`:

```javascript
const MACHINES = [
  {
    id: 'TRB-A1', name: 'Turbine-A1', sector: 'Sector 07 / Power Gen',
    type: 'H',
    defaults: { air: 298.1, proc: 310.5, rpm: 1408, torque: 52.1, wear: 180 }
  },
  {
    id: 'CMP-B4', name: 'Compressor-B4', sector: 'Sector 02 / Gas Processing',
    type: 'M',
    defaults: { air: 297.8, proc: 308.6, rpm: 1551, torque: 42.8, wear: 0 }
  },
  {
    id: 'PMP-C9', name: 'Pump-Station-C', sector: 'Sector 09 / Hydraulics',
    type: 'L',
    defaults: { air: 300.2, proc: 311.3, rpm: 1285, torque: 65.4, wear: 240 }
  },
  {
    id: 'DRL-A1', name: 'Drill-Rig-Alpha', sector: 'Sector 01 / Excavation',
    type: 'M',
    defaults: { air: 296.9, proc: 307.1, rpm: 1623, torque: 38.2, wear: 45 }
  },
];
```

| Field | Description |
|---|---|
| `id` | Unique machine identifier (used in URL params) |
| `name` | Display name shown on cards |
| `sector` | Location label shown below name |
| `type` | Machine quality type: `L`, `M`, or `H` |
| `defaults` | Default sensor readings used for auto-refresh predictions |

---

## How data flows

```
Page load
    │
    ▼
fetchMachine() × 4 machines (parallel)
    │
    ├── POST /predict → Railway API
    │       └── Returns: health_score, rul_cycles, failure_probabilities, alerts
    │
    ▼
renderCards() — injects live data into machine cards
    │
    ▼
User clicks Diagnostics
    │
    ├── Opens modal with pre-filled sensor form
    ├── User edits values → POST /predict → updates card + shows result
    └── "View Full Diagnostics" → machine.html?health=...&fp=...&alerts=...
                                        │
                                        └── machine.html reads URL params
                                            No extra API call needed
```

---

## Deployment (Railway)

Deployed as a second service in the same Railway project as the backend.

To update the dashboard:

```bash
git add .
git commit -m "update: <description>"
git push
```

Railway redeploys automatically on every push to `main`.

### Infrastructure

Nginx Alpine container on port 80. Railway handles SSL termination and provides the public `https://` domain.

```dockerfile
FROM nginx:alpine
COPY index.html machine.html alerts.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## Role permissions

| Feature | Operator | Engineer |
|---|---|---|
| View fleet overview | ✅ | ✅ |
| Run live prediction | ✅ | ✅ |
| View machine detail | ✅ | ✅ |
| Edit sensor values | ✅ | ✅ |
| View alert center | ✅ | ✅ |

> Note: The current version has no authentication. All pages are publicly accessible. Authentication can be added by gating the API with JWT and storing the token in `sessionStorage`.

---

## Tech Stack

`HTML5` · `Tailwind CSS (CDN)` · `Vanilla JS (ES2022)` · `Nginx Alpine` · `Docker` · `Railway`

---

## Design

Built on the **Digital Foreman** design system — dark industrial aesthetic, green primary accent (`#4de082`), Manrope headline font, Inter body font. Originally designed in Stitch by Anthropic and extended with live API integration.