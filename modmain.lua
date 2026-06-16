local G = GLOBAL

modimport('languages/en') -- load translation strings with English fallback
local lang = 'languages/' .. G.LOC.GetLocaleCode()
if G.kleifileexists(MODROOT .. lang .. '.lua') then modimport(lang) end

TUNING.WtCwT = { override_filter = false, recipes = {}, key_handler = nil }
local ShowRecipesByIngredient = require('show_recipes_by_ingredient')

AddPlayerPostInit(function()
  TUNING.WtCwT.recipes = {} -- ingredient as key, recipes table as value
  for recipe_name, recipe in pairs(G.AllRecipes) do
    for _, ingredient in ipairs(recipe.ingredients) do
      local prefab = ingredient.type -- prefab of ingredient
      if not TUNING.WtCwT.recipes[prefab] then TUNING.WtCwT.recipes[prefab] = {} end
      table.insert(TUNING.WtCwT.recipes[prefab], recipe_name)
    end
  end
end)

AddComponentPostInit('playercontroller', function(self)
  local OldRemoteInspectItemFromInvTile = self.RemoteInspectItemFromInvTile
  function self:RemoteInspectItemFromInvTile(item)
    if not TUNING.WtCwT.key_handler then ShowRecipesByIngredient(item and item.prefab) end
    return OldRemoteInspectItemFromInvTile(self, item)
  end

  local OldRemoteInspectButton = self.RemoteInspectButton
  function self:RemoteInspectButton(action)
    if not TUNING.WtCwT.key_handler then ShowRecipesByIngredient(action and action.target and action.target.prefab) end
    return OldRemoteInspectButton(self, action)
  end

  local OldRemoteUseItemFromInvTile = self.RemoteUseItemFromInvTile
  function self:RemoteUseItemFromInvTile(buffaction, item)
    if not TUNING.WtCwT.key_handler and buffaction.action == G.ACTIONS.LOOKAT then
      ShowRecipesByIngredient(item and item.prefab)
    end
    return OldRemoteUseItemFromInvTile(self, buffaction, item)
  end
end)

-- no more messing up current page!
AddClassPostConstruct('widgets/redux/craftingmenu_widget', function(self)
  local OldRefresh = self.Refresh
  function self:Refresh(...)
    if TUNING.WtCwT.override_filter then
      self:UpdateFilterButtons() -- e.g. the crafting station button on the left side of search box
      self.recipe_grid:RefreshView() -- update the recipe state visual hint, e.g. the lightbulb or lock icon
      self.details_root:Refresh() -- update the detail below
    else
      return OldRefresh(self, ...)
    end
  end

  local OldSelectFilter = self.SelectFilter
  function self:SelectFilter(...)
    TUNING.WtCwT.override_filter = false
    return OldSelectFilter(self, ...)
  end
end)

modimport('keybind')
local Input = G.TheInput
local GetPrefabUnderMouse = require('get_prefab_under_mouse')

function KeyBind(_, key)
  -- disable old binding
  if TUNING.WtCwT.key_handler then
    TUNING.WtCwT.key_handler:Remove()
    TUNING.WtCwT.key_handler = nil
  end

  -- new binding
  local function f(_key, down) return (_key == key and down) and ShowRecipesByIngredient(GetPrefabUnderMouse()) end
  TUNING.WtCwT.key_handler = key and (key >= 1000 and Input:AddMouseButtonHandler(f) or Input:AddKeyHandler(f))
end
