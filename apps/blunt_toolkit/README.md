# Blunt Toolkit

There is currently only one "tool" in this repo. The Aggregate Inspector.

`threequarterspi` over on Slack asked if anyone had implemented some sort of time-traveling for `Commanded`. 

I immediately thought of the `redux devtools` and thought that would be pretty cool for viewing aggregate state over time...with real data.

So I set out to get a bit of something working. 

After discovering and digging a bit into [ratatouille](https://github.com/ndreynolds/ratatouille), I was able to get that little something.

https://user-images.githubusercontent.com/364786/155075370-407d76f1-a002-4dfb-9fa6-d29ca14eda64.mp4


## Usage


Add `{:blunt_toolkit, github: "elixir-blunt/blunt_toolkit", runtime: false, only: :dev}` to your deps and run `mix deps.get`.

You can launch the UI with `mix blunt.inspect.aggregate`. 

That can be a drag to type all the time, so I would recommend assigning an alias in your mix file.

```elixir
  def aliases do
    [
      view_state: "blunt.inspect.aggregate"
    ]
  end
```

and make sure you're including aliases in your project function.

```elixir
  def project do
    [
      ...
      deps: deps(),
      aliases: aliases(),
      ...
    ]
  end
```

Now you can just run `mix view_state`


### Navigation 

You can use the <kbd>⬆</kbd> / <kbd>⬇</kbd> or <kbd>j</kbd> / <kbd>k</kbd> keys to navigate through the history of your aggregate.

### Exiting

Strike <kbd>Ctrl+c</kbd> with some heft.

## notes

* The event store module you enter *must* be a valid EventStore.

* The aggregate module you enter *must* be a valid aggregate module with an `apply/2` function.

* The stream must exist. Duh

* The next time you run the mix task, it will present you with your last answers as defaults.


## Development

You'll need a local postgres install with username `postgres` and password `postgres` (or alter `config/config.exs`)

To populate some events run `mix test`

Then start the UI via `mix view_state`.

Debugging this is difficult to say the least. Logs are swallowed, and it seems all `IO` functions are swallowed as well.

I just start a file in `init`, define a log function, and simply call `log` when I need to see something.

```elixir
  def init(_context) do
    {:ok, file} = File.open("debug.log", [:append, {:delayed_write, 100, 20}]
        config = %{
          logfile: file,
      stream: "",
      ...
  end

  defp log(%{logfile: logfile}, title \\ "", content) do
    IO.binwrite(
      logfile,
      title <> " - " <> inspect(content, pretty: true, limit: :infinity) <> "\n"
    )

    content
  end
```

## Things to consider.

This was a result of about 2 hours of playing around. It's not optimized for large streams. 

It would be nice to be able to just grab n events up front and request more events as needed. 

But `¯\_(ツ)_/¯`
