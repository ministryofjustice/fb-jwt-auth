require_relative 'lib/fb/jwt/auth/version'

Gem::Specification.new do |spec|
  spec.name          = "fb-jwt-auth"
  spec.version       = Fb::Jwt::Auth::VERSION
  spec.authors       = ['Form builder developers']
  spec.email         = ['form-builder-developers@digital.justice.gov.uk']

  spec.summary       = %q{JWT authentication done in form builder team}
  spec.description   = %q{JWT authentication done in all apps in form builder}
  spec.homepage      = 'https://github.com/ministryofjustice/fb-jwt-auth'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ministryofjustice/fb-jwt-auth"
  spec.metadata["changelog_uri"] = "https://github.com/ministryofjustice/fb-jwt-auth/blob/main/Changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'jwt'
  spec.add_dependency 'json'
  spec.add_dependency 'activesupport'
end
