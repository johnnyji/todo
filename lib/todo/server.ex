defmodule Todo.Server do
  use Supervisor

  alias Todo.Cache

  def add_list(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  def find_list(name) do
    Enum.find get_lists, fn(child) ->
      Todo.List.name(child) == name
    end
  end

  def delete_list(list) do
    Supervisor.terminate_child(__MODULE__, list)
  end

  def get_lists do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.map(fn({_, child, _, _}) -> child end)
  end

  def populate_lists do
    # Populates the server with existing Todo.Cache state
    for list <- Cache.get_lists, do: add_list(list)
  end

  ###
  # Supervisor API
  ###

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Todo.List, [], restart: :transient)
    ]

    populate_lists

    supervise(children, strategy: :simple_one_for_one)
  end
end
