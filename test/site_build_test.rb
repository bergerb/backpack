require "fileutils"
require "rubygems"
require "minitest/autorun"
require "open3"

class SiteBuildTest < Minitest::Test
  def test_explicit_resume_mode_preserves_resume_home_structure
    html = home_page_html(config_contents: <<~YAML)
      backpack:
        mode: resume
    YAML

    assert_resume_home_structure(html)
  end

  def test_missing_mode_defaults_to_resume_home_structure
    html = home_page_html
    assert_resume_home_structure(html)
  end

  def test_unknown_mode_defaults_to_resume_home_structure
    html = home_page_html(config_contents: <<~YAML)
      backpack:
        mode: unknown
    YAML
    assert_resume_home_structure(html)
  end

  def test_explicit_blog_mode_renders_blog_home_structure
    html = home_page_html(config_contents: <<~YAML)
      backpack:
        mode: blog
    YAML

    assert_blog_home_structure(html)
  end

  def test_blog_mode_renders_social_panel_above_recent_posts
    html = home_page_html(config_contents: <<~YAML)
      backpack:
        mode: blog
    YAML

    assert_includes html, "<h2>Find me online</h2>"
    assert_includes html, "github.com/bergerb"
    assert_includes html, "linkedin.com/in/brent-berger-bb19719"
    assert_match(
      %r{<section class="content" data-backpack-home="blog">.*?<section class="panel panel--wide">.*?<h2>Recent Writing</h2>.*?</section>\s*</section>\s*<aside class="sidebar sidebar--blog">.*?<section class="panel panel--blog-social" data-backpack-section="blog-social">.*?<h2>Find me online</h2>}m,
      html
    )
  end

  def test_blog_mode_uses_configured_identity_line_and_subtitle
    html = home_page_html(config_contents: <<~YAML)
      title: "Bergerb"
      author: "Brent Berger"
      subtitle: "Adventures in Software Development and Life"
      backpack:
        mode: blog
        blog_eyebrow: "BERGERB.NET"
    YAML
    
    assert_includes html, "<p class=\"eyebrow\">BERGERB.NET</p>"
    assert_includes html, "<h1>Brent Berger</h1>"
    assert_includes html, "<p class=\"hero__summary\">Adventures in Software Development and Life</p>"
    refute_includes html, "BERGERB.NET, Brent Berger, Adventures in Software Development and Life"
    refute_includes html, "Building secure, accessible, and maintainable software with a calm delivery cadence."
  end

  def test_blog_mode_falls_back_to_title_author_and_subtitle_on_separate_lines
    html = home_page_html(config_contents: <<~YAML)
      title: "Bergerb"
      author: "Brent Berger"
      subtitle: "Adventures in Software Development and Life"
      backpack:
        mode: blog
    YAML

    assert_includes html, "<p class=\"eyebrow\">BERGERB</p>"
    assert_includes html, "<h1>Brent Berger</h1>"
    assert_includes html, "<p class=\"hero__summary\">Adventures in Software Development and Life</p>"
    refute_includes html, "BERGERB, Brent Berger, Adventures in Software Development and Life"
    refute_includes html, "<h1>Sample Engineer</h1>"
  end

  def test_blog_mode_renders_avatar_on_the_right_when_configured
    html = home_page_html(config_contents: <<~YAML)
      avatar_url: "https://example.com/avatar.png"
      backpack:
        mode: blog
    YAML

    assert_match(
      %r{<div class="hero__media">\s*<img class="hero__avatar" src="https://example.com/avatar\.png" alt="Sample Engineer portrait">\s*</div>}m,
      html
    )
  end

  def test_home_layout_normalizes_mode_and_routes_resume_partials
    layout = home_layout

    assert_resume_mode_routing(layout)
    assert_blog_mode_routing(layout)
    refute_includes layout, "{% include header.html %}"
  end

  def test_site_header_normalizes_mode_same_as_home_layout
    include_template = site_header_include

    assert_includes include_template, '{% assign backpack_mode = backpack_mode | default: site.backpack.mode | default: "resume" | downcase %}'
    assert_includes include_template, '{% unless backpack_mode == "blog" %}'
    assert_includes include_template, '{% assign backpack_mode = "resume" %}'
  end

  def test_recent_posts_description_uses_default_without_dead_guard
    include_template = recent_posts_include
 
    assert_includes include_template, '{% assign description = include.description | default: "Blog-ready theme support for posts and page navigation." %}'
    refute_includes include_template, "{% if description %}"
  end

  def test_recent_posts_include_preserves_pagination_navigation
    include_template = recent_posts_include

    assert_includes include_template, "{% for post in recent_posts %}"
    refute_includes include_template, "limit: 5"
    assert_includes include_template, "{% if paginator.total_pages > 1 %}"
    assert_includes include_template, "{% if paginator.previous_page %}"
    assert_includes include_template, "{% if paginator.next_page %}"
  end

  def test_builds_standard_page_content
    output_directory = File.join(repo_root, "_site_test")
    FileUtils.rm_rf(output_directory)

    stdout, stderr, status = Open3.capture3(
      { "BUNDLE_GEMFILE" => File.join(repo_root, "Gemfile") },
      "bundle exec jekyll build --source . --destination _site_test",
      chdir: repo_root
    )

    assert status.success?, <<~MESSAGE
      Expected the demo site build to succeed.
      STDOUT:
      #{stdout}
      STDERR:
      #{stderr}
    MESSAGE

    html = File.read(File.join(output_directory, "about", "index.html"))

    assert_includes html, "About Backpack"
    assert_includes html, "remote theme"
  end

  def test_blog_mode_page_layout_keeps_hero_header
    output_directory = build_site(config_contents: <<~YAML)
      backpack:
        mode: blog
    YAML

    html = File.read(File.join(output_directory, "about", "index.html"))

    assert_includes html, '<div class="site-shell">'
    assert_includes html, '<header class="hero hero--compact">'
    assert_includes html, '<p class="eyebrow">BACKPACK</p>'
    assert_match(%r{<div class="hero__actions">.*About Backpack.*</div>}m, html)
    assert_includes html, "<h1>About Backpack</h1>"
    refute_includes html, "<img class=\"hero__avatar\""
    refute_includes html, "<p class=\"hero__summary\">"
    refute_includes html, 'class="site-bar"'
  end

  def test_builds_pdf_resume_view
    output_directory = File.join(repo_root, "_site_test")
    FileUtils.rm_rf(output_directory)

    stdout, stderr, status = Open3.capture3(
      { "BUNDLE_GEMFILE" => File.join(repo_root, "Gemfile") },
      "bundle exec jekyll build --source . --destination _site_test",
      chdir: repo_root
    )

    assert status.success?, <<~MESSAGE
      Expected the demo site build to succeed.
      STDOUT:
      #{stdout}
      STDERR:
      #{stderr}
    MESSAGE

    html = File.read(File.join(output_directory, "pdf", "index.html"))

    assert_includes html, "Sample Engineer"
    assert_includes html, "Senior Full-Stack Engineer"
  end

  def test_gemspec_packages_theme_files
    specification = Gem::Specification.load(File.join(repo_root, "backpack.gemspec"))

    assert_includes specification.files, "_layouts/home.html"
    assert_includes specification.files, "_includes/header.html"
    assert_includes specification.files, "_includes/blog_social.html"
    assert_includes specification.files, "_includes/hero_blog.html"
    assert_includes specification.files, "_includes/hero_resume.html"
    assert_includes specification.files, "_includes/home_blog.html"
    assert_includes specification.files, "_includes/home_resume.html"
    assert_includes specification.files, "assets/css/main.css"
  end

  def test_home_page_lists_navigation_and_recent_posts
    output_directory = File.join(repo_root, "_site_test")
    FileUtils.rm_rf(output_directory)

    stdout, stderr, status = Open3.capture3(
      { "BUNDLE_GEMFILE" => File.join(repo_root, "Gemfile") },
      "bundle exec jekyll build --source . --destination _site_test",
      chdir: repo_root
    )

    assert status.success?, <<~MESSAGE
      Expected the demo site build to succeed.
      STDOUT:
      #{stdout}
      STDERR:
      #{stderr}
    MESSAGE

    html = File.read(File.join(output_directory, "index.html"))

    assert_includes html, "About Backpack"
    assert_includes html, "Welcome to Backpack"
  end

  def test_post_page_renders_metadata_and_comments
    output_directory = File.join(repo_root, "_site_test")
    FileUtils.rm_rf(output_directory)

    stdout, stderr, status = Open3.capture3(
      { "BUNDLE_GEMFILE" => File.join(repo_root, "Gemfile") },
      "bundle exec jekyll build --source . --destination _site_test",
      chdir: repo_root
    )

    assert status.success?, <<~MESSAGE
      Expected the demo site build to succeed.
      STDOUT:
      #{stdout}
      STDERR:
      #{stderr}
    MESSAGE

    html = File.read(File.join(output_directory, "2026", "01", "01", "welcome-to-backpack", "index.html"))

    assert_includes html, "Welcome to Backpack"
    assert_includes html, "Jan 1, 2026"
    assert_includes html, "Backpack can now host standard blog posts"
    assert_includes html, "backpack-demo.disqus.com/embed.js"
  end

  def test_blog_mode_post_layout_keeps_hero_header
    output_directory = build_site(config_contents: <<~YAML)
      backpack:
        mode: blog
    YAML

    html = File.read(File.join(output_directory, "2026", "01", "01", "welcome-to-backpack", "index.html"))

    assert_includes html, '<div class="site-shell">'
    assert_includes html, '<header class="hero hero--compact">'
    assert_match(%r{<div class="hero__actions">.*About Backpack.*</div>}m, html)
    assert_includes html, "<h1>Welcome to Backpack</h1>"
    assert_includes html, "backpack-demo.disqus.com/embed.js"
    refute_includes html, "<img class=\"hero__avatar\""
    refute_includes html, "<p class=\"hero__summary\">"
    refute_includes html, 'class="site-bar"'
  end

  private

  def repo_root
    File.expand_path("..", __dir__)
  end

  def build_site(config_contents: nil)
    output_directory = File.join(repo_root, "_site_test")
    config_override_path = File.join(repo_root, "_test_config_override.yml")

    FileUtils.rm_rf(output_directory)
    FileUtils.rm_f(config_override_path)

    command = "bundle exec jekyll build --source . --destination _site_test"

    if config_contents
      File.write(config_override_path, config_contents)
      command += " --config _config.yml,_test_config_override.yml"
    end

    stdout, stderr, status = Open3.capture3(
      { "BUNDLE_GEMFILE" => File.join(repo_root, "Gemfile") },
      command,
      chdir: repo_root
    )

    assert status.success?, <<~MESSAGE
      Expected the demo site build to succeed.
      Command:
      #{command}
      STDOUT:
      #{stdout}
      STDERR:
      #{stderr}
    MESSAGE

    output_directory
  ensure
    FileUtils.rm_f(config_override_path)
  end

  def home_page_html(config_contents: nil)
    output_directory = build_site(config_contents: config_contents)
    File.read(File.join(output_directory, "index.html"))
  end

  def home_layout
    File.read(File.join(repo_root, "_layouts", "home.html"))
  end

  def site_header_include
    File.read(File.join(repo_root, "_includes", "site_header.html"))
  end

  def recent_posts_include
    File.read(File.join(repo_root, "_includes", "recent_posts.html"))
  end

  def assert_resume_home_structure(html)
    assert_includes html, "Sample Engineer"
    assert_includes html, "<title>Sample Engineer | Backpack</title>"
    assert_includes html, '<header class="hero">'
    assert_includes html, '<main class="resume-layout" data-backpack-mode="resume">'
    assert_includes html, '<aside class="sidebar">'
    assert_includes html, '<section class="content">'
    assert_includes html, "Professional Experience"
    assert_includes html, "Core Strengths"
    refute_includes html, 'data-backpack-home="blog"'
    refute_includes html, 'data-backpack-section="blog-social"'
    refute_includes html, "<h2>Find me online</h2>"
  end

  def assert_blog_home_structure(html)
    assert_includes html, "Sample Engineer"
    assert_includes html, "<title>Sample Engineer | Backpack</title>"
    assert_includes html, '<main class="blog-layout" data-backpack-mode="blog">'
    assert_includes html, '<section class="content" data-backpack-home="blog">'
    assert_includes html, '<aside class="sidebar sidebar--blog">'
    assert_includes html, 'data-backpack-section="blog-social"'
    assert_includes html, '<header class="hero">'
    assert_match(%r{<div class="hero__actions">.*About Backpack.*</div>}m, html)
    assert_includes html, "Welcome to Backpack"

    refute_includes html, 'class="site-bar"'
    refute_includes html, "Core Strengths"
    refute_includes html, "Professional Experience"
    refute_includes html, "Senior Full-Stack Engineer"
  end

  def assert_resume_mode_routing(layout)
    assert_includes layout, '{% assign backpack_mode = site.backpack.mode | default: "resume" | downcase %}'
    assert_includes layout, '{% unless backpack_mode == "blog" %}'
    assert_includes layout, '{% assign backpack_mode = "resume" %}'
    assert_includes layout, "{% include hero_resume.html %}"
    assert_includes layout, "{% include home_resume.html %}"
  end

  def assert_blog_mode_routing(layout)
    assert_includes layout, '{% if backpack_mode == "blog" %}'
    assert_includes layout, "{% include hero_blog.html %}"
    assert_includes layout, "{% include home_blog.html %}"
  end
end
