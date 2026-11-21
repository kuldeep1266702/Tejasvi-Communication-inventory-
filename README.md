# Tejasvi Communication — Stock & Inventory

A responsive inventory dashboard for mobile phones and accessories. Includes admin sign-in, item management, stock adjustments, low-stock indicators, stock activity log, product image URLs and live updates across signed-in sessions.

## Architecture

- Frontend: HTML, CSS and vanilla JavaScript
- Database, authentication and realtime: Supabase
- Hosting: GitHub Pages
- GitHub Pages is static hosting; Supabase provides the live database and authentication.

## 1. Create and configure Supabase

1. Create a project at https://supabase.com.
2. Open **SQL Editor**, paste all of `supabase-schema.sql`, and run it.
3. Open **Project Settings → API**. Copy the Project URL and `anon` / publishable key.
4. In `app.js`, replace:
   - `YOUR_SUPABASE_PROJECT_URL`
   - `YOUR_SUPABASE_ANON_KEY`
5. Never put a `service_role` or secret key in browser code.
6. In **Authentication → Users**, create the admin account (email and password).
7. Copy that user's UUID and run this in SQL Editor:
   ```sql
   insert into public.user_roles (user_id, role)
   values ('YOUR-AUTH-USER-UUID', 'admin');
   ```
8. In **Database → Replication** (or publication settings), confirm `inventory` and `stock_movements` are enabled for Realtime. The SQL script attempts to add them; if it reports they already exist, that is fine.

Only users assigned the `admin` role can read or change inventory. Do not expose secret keys. Create additional admin users in Supabase and add their UUIDs to `user_roles`.

## 2. Test locally

Because this is a static site, you can open `index.html` directly for a quick visual check, but use a local server for best results. For example, with Python installed:
```bash
python -m http.server 8000
```
Then open http://localhost:8000.

## 3. Deploy on GitHub Pages

1. Create a GitHub repository named `tejasvi-communication`.
2. Upload `index.html`, `style.css`, `app.js`, `supabase-schema.sql` and this README to the repository root.
3. Commit the files to the `main` branch.
4. Open repository **Settings → Pages**.
5. Under **Build and deployment**, choose **Deploy from a branch**.
6. Select branch `main`, folder `/ (root)`, then Save.
7. Wait for the Pages deployment. Your site will be available at `https://YOUR-GITHUB-USERNAME.github.io/tejasvi-communication/`.

In Supabase **Authentication → URL Configuration**, add the GitHub Pages URL to **Site URL** and **Redirect URLs**. For this password sign-in flow, ensure the deployed URL is allowed.

## Included features

- Admin login/logout using Supabase Auth
- Add, edit and delete mobile/accessory records
- Brand, model, colour, SKU, quantity, reorder level and pricing fields
- Product image URL preview in the inventory list
- Stock increase/decrease with validation
- Stock movement history
- Dashboard counts and purchase-value estimate
- Search and category filter
- Realtime refresh when inventory changes in another session
- Row Level Security policies for admin-only data access

## Important notes

- The Supabase URL and anon/publishable key are intended for frontend use; database security is enforced by Row Level Security.
- This is a single-store admin inventory starter. Add a proper staff-role workflow, barcode scanning, CSV import/export, supplier and sales modules if required.
- Realtime updates require an active internet connection.
