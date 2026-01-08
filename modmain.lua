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
  local valid_recipes = hud and hud.valid_recipes
  if not (HUD and valid_recipes and widget) then return end

  local recipes_can_build = {} -- sort recipes that we can build before all other recipes
  local recipes_others = {}
  for _, recipe in ipairs(recipes[prefab] or {}) do
    local data = valid_recipes[recipe]
    if data and data.meta and data.meta.can_build then
      table.insert(recipes_can_build, data)
    else
      table.insert(recipes_others, data)
    end
  end
  local filtered_recipes = {}
  for _, data in ipairs(recipes_can_build) do
    table.insert(filtered_recipes, data)
  end
  for _, data in ipairs(recipes_others) do
    table.insert(filtered_recipes, data)
  end
  if #filtered_recipes == 0 then return end -- no possible recipes found, nothing to do.

  if AUTO_OPEN_CRAFT_MENU then HUD:OpenCrafting() end
  ForceFilterEverything(widget)
  widget.search_box.textbox:SetString(prefab)
  widget.no_recipes_msg:Hide()
  widget.recipe_grid:ResetScroll()
  widget.recipe_grid:SetItemsData(filtered_recipes)
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
  function self:RemoteInspectItemFromInvTile(item)
    CraftFinder(item and item.prefab)
    return OldRemoteInspectItemFromInvTile(self, item)
  end

  local OldRemoteInspectButton = self.RemoteInspectButton
  function self:RemoteInspectButton(action)
    CraftFinder(action and action.target and action.target.prefab)
    return OldRemoteInspectButton(self, action)
  end

  local OldRemoteUseItemFromInvTile = self.RemoteUseItemFromInvTile
  function self:RemoteUseItemFromInvTile(buffaction, item)
    local prefab = item and item.prefab
    if buffaction.action == GLOBAL.ACTIONS.LOOKAT then CraftFinder(prefab) end
    return OldRemoteUseItemFromInvTile(self, buffaction, item)
  end

  if GetModConfigData('enable_inspect_on_ground') then
    local OldDoAction = self.DoAction
    function self:DoAction(buffaction, ...)
      local prefab = buffaction and buffaction.target and buffaction.target.prefab
      if buffaction.action == GLOBAL.ACTIONS.LOOKAT then CraftFinder(prefab) end
      return OldDoAction(self, buffaction, ...)
    end
  end
end)

if GetModConfigData('prevent_tech_tree_refresh') then -- no more messing up current page!
  AddClassPostConstruct('widgets/redux/craftingmenu_widget', function(self)
    function self:Refresh()
      self:UpdateFilterButtons() -- e.g. the crafting station button on the left side of search box
      self.recipe_grid:RefreshView() -- update the recipe state visual hint, e.g. the lightbulb or lock icon
      self.details_root:Refresh() -- update the detail below
    end
  end)
end
