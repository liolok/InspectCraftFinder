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

local function HookInspect(item)
  local prefab = item and item.prefab
  if type(prefab) ~= 'string' then return end -- invalid prefab
  if TUNING.WtCwT.key_handler then return end -- key binding already exists, don't hook Inspect actions.
  if not TUNING.WtCwT.recipes[prefab] then return end -- no recipes found
  return ShowRecipesByIngredient(prefab)
end

-- Regular world
AddComponentPostInit('playercontroller', function(self)
  -- Should be using controller to Inspect? untested anyway
  local OldRemoteInspectItemFromInvTile = self.RemoteInspectItemFromInvTile
  function self:RemoteInspectItemFromInvTile(item)
    HookInspect(item)
    return OldRemoteInspectItemFromInvTile(self, item)
  end

  -- RMB to Inspect or Alt + LMB to Examine
  local OldRemoteUseItemFromInvTile = self.RemoteUseItemFromInvTile
  function self:RemoteUseItemFromInvTile(buffaction, item)
    if buffaction.action == G.ACTIONS.LOOKAT then HookInspect(item) end
    return OldRemoteUseItemFromInvTile(self, buffaction, item)
  end

  if GetModConfigData('hook_item_on_ground') then
    local OldDoAction = self.DoAction
    function self:DoAction(buffaction, ...)
      if buffaction.action == G.ACTIONS.LOOKAT then HookInspect(buffaction.target) end
      return OldDoAction(self, buffaction, ...)
    end
  end
end)

-- Local forest-only world or Dont Starve Alone world
AddComponentPostInit('inventory', function(self)
  -- RMB on inventory item to "Inspect"
  local OldUseItemFromInvTile = self.UseItemFromInvTile
  function self:UseItemFromInvTile(item, ...)
    local actions = self.inst.components.playeractionpicker:GetInventoryActions(item)
    local act = actions[1]
    if act.action == G.ACTIONS.LOOKAT then HookInspect(item) end
    return OldUseItemFromInvTile(self, item, ...)
  end

  -- Alt + LMB on inventory item to "Examine"
  local OldInspectItemFromInvTile = self.InspectItemFromInvTile
  function self:InspectItemFromInvTile(item)
    HookInspect(item)
    return OldInspectItemFromInvTile(self, item)
  end
end)

-- No more messing up current page!
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
