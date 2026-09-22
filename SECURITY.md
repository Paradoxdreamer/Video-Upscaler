# Security notes — Video Upscaler

## Scope
This project is a **local / client-side** tool. There is no server backend in the open-source core. Risk is mainly misuse of the CLI on a shared machine or hosting the static web app.

## Fixes in v1.1.0
| Area | Issue | Mitigation |
|------|--------|------------|
| CLI (bash/Python) | Unvalidated fps/crf/threads/preset | Integer ranges + preset whitelist |
| CLI | Overwrite sensitive system paths | Block `/etc`, `/usr`, `/bin`, … for output |
| CLI | Shell injection | Always `ffmpeg` via argv array / `shell=False` |
| Web | DOM XSS via filename | `textContent` only; sanitize download name |
| Web | Tampered form values | Whitelist FPS/CRF/resolution before encode |
| Web | Open redirects / tabnabbing | `rel="noopener noreferrer"` on external links |
| Web | Broad script policy | CSP meta restricting scripts to self + jsDelivr |

## Residual risks
- **CDN supply chain**: ffmpeg.wasm loaded from jsDelivr. Pin versions; consider self-hosting core files for production SaaS.
- **Local DoS**: User can still request extreme encodes (Insane mode) that exhaust CPU/RAM/disk — by design, with warnings.
- **Malicious video files**: FFmpeg parsers have historically had bugs; only process files you trust.
- **SaaS future**: When adding APIs, auth, uploads, and billing, apply standard web security (authn/z, rate limits, virus scan, signed URLs, no SSRF to internal GPU metadata).

## Reporting
Open an issue on the GitHub repository with a clear reproduction. Do not post exploits against third-party users.

## Testing performed
- `bash -n` on shell script
- `python3 -m py_compile` on Python CLI
- Manual review for command injection, path traversal, XSS
- Whitelist / range validation paths exercised logically
