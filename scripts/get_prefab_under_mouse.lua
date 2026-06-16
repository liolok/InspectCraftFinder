-- shortcut for code like `ThePlayer and ThePlayer.replica and ThePlayer.replica.inventory`
local function Get(head_node, ...)
  local current_node = head_node
  for _, key in ipairs({ ... }) do
    if not current_node then return end

    local next_node = current_node[key]
    if type(next_node) == 'function' then -- for code like `ThePlayer.replica.inventory:GetActiveItem()`
      current_node = next_node(current_node) -- this could be `false`/`nil` so avoid assigning with `and or`
    else
      current_node = next_node
    end
  end
  return current_node
end

return function()
  local item_slot = Get(TheInput, 'GetHUDEntityUnderMouse', 'widget', 'parent', 'parent')
  local item_hovered = Get(item_slot, 'tile', 'item') or Get(item_slot, 'item')
  return Get(item_hovered, 'prefab')
end
