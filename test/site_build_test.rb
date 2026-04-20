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

  def test_home_layout_normalizes_mode_and_routes_resume_partials
    layout = File.read(File.join(repo_root, "_layouts", "home.html"))

    assert_includes layout, '{% assign backpack_mode = site.backpack.mode | default: "resume" | downcase %}'
    assert_includes layout, '{% unless backpack_mode == "blog" %}'
    assert_includes layout, "{% include hero_resume.html %}"
    assert_includes layout, "{% include home_resume.html %}"
    refute_includes layout, "{% include header.html %}"
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
    assert_includes specification.files, "_includes/hero_resume.html"
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

  def assert_resume_home_structure(html)
    assert_includes html, "Sample Engineer"
    assert_includes html, "<title>Sample Engineer | Backpack</title>"
    assert_includes html, '<header class="hero">'
    assert_includes html, '<main class="resume-layout">'
    assert_includes html, '<aside class="sidebar">'
    assert_includes html, '<section class="content">'
    assert_includes html, "Professional Experience"
    assert_includes html, "Core Strengths"
  end
end
