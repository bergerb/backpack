# Backpack

Backpack is a resume-inspired Jekyll theme for personal sites. It is being built as a standalone theme repo first so consumer sites can adopt it later as a remote theme.

## Current Theme Scope

This repo currently provides:

- a resume-style `home` layout
- a standard `page` layout
- a standard `post` layout
- a printable `pdf` layout
- top navigation built from `include_nav: true` pages
- optional Disqus comments support for posts
- shared CSS and JS assets
- a `_data/backpack.yml` content contract for the resume-style surfaces

The next step is migrating `bergerb.github.io` to consume this repo as its remote theme.

## Remote Theme Usage

In a GitHub Pages site, add the remote theme and plugin support to your site repo:

```ruby
# Gemfile
gem "github-pages", group: :jekyll_plugins

group :jekyll_plugins do
  gem "jekyll-remote-theme"
end
```

```yaml
# _config.yml
remote_theme: bergerb/backpack@main

plugins:
  - jekyll-remote-theme
```

Then create pages that use the theme layouts:

```markdown
---
layout: home
title: Brent Berger
---
```

```markdown
---
layout: page
title: About
permalink: /about/
---

Page content goes here.
```

```markdown
---
layout: pdf
title: Brent Berger PDF
permalink: /pdf/
---
```

## Data Contract

The resume-style layouts expect a `_data/backpack.yml` file with these top-level keys:

- `header`
- `contact`
- `core_strengths`
- `summary`
- `education`
- `skills`
- `experiences`

This repo's demo site is the reference implementation for the expected shape.

Posts additionally use:

- `layout: post`
- `date`
- optional `tags`

The theme also supports either `comments.disqus_shortname` or the existing top-level `disqus_shortname` configuration shape.

## Local Development

Install dependencies:

```powershell
bundle install
```

Run the automated theme checks:

```powershell
bundle exec rake test
```

Build the demo site:

```powershell
bundle exec rake build
```

