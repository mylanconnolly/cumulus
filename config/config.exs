# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if File.exists?(Path.join([File.cwd!(), "config", "config.secret.exs"])) do
  import_config "config.secret.exs"
end
