# Phase 5: Blog & Tags

## Context

You are working on Georgetown Pour, a Phoenix 1.8 + Ecto community wine-tasting app. Phases 1-4 are complete:

- Role-based access control with admin approval
- Tasting events with RSVP and private locations
- Orders with shop dashboard and consolidated view
- Wine ratings and reviews

**IMPORTANT:** Before starting, read these files to understand current state:
- `lib/pour_web/router.ex` — current route structure
- `lib/pour_web/components/core_components.ex` — existing UI components
- `lib/pour/uploads.ex` — S3 upload helper (created in Phase 2)
- `mix.exs` — current dependencies

## Objective

Admin can publish rich-text blog posts with tags/categories. Public visitors can browse and read published posts. Content is written in Markdown and rendered server-side.

## Tasks

### 1. Add Markdown Dependency

In `mix.exs`, add:
```elixir
{:earmark, "~> 1.4"}
```

Run `mix deps.get`.

### 2. Migrations

**a) Create blog_posts table:**
```
- id: binary_id (PK)
- author_id: references users, type: binary_id, not null
- title: string, not null
- slug: string, not null
- body: text, not null (Markdown content)
- published_at: utc_datetime, nullable (null = draft)
- inserted_at, updated_at: utc_datetime
- unique index on slug
```

**b) Create tags table:**
```
- id: binary_id (PK)
- name: string, not null
- slug: string, not null
- unique index on name
- unique index on slug
```

**c) Create blog_post_tags join table:**
```
- blog_post_id: references blog_posts, type: binary_id, not null, on_delete: delete_all
- tag_id: references tags, type: binary_id, not null, on_delete: delete_all
- primary key on [blog_post_id, tag_id]
  (OR id: binary_id PK + unique index on [blog_post_id, tag_id])
```

### 3. Create Schemas

**`lib/pour/blog/blog_post.ex`:**
- Fields: title, slug, body, published_at
- belongs_to :author, Pour.Accounts.User
- many_to_many :tags, through blog_post_tags join table
- Changesets:
  - `changeset/2` — casts title, body, published_at. Auto-generates slug from title if slug is blank.
  - Slug generation: downcase, replace spaces with hyphens, remove non-alphanumeric (except hyphens), trim hyphens
  - Validate title presence and length (max 200)
  - Validate slug uniqueness
  - Validate body presence

**`lib/pour/blog/tag.ex`:**
- Fields: name, slug
- many_to_many :blog_posts
- Changeset: auto-generate slug from name, validate uniqueness of name and slug

**`lib/pour/blog/blog_post_tag.ex`:**
- Join schema (if using a separate schema; alternatively handle via `put_assoc`)
- belongs_to :blog_post, :tag

### 4. Create Blog Context

**`lib/pour/blog.ex`:**

Functions:
- `list_published_posts/1` — takes optional tag_slug filter. Returns published posts (published_at != nil and published_at <= now), ordered by published_at desc. Preload author and tags.
- `list_all_posts/0` — admin view, all posts (drafts + published), ordered by updated_at desc. Preload author and tags.
- `get_post_by_slug!/1` — get published post by slug, preload author and tags. Raise if not found or not published.
- `get_post!/1` — get post by id (admin, any status), preload author and tags.
- `create_post/2` — takes scope (user as author) and attrs. Set author_id from scope.
- `update_post/2` — update post attrs
- `delete_post/1` — delete a post
- `publish_post/1` — set published_at to now (if not already set)
- `unpublish_post/1` — set published_at to nil
- `list_tags/0` — all tags ordered by name
- `create_tag/1` — create a tag
- `get_or_create_tags/1` — takes list of tag names, returns list of tag structs (creates any that don't exist)
- `update_post_tags/2` — takes post and list of tag ids, updates the association
- `render_markdown/1` — takes markdown string, returns safe HTML using Earmark. Sanitize output to prevent XSS.

### 5. Admin Blog LiveViews

**`lib/pour_web/live/admin_live/blog_live/index.ex`:**
- List all posts (drafts and published)
- Columns: title, status (Draft/Published), published date, tag list
- Actions: Edit, Delete, Publish/Unpublish toggle
- "New Post" button

**`lib/pour_web/live/admin_live/blog_live/form.ex`:**
- Create/edit blog post
- Fields:
  - Title (text input)
  - Slug (auto-generated from title, but editable)
  - Body (large textarea for Markdown)
  - Tags (multi-select or comma-separated input)
  - Published at (checkbox "Publish now" or date picker)
- **Markdown preview:** Show rendered HTML preview below or beside the textarea. Update on blur or with a "Preview" button. Use Earmark to render server-side.
- Image insertion: Provide a file upload section (reuse S3 upload infrastructure from Phase 2). After upload, insert markdown image syntax `![alt](url)` into the textarea. This can be a simple "Upload Image" button that uploads and shows the URL for the user to paste.

### 6. Public Blog LiveViews

**`lib/pour_web/live/blog_live/index.ex`:**
- List published posts
- Show: title, excerpt (first ~200 chars of body, stripped of markdown), published date, author, tags
- Filter by tag (clickable tag pills)
- Pagination (if needed — start with simple load-more or just show all)
- This page should be publicly accessible (no auth required)

**`lib/pour_web/live/blog_live/show.ex`:**
- Display full post: title, author, published date, tags, rendered markdown body
- Publicly accessible
- Tag links that filter the blog index

### 7. Update Router

Public routes (no auth):
```elixir
scope "/", PourWeb do
  pipe_through :browser
  live "/", HomeLive.Index, :index
  live "/blog", BlogLive.Index, :index
  live "/blog/:slug", BlogLive.Show, :show
end
```

Admin routes (inside admin live_session):
```elixir
live "/admin/blog", AdminLive.BlogLive.Index, :index
live "/admin/blog/new", AdminLive.BlogLive.Form, :new
live "/admin/blog/:id/edit", AdminLive.BlogLive.Form, :edit
```

### 8. Navigation Update

Update the app layout/navigation to include a "Blog" link visible to all visitors. Check `lib/pour_web/components/layouts/` for the navigation template and add the blog link.

### 9. Markdown Rendering Safety

When rendering Markdown to HTML, ensure XSS safety:
```elixir
def render_markdown(markdown) when is_binary(markdown) do
  markdown
  |> Earmark.as_html!()
  |> Phoenix.HTML.raw()
end

def render_markdown(_), do: ""
```

Earmark's default output is reasonably safe, but if you want extra safety, consider stripping script tags or using `HtmlSanitizeEx` (add as dependency if needed). For this project, since only admins write content, Earmark defaults are acceptable.

## Acceptance Criteria

- [ ] Admin can create blog posts with title, markdown body, and tags at /admin/blog
- [ ] Slug is auto-generated from title
- [ ] Posts can be saved as draft (no published_at) or published
- [ ] Admin can publish/unpublish posts
- [ ] Admin can manage tags
- [ ] Markdown preview works in the editor
- [ ] Public blog listing at /blog shows only published posts
- [ ] Posts can be filtered by tag
- [ ] Individual post page at /blog/:slug renders markdown as HTML
- [ ] Blog link is in the site navigation
- [ ] Admin can upload images for use in blog posts
- [ ] `mix test` passes
- [ ] `mix compile --warnings-as-errors` is clean

## Status Report

When complete, provide:
1. List of all files created or modified
2. Migration file names with timestamps
3. Dependencies added
4. How Markdown rendering and preview works
5. How tag management works (creation, association)
6. How slug generation works
7. Any issues encountered or assumptions made
8. Confirm compilation and tests pass
