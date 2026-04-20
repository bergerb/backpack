require "fileutils"
require "rubygems"
require "minitest/autorun"
require "open3"

class SiteBuildTest < Minitest::Test
  def test_builds_resume_home_page
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

    assert_includes html, "Sample Engineer"
    assert_includes html, "Professional Experience"
    assert_includes html, "<title>Sample Engineer | Backpack</title>"
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
end
