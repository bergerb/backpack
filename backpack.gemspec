# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "backpack"
  spec.version       = "0.1.0"
  spec.authors       = ["Brent Berger"]
  spec.email         = ["brent@bergerb.net"]

  spec.summary       = "Resume-inspired Jekyll theme for personal sites"
  spec.homepage      = "https://github.com/bergerb/backpack"
  spec.license       = "MIT"

  spec.files = Dir.glob("{assets,_layouts,_includes,_sass}/**/*", File::FNM_DOTMATCH)
                  .reject { |file| File.directory?(file) }
                  .concat(%w[LICENSE README.md])

  spec.add_runtime_dependency "jekyll", "~> 4.4"
  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "webrick", "~> 1.9"
end

