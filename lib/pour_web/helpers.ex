defmodule PourWeb.Helpers do
  def list_select_for(named_entity_list, label_field \\ :name) do
    Enum.map(named_entity_list, fn entity_map ->
      {Map.get(entity_map, label_field), Map.get(entity_map, :id)}
    end)
  end
end
