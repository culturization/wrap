# frozen_string_literal: true

require_relative 'lib/wrap/version'

Gem::Specification.new do |spec|
  spec.name = 'wrap'
  spec.version = Wrap::VERSION
  spec.authors = ['culturization']
  spec.email = ['58606521+culturization@users.noreply.github.com']

  spec.summary = 'Simple Discord wrapper'
  spec.homepage = 'https://github.com/culturization/wrap'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/culturization/wrap'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'websocket-client-simple'
end
