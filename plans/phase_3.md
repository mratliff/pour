# Phase 3: Orders & Shop Dashboard

## Context

You are working on Georgetown Pour, a Phoenix 1.8 + Ecto community wine-tasting app. Phases 1-2 are complete:

- Role-based access control (admin, member, shop) with approval workflow
- Tasting events with wine associations and RSVP
- Wine image uploads via S3
- Email notifications for new tastings and RSVP confirmations

**IMPORTANT:** Before starting, read these files to understand current state:
- `lib/pour_web/router.ex` — current route structure with admin/shop/member scopes
- `lib/pour/shopping_cart.ex` — existing cart context
- `lib/pour/shopping_cart/cart.ex` — cart schema
- `lib/pour/shopping_cart/cart_item.ex` — cart item schema
- `lib/pour_web/live/cart/show.ex` — cart page (has HARDCODED totals — must fix)
- `lib/pour/events.ex` — events context for tasting associations

## Objective

Convert the shopping cart into a proper order system. Members place orders from their cart, shop users manage and fulfill orders, and the shop gets a consolidated view of total quantities needed.

## Tasks

### 1. Migrations

**a) Create orders table:**
```
- id: binary_id (PK)
- user_id: references users, type: binary_id, not null
- tasting_id: references tastings, type: binary_id, nullable
  (orders may be associated with a tasting but don't have to be)
- status: string, not null, default "placed"
  (values: "placed", "confirmed", "ready_for_pickup", "completed", "cancelled")
- notes: text, nullable (member can leave a note)
- placed_at: utc_datetime, not null
- confirmed_at: utc_datetime, nullable
- ready_at: utc_datetime, nullable
- completed_at: utc_datetime, nullable
- inserted_at, updated_at: utc_datetime
```

**b) Create order_items table:**
```
- id: binary_id (PK)
- order_id: references orders, type: binary_id, not null, on_delete: delete_all
- wine_id: references wines, type: binary_id, not null
- quantity: integer, not null
- price_at_order: decimal(10,2), not null (snapshot of price when ordered)
- inserted_at, updated_at: utc_datetime
```

Add index on `orders.user_id`, `orders.tasting_id`, `orders.status`.

### 2. Create Schemas

**`lib/pour/orders/order.ex`:**
- Fields: status, notes, placed_at, confirmed_at, ready_at, completed_at
- belongs_to :user, :tasting
- has_many :order_items
- has_many :wines, through: [:order_items, :wine]
- Changesets: create_changeset, status_changeset
- Status validation: must be one of the allowed values
- status_changeset should auto-set the corresponding timestamp (e.g., when status becomes "confirmed", set confirmed_at)

**`lib/pour/orders/order_item.ex`:**
- Fields: quantity, price_at_order
- belongs_to :order, :wine
- Validate quantity >= 1

### 3. Create Orders Context

**`lib/pour/orders.ex`:**

Functions:
- `create_order_from_cart/2` — Takes scope (user) and optional tasting_id. In a DB transaction:
  1. Load the user's cart with items + wine preloaded
  2. Validate cart is not empty
  3. Create order with status "placed", placed_at now
  4. Create order_items from cart_items (snapshot price_when_carted → price_at_order)
  5. Clear the cart items (delete all cart items)
  6. Return {:ok, order} or {:error, reason}
- `list_user_orders/1` — takes scope, returns user's orders ordered by placed_at desc, preload items + wines
- `get_order!/2` — takes id + scope, returns order (scoped to user for members). Preload items + wines.
- `get_order_admin!/1` — takes id, returns order with all preloads (for admin/shop)
- `list_all_orders/1` — takes optional filters (status, tasting_id), returns all orders. For shop/admin use.
- `update_order_status/2` — takes order + new status string. Updates status and sets corresponding timestamp. If new status is "ready_for_pickup", send email notification to the order's user.
- `cancel_order/1` — sets status to "cancelled" (only if current status is "placed" or "confirmed")
- `consolidated_view/1` — takes optional tasting_id filter. Returns aggregated data:
  ```
  [
    %{wine: %Wine{}, total_quantity: 25, order_count: 12},
    %{wine: %Wine{}, total_quantity: 18, order_count: 8},
    ...
  ]
  ```
  Uses a GROUP BY query on order_items joined with orders (only non-cancelled orders).
- `order_total/1` — calculates total for an order (sum of quantity * price_at_order for all items)

### 4. Fix Cart Totals

In `lib/pour/shopping_cart.ex`, add:
- `cart_total/1` — takes a cart (preloaded with items), returns total as Decimal
- `cart_item_subtotal/1` — takes a cart_item, returns quantity * price_when_carted

Update `lib/pour_web/live/cart/show.ex`:
- Replace ALL hardcoded dollar amounts ($99.00, $8.32, etc.) with real calculated values
- Show per-item subtotals and cart total
- No tax calculation needed (money handled at shop)

### 5. Update Cart Page with Order Placement

In `lib/pour_web/live/cart/show.ex`:
- Add a "Place Order" button (replaces the existing "Complete Order" stub)
- Optional: tasting dropdown if there are active tastings (associate order with a tasting)
- Optional: notes text field
- On click: call `Orders.create_order_from_cart/2`
- On success: redirect to order confirmation page with flash "Order placed!"
- On failure (empty cart, etc.): show error flash
- After placing order, cart should be empty

### 6. Member Order History

**`lib/pour_web/live/order_live/index.ex`:**
- List the current user's orders
- Show: order date, status (with colored badge), number of items, total
- Link to order detail

**`lib/pour_web/live/order_live/show.ex`:**
- Order detail: date, status, notes
- List of items: wine name, quantity, price, subtotal
- Order total
- If status is "placed", show a "Cancel Order" button
- Status timeline/tracker showing the progression

### 7. Shop Dashboard

**`lib/pour_web/live/shop_live/dashboard.ex`:**
- List all orders with filters:
  - Status filter (tabs or dropdown: All, Placed, Confirmed, Ready, Completed, Cancelled)
  - Optional: filter by tasting
- Each order row: order ID (truncated), customer email, date, item count, total, status
- Click to expand or link to detail
- Status update buttons: "Confirm" (placed→confirmed), "Mark Ready" (confirmed→ready_for_pickup), "Complete" (ready→completed)
- When marking "Ready for Pickup", system sends email to the member

**`lib/pour_web/live/shop_live/order_detail.ex`:**
- Full order detail view for shop
- All items with quantities and prices
- Customer info (email)
- Status update actions
- Order notes

### 8. Shop Consolidated View

**`lib/pour_web/live/shop_live/consolidated.ex`:**
- Shows aggregated quantities needed across all active orders
- Table columns: Wine Name, Region, Vintage, Total Bottles Ordered, Number of Orders
- Filter by tasting (dropdown)
- Filter by order status (default: show placed + confirmed, not cancelled/completed)
- This is the shop's "purchasing list" — what they need to stock
- Sortable by quantity or wine name

### 9. Email Notifications

Add to the notifier module:
- `deliver_order_ready_notification/1` — takes order (preloaded with user), sends email saying order is ready for pickup
- `deliver_order_placed_notification/1` — (optional) sends confirmation to member that order was received

### 10. Update Router

Add to the approved member live_session:
```elixir
live "/orders", OrderLive.Index, :index
live "/orders/:id", OrderLive.Show, :show
```

Add to the shop live_session:
```elixir
live "/shop/orders", ShopLive.Dashboard, :index
live "/shop/orders/:id", ShopLive.OrderDetail, :show
live "/shop/consolidated", ShopLive.Consolidated, :index
```

Also add admin access to shop routes (admins should be able to see the shop dashboard too). Consider either:
- A shared `:require_shop_or_admin` on_mount hook, OR
- Duplicate the routes in the admin scope

## Acceptance Criteria

- [ ] Cart shows real calculated totals (no hardcoded values)
- [ ] "Place Order" converts cart items to an order and clears the cart
- [ ] Order snapshots wine prices at time of order (price_at_order)
- [ ] Member can view their order history at /orders
- [ ] Member can view individual order details
- [ ] Member can cancel a "placed" order
- [ ] Shop can view all orders at /shop/orders with status filters
- [ ] Shop can update order statuses (confirm, mark ready, complete)
- [ ] Marking order "ready for pickup" sends email to member
- [ ] Shop can see consolidated view at /shop/consolidated
- [ ] Consolidated view shows total quantities per wine across non-cancelled orders
- [ ] Consolidated view is filterable by tasting
- [ ] Order can be optionally associated with a tasting
- [ ] DB transaction ensures cart→order conversion is atomic
- [ ] `mix test` passes
- [ ] `mix compile --warnings-as-errors` is clean

## Status Report

When complete, provide:
1. List of all files created or modified
2. Migration file names with timestamps
3. How cart→order conversion works (transaction details)
4. How consolidated view query works
5. Any issues encountered or assumptions made
6. Confirm compilation and tests pass
