# Database schema

SQLite database file: **`pakeeza_pos.db`**

Location (typical):  
`C:\Users\<you>\AppData\Roaming\pakeeza_pos\data\pakeeza_pos.db`  
(Exact path shown in **Settings** inside the app.)

## Tables

### `users`

| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | Auto |
| username | TEXT UNIQUE | Lowercase, min 3 chars |
| display_name | TEXT | Shown in app bar |
| password_hash | TEXT | SHA-256 + salt |
| salt | TEXT | Per user |
| role | TEXT | `owner` or `cashier` |
| created_at | TEXT | ISO-8601 |

First registered user is always **owner**.

### `categories`

| Column | Type |
|--------|------|
| id | INTEGER PK |
| name | TEXT |
| sort_order | INTEGER |

8 categories — see [MENU.md](MENU.md).

### `products`

| Column | Type |
|--------|------|
| id | INTEGER PK |
| category_id | INTEGER FK |
| name | TEXT |
| sort_order | INTEGER |

### `variants`

| Column | Type |
|--------|------|
| id | INTEGER PK AUTO |
| product_id | INTEGER FK |
| name | TEXT | e.g. Small, Large, Regular |
| price | INTEGER | PKR whole rupees |
| sort_order | INTEGER |

### `orders`

| Column | Type |
|--------|------|
| id | INTEGER PK AUTO |
| created_at | TEXT ISO-8601 |
| total | INTEGER |
| payment_method | TEXT | cash, card, online |
| customer_note | TEXT NULL |
| status | TEXT | completed |
| user_id | INTEGER FK NULL | Cashier |

### `order_items`

| Column | Type |
|--------|------|
| id | INTEGER PK AUTO |
| order_id | INTEGER FK |
| product_name | TEXT | Snapshot at sale time |
| variant_name | TEXT |
| unit_price | INTEGER |
| quantity | INTEGER |
| line_total | INTEGER |

Names/prices are **copied at checkout** so later menu edits do not change old receipts.

### `settings`

| key | value |
|-----|-------|
| shop_name | … |
| shop_address | … |
| shop_phones | … |
| receipt_footer | … |

### `meta`

| key | value |
|-----|-------|
| menu_seeded | 1 |

## Backup

Use **Settings → Export database backup**.  
Copies the `.db` file to Documents → `PakeezaPOS/backups/`.

To restore: replace `pakeeza_pos.db` while app is closed (advanced — contact developer).

## Migrations

Version **1** only. Future versions will use `onUpgrade` in `DatabaseHelper`.
