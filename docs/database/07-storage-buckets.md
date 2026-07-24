# Database Design — Storage Buckets

> Part of `docs/database-design.md`. DESIGN ONLY — not applied. Bucket creation + storage RLS
> policies go through Supabase MCP only after review, same as table RLS (CLAUDE.md §6.9).

## Convention
- Path convention across all buckets: `<owner-or-entity-id>/<filename>` so storage RLS can check
  `(storage.foldername(name))[1] = <owner id>::text` (or the relevant entity id, checked against
  the owning row).
- Public buckets: `SELECT` open to `anon`/`authenticated` (public URLs), but `INSERT`/`UPDATE`/
  `DELETE` restricted to the owner's folder. Storage **upsert requires INSERT + SELECT + UPDATE**
  grants together (per the `supabase` skill's security checklist) — replacing a file (many flows
  here use `FileOptions(upsert:true)`) silently fails with INSERT-only.
- Private buckets: no public `SELECT` — signed URLs only, generated server-side (edge
  function/RPC) for the owner + admin.

## Existing buckets (confirmed by the frontend contract)
| Bucket | Public? | Used by | Path convention | Mime types | Size limit (recommended) |
|---|---|---|---|---|---|
| `post-images` | **Public** read | Home Feed & Posts (`create_post`, `editpost`) | `<post_id>/<file>` | `image/jpeg`, `image/png`, `image/webp` | 10 MB/file |
| `sales-images` | **Public** read | Marketplace (`uploadSalesImages`) | `<sale_id>/<epoch_ms>.<ext>` (default `webp`) | `image/jpeg`, `image/png`, `image/webp` | 10 MB/file |
| `profile-images` | **Public** read | Profile avatar (`user_profile`) | `<user_id>/<file>` | `image/jpeg`, `image/png`, `image/webp` | 5 MB/file |
| `cover-images` | **Public** read | Profile cover (`user_profile`) | `<user_id>/<file>` | `image/jpeg`, `image/png`, `image/webp` | 5 MB/file |
| `business-image` | **Public** read | Business page profile/cover (`create_page`) | `<business_page_id>/{profile\|cover}_<file>` | `image/jpeg`, `image/png`, `image/webp` | 5 MB/file |
| `promote-receipts` | **Private** — MUST NOT be public | Business promotion receipts (`upload_receipt`) | `<business_page_id>/<file>` | `image/jpeg`, `image/png`, `application/pdf` | 10 MB/file |
| `event` | **Public** read | Event cover images (`create_event`, `edit_event`) | `<event_id>/<file>` | `image/jpeg`, `image/png`, `image/webp` | 10 MB/file |
| `group-profile-image` | **Public** read | Group banner (`create_group`, `edit_group`) — confirmed in feature doc §7 but missing from the task's listed "current frontend buckets" set; kept since `docs/features/05-groups.md` explicitly names it | `<group_id>/<file>` | `image/jpeg`, `image/png`, `image/webp` | 5 MB/file |
| `squadd` | **Public** read | Static defaults only (`default_group_image/`, `default_profile/`, `default_cover_image/`) — admin-managed, no user uploads | fixed known paths | image | n/a (admin-curated) |

## Video upload — RESOLVED, out of scope
**Video upload is NOT in scope — the app has no video-upload UI; revisit in future.** No
`post-videos` bucket, no `video/*` mime types, and no `e_media_type='video'` design exist in this
document. `post_images.e_media_type` is images only (`'image'`) for the current build. See
Decision: Video Out of Scope in `10-open-decisions.md` (RESOLVED).

## Storage RLS intent (per bucket)
- **Public image buckets** (`post-images`, `sales-images`, `profile-images`, `cover-images`,
  `business-image`, `event`, `group-profile-image`): `SELECT` to `anon, authenticated` (unrestricted
  — these are meant to be publicly loadable URLs); `INSERT`/`UPDATE`/`DELETE` restricted to
  `authenticated` where the first path segment equals the caller's own id (`profile-images`,
  `cover-images`) or where the caller owns the parent entity (`post-images` → post author,
  `sales-images` → sale owner, `business-image` → business page owner, `event` → event owner,
  `group-profile-image` → group admin/creator). Ownership check is a `(SELECT is_owner_of(...))`
  helper joining back to the entity table, not a bare path check, since folder = entity id, not
  user id, for most of these.
- **`promote-receipts` (private)**: `SELECT` restricted to the business page owner
  (`business_promote.admin_user = auth.uid()`) **or** `is_admin()`. `INSERT` restricted to the
  owner's own `business_page_id` folder. No public `SELECT` policy at all.
- **`squadd`**: `SELECT` public; `INSERT`/`UPDATE`/`DELETE` admin-only (static default assets).
