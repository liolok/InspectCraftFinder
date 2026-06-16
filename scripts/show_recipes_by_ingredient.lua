local T = TUNING.WtCwT

local function PrioritizeRecipe(recipe)
  local meta_data = recipe and recipe.meta
  if meta_data then
    local build_state = meta_data.build_state
    if meta_data.can_build then
      if build_state == 'prototype' then return 3 end
      if build_state == 'buffered' then return 2 end
      return 1
    else
      if build_state == 'prototype' then return 0.9 end
      if build_state == 'no_ingredients' then return 0.8 end
      return 0
    end
  else
    return -1
  end
end

local function CompareRecipe(a, b) return PrioritizeRecipe(a) > PrioritizeRecipe(b) end

local function ForceFilterEverything(widget)
  if widget.current_filter_name == 'EVERYTHING' then return end

  if widget.current_filter_name and widget.filter_buttons[widget.current_filter_name] then
    widget.filter_buttons[widget.current_filter_name].button:Unselect()
  end
  widget.filter_buttons['EVERYTHING'].button:Select()

  widget.current_filter_name = 'EVERYTHING'
end

local function GetName(prefab) return STRINGS.NAMES[prefab:upper()] end

return function(prefab)
  if not prefab then return end

  local HUD = ThePlayer and ThePlayer.HUD -- screens/playerhud
  local hud = HUD and HUD.controls and HUD.controls.craftingmenu -- widgets/redux/craftingmenu_hud
  if hud then hud:RebuildRecipes() end
  local widget = hud and hud.craftingmenu -- widgets/redux/craftingmenu_widget
  local valid_recipes = hud and hud.valid_recipes
  if not (HUD and valid_recipes and widget) then return end

  local filtered_recipes = {}
  for _, recipe in ipairs(T.recipes[prefab] or {}) do
    table.insert(filtered_recipes, valid_recipes[recipe])
  end
  if #filtered_recipes == 0 then return end -- no possible recipes found, nothing to do.

  table.sort(filtered_recipes, CompareRecipe)

  HUD:OpenCrafting()

  T.override_filter = true
  ForceFilterEverything(widget)
  widget.search_box.textbox.prompt:SetString(subfmt(STRINGS.WtCwT, { ingredient = GetName(prefab) }))
  widget.no_recipes_msg:Hide()
  widget.recipe_grid:ResetScroll()
  widget.recipe_grid:SetItemsData(filtered_recipes)
  widget.recipe_grid.dirty = false
  widget:PopulateRecipeDetailPanel()
end
