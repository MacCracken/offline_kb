# Offline Knowledge Base

Portable offline knowledge on an SSD. Plug into any computer, run the server, browse everything locally.

## What's Included

- **Wikipedia** (full English, no images variant ~50GB or with images ~100GB)
- **Survival & Medical** — Army Survival Manual, Where There Is No Doctor, SAS Survival Handbook references
- **How-To & Repair** — iFixit, Wikibooks, Wikihow
- **Reference** — Wiktionary, Wikivoyage, StackOverflow/Exchange
- **Books** — Project Gutenberg (60k+ public domain books)
- **Maps** — OpenStreetMap

## Quick Start (Docker)

```bash
# 1. Edit content.yaml to pick what you want (sizes listed per item)

# 2. Start the container
docker compose up -d

# 3. Download content into the container's data volume
docker exec -it offline-kb /app/setup.sh /data

# 4. Browse
#    Portal:  http://localhost:8080
#    Kiwix:   http://localhost:8888
```

The portal at `:8080` gives you a landing page with links to all content. Kiwix at `:8888` serves the ZIM files directly with full-text search.

## Without Docker

```bash
# Download content to your SSD
./setup.sh /mnt/your-ssd

# Serve it
./serve.sh /mnt/your-ssd
# Open http://localhost:8888
```

## Selective Download

Edit `content.yaml` to pick what you want before running setup. Each entry has a size estimate so you can budget your storage.

## Requirements

- Docker and Docker Compose (recommended), OR:
- `kiwix-tools`, `curl`, `python3` with `pyyaml`
- ~200GB for everything, ~60GB for a lean setup

## Roadmap

- [ ] SSD plug-and-serve (current)
- [ ] Raspberry Pi self-contained appliance (WiFi hotspot, boots to server)
- [ ] Rugged hardware build (weatherproof case, battery backup)
- [ ] Custom UI / search across all content
