# 💼 Backpack

Backpack is a resume-inspired Jekyll theme for personal sites. 

## ✨ Features

- Resume-style homepage with customizable sections
- Print-friendly PDF layout for professional documents
- Blog mode for content-focused presentations
- Disqus comments integration
- Clean, responsive design
- Modular layouts: `home`, `page`, `post`, and `pdf`

## ⚙️ What This Repo Provides

The theme repo supplies:

- A resume-style `home` layout
- Standard `page` layout
- Standard `post` layout
- Printable `pdf` layout
- Top navigation via `include_nav: true` pages
- Optional Disqus comments for posts
- Shared CSS and JS assets
- `_data/backpack.yml` content contract for resume layouts


## 🌐 Remote Theme Usage
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

## 🏠 Homepage Modes
Backpack supports two homepage presentations through `_config.yml`:

```yaml
backpack:
  mode: resume # or blog
```

- `resume` renders the original resume-style homepage and remains the default when `backpack.mode` is missing or invalid.
- `blog` renders the blog-oriented homepage while keeping standard `page`, `post`, and `pdf` layouts available for the rest of the site.

## 🗄️ Data Contract
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

## 💻 Local Development
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
