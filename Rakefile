require "rake/testtask"

Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.pattern = "test/**/*_test.rb"
end

desc "Build the demo site"
task :build do
  sh "bundle exec jekyll build"
end

task default: :test

