# Cumulus

This is a simple client for Google Cloud Storage.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cumulus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cumulus, "~> 0.1.0"}
  ]
end
```

This library makes use of the environment credentials, which are either set up
automatically by Google Compute Engine or can be set up using the Google
Cloud SDK. Make sure one of these has been done.

Next, you'll need to add the following configuration to your project if you
are not on Google Compute Engine:

```elixir
config :goth, project_id: "name-of-project"
```

## Testing

Note that testing requires you to create a configuration file `config.secret.exs`
and place it in the [config](config) directory. The contents of this file
should be:

```elixir
use Mix.Config

config :goth, project_id: "name-of-project"
```

Additionally, make sure that you are either running from within a Google
Compute Engine instance or have the Google Cloud SDK installed, and have
configured the application default credentials.

These steps are necessary for authentication to work correctly.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cumulus](https://hexdocs.pm/cumulus).
