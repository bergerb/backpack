# Backpack Two-Mode Homepage Design

**Problem**

`backpack` currently blends resume and blog presentation into one homepage composition. We need two clear homepage modes:

- **Resume mode** keeps the current resume-style experience.
- **Blog mode** uses the same visual language, but behaves like a blog homepage instead of a resume.

**Goal**

Support a site-wide homepage mode switch so consuming sites can choose either a resume-first or blog-first presentation without forking the theme.

## Current State

The current `home` layout always renders:

- the top site nav bar
- the hero panel
- the resume sidebar
- professional summary
- professional experience
- recent posts

That means the homepage is currently a hybrid instead of a deliberate mode-based design.

## Desired Modes

### Resume Mode

Resume mode should remain close to the existing experience:

- keep the top nav bar
- keep the hero panel
- keep the hero title line
- keep hero actions for external/profile links
- keep the resume sidebar
- keep professional summary
- keep professional experience
- recent posts may remain secondary content if desired by the existing design

### Blog Mode

Blog mode should shift the homepage into a blog-first composition:

- remove the separate top nav bar
- keep the main hero panel as the top visual surface
- show identity content such as name and optional eyebrow
- hide the resume title line like “Senior Full-Stack .NET Engineer”
- replace the hero action row with navigation links only
- remove resume-only supporting panels:
  - contact
  - core strengths
  - technical skills
  - education
- remove resume sections from the main content area:
  - professional summary
  - professional experience
- place the blog listing in the main content area where professional experience currently appears

## Mode Selection

Mode selection should be site-wide via `_config.yml`.

Proposed config:

```yml
backpack:
  mode: blog
```

Allowed values:

- `resume`
- `blog`

If the mode is omitted, the theme should default to `resume` so existing resume behavior is preserved.

## Architecture

Keep `layout: home` as the homepage entry point and make it the mode router.

Recommended structure:

- `home.html`
  - reads `site.backpack.mode`
  - renders either the resume homepage composition or the blog homepage composition
- `site_header.html`
  - renders only for Resume mode
- split the hero into two focused includes:
  - `hero_resume.html`
  - `hero_blog.html`
- split homepage body content into two focused includes:
  - `home_resume.html`
  - `home_blog.html`
- keep the current sidebar as resume-only

This avoids turning one layout into a large pile of nested conditionals and makes the two modes understandable in isolation.

## Data Contract

The existing `_data/backpack.yml` file remains valid, but the two modes consume different subsets.

### Resume Mode reads

- `header.eyebrow`
- `header.name`
- `header.title`
- `header.summary`
- `header.actions`
- `contact`
- `core_strengths`
- `summary`
- `education`
- `skills`
- `experiences`

### Blog Mode reads

- `header.eyebrow` (optional)
- `header.name`
- optionally `header.summary` if we decide the blog hero should still include a short intro
- site pages marked with `include_nav: true`
- site posts

### Blog Mode ignores

- `header.title`
- `contact`
- `core_strengths`
- `skills`
- `education`
- `experiences`

## Blog Mode Navigation Behavior

Blog mode navigation should be drawn from the same `include_nav: true` pages already used by the site.

In Blog mode:

- those links move into the main hero action row
- the action row contains navigation links only
- no external profile links appear in that row

This keeps the homepage focused on navigating the site rather than presenting resume/contact actions.

## Migration Strategy

For `bergerb.github.io`:

1. Set `backpack.mode: blog`.
2. Keep `include_nav: true` on pages like About and Explore.
3. Keep existing post and page content intact.
4. Let the homepage composition switch entirely through theme behavior.

This minimizes consumer-side churn and keeps the migration config-driven.

## Error Handling and Defaults

- Unknown mode values should fall back to `resume`.
- Missing nav pages in Blog mode should not break the page; the hero simply renders without nav actions.
- Missing resume-only data in Blog mode should not matter because that data is not read.

## Verification Expectations

Implementation should verify:

1. Resume mode still renders the current resume homepage structure.
2. Blog mode hides the top nav bar.
3. Blog mode hides the hero title line.
4. Blog mode renders nav links in the hero action row.
5. Blog mode does not render the sidebar panels.
6. Blog mode replaces resume main content with the blog listing.
7. `bergerb.github.io` builds cleanly with `backpack.mode: blog`.

## Scope Boundaries

In scope:

- homepage mode switching
- mode-specific homepage composition
- mode-specific navigation placement
- preserving current post/page layouts

Out of scope:

- redesigning post layout
- redesigning page layout
- changing the PDF layout
- reworking the theme color system
- introducing per-page mode overrides
