local recipes = {}
local AUTO_OPEN_CRAFT_MENU = GetModConfigData('auto_open_craft_menu')

local function ForceFilterEverything(widget)
  if widget.current_filter_name == 'EVERYTHING' then return end

  if widget.current_filter_name and widget.filter_buttons[widget.current_filter_name] then
    widget.filter_buttons[widget.current_filter_name].button:Unselect()
  end
  widget.filter_buttons['EVERYTHING'].button:Select()

  widget.current_filter_name = 'EVERYTHING'
end

local function CraftFinder(prefab)
  if not prefab then return end
  local HUD = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD -- screens/playerhud
  local hud = HUD and HUD.controls and HUD.controls.craftingmenu -- widgets/redux/craftingmenu_hud
  local widget = hud and hud.craftingmenu -- widgets/redux/craftingmenu_widget
  if not widget then return end

  local recipes_data = {}
  for _, recipe in ipairs(recipes[prefab] or {}) do
    local data = hud.valid_recipes[recipe]
    table.insert(recipes_data, data)
  end
  if #recipes_data == 0 then return end -- no possible recipes found, nothing to do.

  if AUTO_OPEN_CRAFT_MENU then HUD:OpenCrafting() end
  ForceFilterEverything(widget)
  widget.search_box.textbox:SetString(prefab)
  widget.no_recipes_msg:Hide()
  widget.recipe_grid:ResetScroll()
  widget.recipe_grid:SetItemsData(recipes_data)
  widget.recipe_grid.dirty = false
  widget.details_root:PopulateRecipeDetailPanel()
end

AddPlayerPostInit(function()
  recipes = {}
  for recipe_name, recipe in pairs(GLOBAL.AllRecipes) do
    for _, ingredient in ipairs(recipe.ingredients) do
      local prefab = ingredient.type -- prefab of ingredient
      if not recipes[prefab] then recipes[prefab] = {} end
      table.insert(recipes[prefab], recipe_name)
    end
  end
end)

AddComponentPostInit('playercontroller', function(self)
  local OldRemoteInspectItemFromInvTile = self.RemoteInspectItemFromInvTile
  self.RemoteInspectItemFromInvTile = function(self, item)
    CraftFinder(item and item.prefab)
    return OldRemoteInspectItemFromInvTile(self, item)
  end

  local OldRemoteInspectButton = self.RemoteInspectButton
  self.RemoteInspectButton = function(self, action)
    CraftFinder(action and action.target and action.target.prefab)
    return OldRemoteInspectButton(self, action)
  end

  local OldRemoteUseItemFromInvTile = self.RemoteUseItemFromInvTile
  self.RemoteUseItemFromInvTile = function(self, buffaction, item)
    local prefab = item and item.prefab
    if buffaction.action == GLOBAL.ACTIONS.LOOKAT then CraftFinder(prefab) end
    return OldRemoteUseItemFromInvTile(self, buffaction, item)
  end

  if GetModConfigData('enable_inspect_on_ground') then
    local OldDoAction = self.DoAction
    self.DoAction = function(self, buffaction, ...)
      local prefab = buffaction and buffaction.target and buffaction.target.prefab
      if buffaction.action == GLOBAL.ACTIONS.LOOKAT then CraftFinder(prefab) end
      return OldDoAction(self, buffaction, ...)
    end
  end
end)
