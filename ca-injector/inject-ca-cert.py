#!/usr/bin/env python3
import json
import sys

config_path, cert_src, cert_dst = sys.argv[1], sys.argv[2], sys.argv[3]

with open(config_path) as f:
    cfg = json.load(f)

# --- Bind-mount the CA cert file ---
existing_dests = {m["destination"] for m in cfg.get("mounts", [])}
if cert_dst not in existing_dests:
    cfg.setdefault("mounts", []).append({
        "destination": "/etc/ssl/certs",
        "type": "bind",
        "source": "/etc/ssl/certs",
        "options": ["bind", "ro", "rprivate"]
    })

# --- Inject environment variables ---
# Covers: Python (requests/httpx), Node.js, Go, curl, wget
# env_vars = {
#     "SSL_CERT_FILE":          cert_dst,  # Go stdlib, many others
#     "SSL_CERT_DIR":           "/usr/local/share/ca-certificates",
#     "REQUESTS_CA_BUNDLE":     cert_dst,  # Python requests
#     "HTTPX_CA_BUNDLE":        cert_dst,  # Python httpx (used by newer OpenAI SDK)
#     "NODE_EXTRA_CA_CERTS":    cert_dst,  # Node.js
#     "CURL_CA_BUNDLE":         cert_dst,  # curl / wget
#     "OPENAI_CA_BUNDLE":       cert_dst,  # some OpenAI SDK builds respect this
# }

proc_env = cfg.setdefault("process", {}).setdefault("env", [])
existing_keys = {e.split("=", 1)[0] for e in proc_env}

# for key, val in env_vars.items():
#     if key not in existing_keys:
#         proc_env.append(f"{key}={val}")

with open(config_path, "w") as f:
    json.dump(cfg, f)