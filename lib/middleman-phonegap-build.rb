require 'middleman-core'

require 'middleman-phonegap-build/commands'

::Middleman::Extensions.register(:phonegap_build) do
  require 'middleman-phonegap-build/extension'
  ::Middleman::PhonegapBuild
end
