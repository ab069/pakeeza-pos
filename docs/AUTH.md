# Authentication (login & sign up)

## Overview

Accounts are stored **locally** in SQLite. There is no online registration or forgot-password email. This is appropriate for a single-shop offline POS.

## First launch

1. Database has **no users**.  
2. App opens **Sign Up** tab with message: *First time setup*.  
3. Create account → becomes **owner** automatically.  
4. You are logged in and can use POS.

## Sign up (after first user)

- New accounts default to role **`cashier`**.  
- Usernames must be **unique** (case-insensitive).  
- Password minimum **6** characters.  
- Username minimum **3** characters.

## Login

- Enter username + password.  
- On success, session is stored in memory.  
- `shared_preferences` stores `session_user_id` for reference only — **password is never saved**.  
- After app restart, user must **login again** (security).

## Roles

| Role | Intended use |
|------|----------------|
| **owner** | First account; full access (same screens as cashier in v1) |
| **cashier** | Staff accounts |

v1 does not hide screens by role yet. Future: only owner can change prices, manage users, or view sensitive reports.

## Password security

- Each password uses a random **salt**.  
- Hash: `SHA-256(salt + ":" + password)` stored as base64.  
- Suitable for **offline local** use; not designed for internet-facing auth.

## Logout

**Settings → Logout** clears session. Next user can log in.

## Recommendations for the shop

1. Create **one owner** (manager) account.  
2. Create **cashier** accounts for each shift worker — avoid sharing one login.  
3. Use strong passwords for owner.  
4. Export database backup regularly (includes user table).

## Future improvements

- Owner-only “Add user” (disable public sign up)  
- Change password screen  
- Optional PIN quick-login for cashiers
