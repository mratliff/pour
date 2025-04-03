defmodule PourWeb.Helpers do
  def list_select_for(named_entity_list) do
    Enum.map(named_entity_list, fn %{id: id, name: name} ->
      {name, id}
    end)
  end
end
