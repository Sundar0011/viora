# Feature: Marketplace / Sale Listings

> Source of truth = the Flutter frontend. This doc records what the backend MUST provide
> for this feature to work. Derived from `lib/` — do not invent behavior the code doesn't show.

## 1. Overview
- **What it is:** A local classifieds/marketplace. Users create listings (with or without photos),
  set a category, price type (Free/Fixed) and price, a location, browse a community sales feed with
  category / distance (kms) / sort filters, view a listing's full detail, edit or delete their own
  listing, mark it Sold (or Available again), chat with the seller, and report a listing.
- **Why it exists / user value:** Lets neighbors buy and sell items within their community
  (`community_id`), discovered by proximity (distance in kms from the viewer) and category.
- **Related features:** Reports (`reports` table, shared with posts/events — report_type='sale'),
  Chat/Messages (contact-seller flow inserts into `chat` / `messages`), Search
  (`get_search_all_data` returns sales too), Neighborhood distance/geo (lat/lng + PostGIS).

## 2. Screens & widgets
| Screen / widget (path under `lib/pages/sale/`) | Purpose | Key actions |
|---|---|---|
| `sale/sale_widget.dart` | Marketplace home: browse feed + "yours" (my listings) tabs | On load: browse feed via `get_sales_home_data`, my listings via `get_yours_sales_details`; opens filter sheets |
| `sale_details/sale_details_widget.dart` | Full listing view | Loads via `get_sales_homepage` (single `p_saleid`); contact seller → `chat`/`messages` DML; three-dot menu |
| `sales_create_edit/listing_details/` | Create listing **with photos** | `insert_sales_details` RPC → `uploadSalesImages` action → `update_sale_count` RPC |
| `sales_create_edit/listing_details_no_photos/` | Create listing **without photos** | `insert_sales_details` RPC → `update_sale_count` RPC (no image upload) |
| `sales_create_edit/listing_details_edit/` | Edit listing **with photos** | Prefill via `SaleTable` query + `get_sale_images`; `update_sale_without_image` RPC + `sale_images` delete/insert + `uploadSalesImages` |
| `sales_create_edit/listing_details_no_photos_edit/` | Edit listing **without photos** | Prefill via `SaleTable` query; `update_sale_without_image` RPC |
| `comp_create_listing/` | "Create listing" entry sheet (photo picker / choose flow) | Uploads local files, routes to with/without-photos create screen |
| `comp_category_filter/` | Category filter sheet | Lists `sale_category` rows; sets `FFAppState().SalesFilter`, re-runs feed (`get_sales_home_data`) or search (`get_search_all_data`) |
| `comp_kms_filter/` | Distance (kms) filter sheet | Sets `FFAppState().SalesKmFilter` (int), re-runs feed |
| `comp_sales_sort/` | Sort sheet | Sets `FFAppState().SalesSort` = 'Newest' or 'Closest', re-runs feed |
| `comp_three_dot_report_sale/` | Three-dot menu | Owner → Edit Listing (routes to photos/no-photos edit by `imageCount`); non-owner → Report Listing |
| `comp_report_listing/` | Report sheet | Inserts into `reports` (report_type='sale') |
| `comp_sale_delete/` | Delete/Sold **undo** snackbar sheet | "Undo" reverses a delete (isdeleted=false) or sold state |
| `comp_sold_delete/` | Delete / Mark-Sold confirmation sheet | Direct `SaleTable().update` of `isdeleted` / `e_sale_type` |

## 3. Data model (tables & columns)

### `sale`
- **Purpose:** One row per listing. Types/nullability from `SaleRow`
  (`lib/backend/supabase/database/tables/sale.dart`).
- **Columns:**
  | Column | Type | Null? | Notes (PK/FK/default/enum) |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK. Used as storage folder name for images. Returned by `insert_sales_details` (`$.id`) |
  | `created_at` | timestamptz | no | default `now()`; sort key for "Newest" |
  | `community_id` | int8 (int) | no | FK → community. From `FFAppState().communityId` |
  | `title` | text | no | Listing title |
  | `description` | text | no | Listing description |
  | `sale_category` | text | no | Category name string (matches `sale_category.name`, NOT an id) |
  | `e_price_type` | text | no | 'Free' or 'Fixed' (from radio button). Not a DB enum in frontend |
  | `price` | int8 (int) | yes | Null when Free; integer amount when Fixed |
  | `location` | text | no | Human-readable place string (chosen place) |
  | `e_sale_type` | text | no | 'selling' (available) / 'sold'. Set 'selling' on create |
  | `created_by` | uuid (String) | no | FK → seller/owner (`currentUserUid`). Sent to RPC as `p_userid` |
  | `location_point` | geography/geometry (String) | no | PostGIS point. Frontend reads as String; written server-side from lat/lng in the insert RPC (see §8) |
  | `city` | text | no | City string |
  | `isdeleted` | bool | no | **Note: `isdeleted` (no underscore).** Soft-delete flag; set true on delete, false on undo |
  | `latitude` | float8 (double) | yes | From chosen place |
  | `longitude` | float8 (double) | yes | From chosen place |
- **Foreign keys / relationships:** `community_id` → community; `created_by` → user profile /
  auth user. One-to-many with `sale_images` via `sale_id`.
- **Indexes needed:** `community_id`, `created_by`, `sale_category`, `e_sale_type`, `isdeleted`,
  `created_at`; GiST index on `location_point` for distance queries.

### `sale_category`
- **Purpose:** Lookup table of category names shown in the category dropdown and the category
  filter sheet. Types from `SaleCategoryRow` (`sale_category.dart`).
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()`; filter sheet orders by this |
  | `community_id` | int8 (int) | yes | FK → community (nullable; global categories allowed) |
  | `name` | text | yes | Category label. Stored into `sale.sale_category` by name |
- **Foreign keys / relationships:** `community_id` → community. `sale.sale_category` references
  `sale_category.name` **by string value** (no FK constraint in frontend contract).
- **Reads:** `SaleCategoryTable().queryRows(queryFn: (q) => q)` in create/edit screens (unordered);
  `q.order('created_at')` in `comp_category_filter`. No community filter is applied in the query.
- **Indexes needed:** `community_id`, `name`.

### `sale_images`
- **Purpose:** Zero-or-more photos per listing. Types from `SaleImagesRow` (`sale_images.dart`).
- **Columns:**
  | Column | Type | Null? | Notes |
  |---|---|---|---|
  | `id` | uuid (String) | no | PK |
  | `created_at` | timestamptz | no | default `now()` |
  | `community_id` | int8 (int) | yes | FK → community. Written as `int.tryParse(communityId)` in upload action |
  | `sale_id` | uuid (String) | no | FK → `sale.id` |
  | `user_id` | uuid (String) | yes | FK → uploader (seller) |
  | `image` | text | yes | Public URL from `sales-images` storage bucket |
- **Foreign keys / relationships:** `sale_id` → `sale.id` (on delete cascade recommended);
  `user_id` → user; `community_id` → community.
- **Indexes needed:** `sale_id`, `community_id`, `user_id`.
- **Storage:** Bucket **`sales-images`**. Path pattern `"<sale_id>/<millisecondsSinceEpoch>.<ext>"`
  (ext defaults to `webp`), uploaded with `FileOptions(upsert: true)`; public URL stored in `image`.

### `reports` (shared table — see Reports feature)
- **Purpose:** Reporting a listing. Written directly via `ReportsTable().insert(...)`.
- **Fields written here:** `sale_id`, `community_id`, `reported_by_user`, `reason`,
  `report_type` = `'sale'`, `reported_user`. Returns inserted row (`.id`).

## 4. Backend calls (API / RPC / Edge)
All RPCs are PostgREST `POST /rest/v1/rpc/<fn>` against
`https://wgcqstmmkcdjnnpuvspr.supabase.co` (current project — to be re-pointed to Viora's own
Supabase project during rebuild). Headers: `apikey` (anon), `Authorization: Bearer <jwt>`.

| Call / query | Type | Inputs | Returns | Called from |
|---|---|---|---|---|
| `InsertSaleDetailsCall` → `insert_sales_details` | RPC | `community_id`, `title`, `description`, `sale_category`, `e_price_type`, `price`, `location`, `e_sale_type`, `p_userid`, `lon`, `lat`, `city` | new sale (incl. `$.id`) | `listing_details` / `listing_details_no_photos` (create) |
| `UpdateSaleWithoutImageCall` → `update_sale_without_image` | RPC | `city`, `description`, `e_price_type`, `lat`, `location`, `lon`, `price`, `sale_category`, `sale_id`, `title` | updated sale | `listing_details_edit` / `listing_details_no_photos_edit` |
| `GetSalesDataCall` → `get_yours_sales_details` | RPC | `p_userid`, `p_filter` ('all' / 'selling' / 'sold') | my listings list | `sale_widget` ("yours" tab) |
| `GetSalesDetailsCall` → `get_sales_details` | RPC | `p_salesid`, `p_userid` | single listing detail | sale detail flows |
| `GetSaleHomePageSalesCall` → `get_sales_homepage` | RPC | `p_userid`, `p_communityid`, `p_saleid` | single listing (homepage-shaped) | `sale_details_widget` on load |
| `getSaleHomePage` action → `get_sales_home_data` | RPC (custom action, raw http) | `p_userid`, `p_category`, `p_type` (sale type), `p_distance` (kms int), `p_sort`, `p_communityid` | browse feed list (each item has `distance_km`) | `sale_widget` on load; all three filter sheets |
| `UpdateSaleCountCall` → `update_sale_count` | RPC | `p_userid` | (count update) | after create listing |
| `GetSalesImagesCall` → `get_sale_images` | RPC | `p_saleid` | image list for a sale | `listing_details_edit` prefill |
| `GetAllSearchCall` → `get_search_all_data` | RPC | `p_search_text`, `p_userid`, `p_communityid`, `p_type`='sale', `p_category`, `p_sale_type`, `p_sort`, `p_distance` | multi-type search incl. `$.sales` | filter sheets when `pageType != 'sale'` (search context) |
| `uploadSalesImages` action | Storage + direct DML | `uploadedImages[]`, `saleId`, `userid`, `communityId` | — | create/edit-with-photos. Uploads to `sales-images` bucket, inserts each `sale_images` row |
| `SaleCategoryTable().queryRows` | direct SELECT | — (optionally `order('created_at')`) | category rows | category dropdown + filter sheet |
| `SaleTable().queryRows` / `querySingleRow` | direct SELECT | `eqOrNull('id', saleId)` | listing row | edit prefill |
| `SaleTable().update` | direct UPDATE | `data: {isdeleted}` or `{e_sale_type}`; match `id` + `community_id` | — | `comp_sold_delete` (delete/mark sold), `comp_sale_delete` (undo) |
| `SaleImagesTable().delete` | direct DELETE | `matchingRows` by sale/image | — | edit-with-photos (remove images) |
| `ReportsTable().insert` | direct INSERT | report fields (report_type='sale') | inserted row | `comp_report_listing` |

## 5. Business rules & flows

**Create (with photos):**
1. Validate title/price form, category chosen, at least one uploaded image, a chosen place/location.
2. If `price == 'Free'` → send `price: null`; else parse integer from price field.
3. `insert_sales_details` (e_sale_type='selling', p_userid=currentUserUid, lat/lng/city) → returns `$.id`.
4. `await Future.delayed(1000ms)` then `uploadSalesImages(files, saleId, userId, communityId)` —
   uploads each image to `sales-images/<saleId>/...` and inserts a `sale_images` row.
5. `update_sale_count(p_userid)` → navigate to `sale` (pageType 'yours').

**Create (no photos):** same as above minus steps 4 image upload.

**Edit:** prefill from `SaleTable` (+ `get_sale_images` for photo edit). Save via
`update_sale_without_image` (title, description, category, price, e_price_type, location, lat/lon,
city, sale_id). Photo edit additionally deletes removed `sale_images` rows and uploads new ones via
`uploadSalesImages`. `e_sale_type`, `community_id`, `created_by`, `isdeleted` are NOT changed on edit.

**Delete / Sold / Undo (owner):**
- Delete = **soft delete**: `sale.isdeleted = true` (undo sets it back to `false`).
- Mark Sold: `sale.e_sale_type = 'sold'`; Mark Available again: `e_sale_type = 'selling'`.
- All `SaleTable().update` calls match on **both** `id` AND `community_id` (ownership/community guard).

**Browse feed:** `get_sales_home_data(p_userid, p_category, p_type, p_distance, p_sort, p_communityid)`.
Filters live in `FFAppState`: `SalesFilter` (category name), `SalesTypeFilter` (sale type),
`SalesKmFilter` (int kms), `SalesSort` ('Newest' | 'Closest'). Each item includes `distance_km`.
Result stored in `FFAppState().SalesHomePageData`.

**My listings:** `get_yours_sales_details(p_userid, p_filter)` with p_filter 'all' | 'selling' | 'sold'.

**Report:** non-owner three-dot → report sheet → `reports` insert (report_type='sale') → thank-you sheet.

**Contact seller:** from `sale_details`, inserts/updates `chat` + `messages` rows directly (Chat feature).

## 6. Realtime / notifications
- No sale-specific realtime channel or push notification is present in the sale pages.
  (Chat messages inserted from `sale_details` belong to the Chat feature's realtime.)

## 7. Backend to build (Supabase rebuild checklist)
- [ ] **Tables:** `sale`, `sale_category`, `sale_images` (columns/types/nullability per §3);
      real FKs (`sale_images.sale_id → sale.id` on delete cascade; `community_id`, `created_by`).
- [ ] **Indexes:** `sale(community_id, e_sale_type, isdeleted, created_at)`, `sale(created_by)`,
      `sale(sale_category)`, GiST on `sale.location_point`; `sale_images(sale_id)`,
      `sale_category(community_id, name)`.
- [ ] **PostGIS / geospatial:** `location_point` geography column; populate from lat/lng inside
      `insert_sales_details`; distance (kms) computed via `ST_DWithin` / `ST_Distance` against the
      caller's community/user location for `get_sales_home_data` + the `distance_km` output field.
- [ ] **RLS intent:**
      - `SELECT` on `sale` / `sale_images`: community members; hide `isdeleted = true` from feed.
      - Writes to `sale` should go through RPC (`insert_sales_details`, `update_sale_without_image`);
        the current frontend also does **direct** `SaleTable().update` for delete/sold/undo and direct
        `sale_images` insert/delete — RLS must allow the owner (`created_by = auth.uid()`) within their
        community, or these should be migrated to RPCs (see §8, security concern).
      - `sale_category`: SELECT for authenticated; writes admin-only.
      - `reports` insert: authenticated (per Reports feature).
- [ ] **RPC / PL-pgSQL functions:** `insert_sales_details`, `update_sale_without_image`,
      `get_yours_sales_details`, `get_sales_details`, `get_sales_homepage`, `get_sales_home_data`,
      `update_sale_count`, `get_sale_images` (+ `get_search_all_data` shared with Search). Validate
      `auth.uid()`, enforce ownership on update, `SET search_path`, appropriate GRANTs.
- [ ] **Storage:** bucket **`sales-images`** (public read). Policies: insert/update/delete by owner
      under their `<sale_id>/` prefix; public GET for image URLs.
- [ ] **Triggers / cron:** none required by the frontend beyond `update_sale_count` (invoked manually).

## 8. Open questions & risks
- **`location_point` type & population:** frontend reads it as a non-null String but never writes it
  in DML; it must be a PostGIS point set server-side inside `insert_sales_details` from lat/lng.
  Confirm SRID and geography-vs-geometry. `latitude`/`longitude` are nullable but `location_point`
  is non-null — reconcile (what happens when no place chosen?).
- **Distance filter:** `get_sales_home_data` takes `p_distance` (int kms) and returns `distance_km`.
  Confirm the reference point (viewer's current lat/lng vs community centroid) and the meaning of
  the `p_distance` sentinel values (e.g. "any distance"). `comp_kms_filter` supplies a fixed km list.
- **Sort values:** `SalesSort` is 'Newest' or 'Closest' (exact strings the RPC must accept). 'Closest'
  requires the geospatial distance computed above.
- **`p_type` overload:** in `get_sales_home_data` the 4th arg is passed as `FFAppState().SalesTypeFilter`
  (sale type: selling/sold), while `get_search_all_data` has both `p_type='sale'` and a separate
  `p_sale_type`. Confirm exact accepted values for the sale-type filter.
- **Direct client writes bypass RPC:** delete/sold/undo use `SaleTable().update` and image add/remove
  use direct `sale_images` insert/delete + storage from the client. Per CLAUDE.md §6 these should be
  RLS-guarded to owner-only or moved behind SECURITY DEFINER RPCs. Decision needed.
- **`sale_category` by name, not id:** `sale.sale_category` stores the category **name** string. No FK.
  Renaming a category would orphan listings. Confirm whether to keep name-based or switch to id FK
  (frontend contract is name-based — changing it breaks the app).
- **`InsertImageUrlsCall` (`insert_post_image_rows`)** was listed for this feature but is **NOT used**
  by any sale screen — sale images are written by the `uploadSalesImages` action (direct `sale_images`
  insert). It belongs to the Post feature. No `insert_post_image_rows` needed for sale.
- **`update_sale_count`:** increments some per-user counter (target table/column not visible in
  frontend). Confirm what it maintains (e.g. a profile listing count).
- **`community_id` types differ:** `sale.community_id` is non-null int8; `sale_category.community_id`
  and `sale_images.community_id` are nullable. Confirm intended nullability.
