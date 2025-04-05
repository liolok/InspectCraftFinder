-- GLOBAL.CHEATS_ENABLED = true
-- GLOBAL.require( 'debugkeys' )

local Image = GLOBAL.require("widgets/image")

local recipes = {}
local actionstrs = {CARTOGRAPHY = true, ORPHANAGE = true, SOCKET = true}
local PlayerHUD
local loaded = false

local function isValidRecipe(pj, recipeV)
    if recipeV.hint_msg then return false end
    if recipeV.builder_tag and not pj:HasTag(recipeV.builder_tag) then return false end
    if recipeV.actionstr and not actionstrs[recipeV.actionstr] then return false end
    return true
end

local function ForceFilterEverything(craftWidget)
    if craftWidget.current_filter_name == "EVERYTHING" then return end

	if craftWidget.current_filter_name ~= nil and craftWidget.filter_buttons[craftWidget.current_filter_name] ~= nil then
		craftWidget.filter_buttons[craftWidget.current_filter_name].button:Unselect()
	end
	craftWidget.filter_buttons["EVERYTHING"].button:Select()

    craftWidget.current_filter_name = "EVERYTHING"
end

local function CraftFinder(prefab)
    if not prefab or not PlayerHUD then return end

    local craftHUD = PlayerHUD.controls.craftingmenu;
    local f_recipes = {}
    if recipes[prefab] then
        for _, recipe in ipairs(recipes[prefab]) do
            table.insert(f_recipes, craftHUD.valid_recipes[recipe])
        end
    end

    -- print(GLOBAL.GetInventoryItemAtlas(prefab..".tex"))
    -- if test then
    --     test:SetTexture(GLOBAL.GetInventoryItemAtlas(prefab..".tex"), prefab..".tex")
    -- else
    --     test = PlayerHUD.controls.topleft_root:AddChild(Image(GLOBAL.GetInventoryItemAtlas(prefab..".tex"), prefab..".tex"))
    --     test:ScaleToSize(32,32)
    --     test:SetPosition(16, -16)
    -- end

    local craftWidget = craftHUD.craftingmenu
    if #f_recipes > 0 then
        PlayerHUD:OpenCrafting()
        craftWidget.search_box.textbox:SetString(prefab)
        ForceFilterEverything(craftWidget)
        craftWidget.no_recipes_msg:Hide();
        craftWidget.recipe_grid:ResetScroll(); craftWidget.recipe_grid:SetItemsData(f_recipes); craftWidget.recipe_grid.dirty = false;
        craftWidget.details_root:PopulateRecipeDetailPanel();
    end
end

AddPlayerPostInit(function(pj)
    recipes = {}
    for Rname, Rvalue in pairs(GLOBAL.AllRecipes) do
        for _, ing in ipairs(Rvalue.ingredients) do
            if isValidRecipe(pj, Rvalue) then
                if not recipes[ing.type] then recipes[ing.type] = {} end
                table.insert(recipes[ing.type], Rname)
            end
        end
    end
end)

AddComponentPostInit("playercontroller", function(playercontroller)
    PlayerHUD = GLOBAL.ThePlayer.HUD

    if GLOBAL.TheNet:GetIsServer() then return end;

    local old_RemoteInspectItemFromInvTile = playercontroller.RemoteInspectItemFromInvTile
    function playercontroller:RemoteInspectItemFromInvTile(item)
        CraftFinder(item.prefab)
        old_RemoteInspectItemFromInvTile(self, item)
    end

    local old_RemoteInspectButton = playercontroller.RemoteInspectButton
    function playercontroller:RemoteInspectButton(action)
        CraftFinder(action.target.prefab)
        old_RemoteInspectButton(self, action)
    end

    local old_RemoteUseItemFromInvTile = playercontroller.RemoteUseItemFromInvTile
    function playercontroller:RemoteUseItemFromInvTile(buffaction, item)
        if buffaction.action == GLOBAL.ACTIONS.LOOKAT then CraftFinder(item.prefab) end
        old_RemoteUseItemFromInvTile(self, buffaction, item)
    end

    local old_DoAction = playercontroller.DoAction
    function playercontroller:DoAction(buffaction, spellbook)
        if buffaction and buffaction.target and buffaction.action == GLOBAL.ACTIONS.LOOKAT then CraftFinder(buffaction.target.prefab) end
        old_DoAction(self, buffaction, spellbook)
    end
end)

AddClassPostConstruct("screens/playerhud", function (playerhud)
    PlayerHUD = playerhud

    if GLOBAL.TheNet:GetIsClient() or loaded then return end; loaded = true;

    local old_LOOKAT = GLOBAL.ACTIONS.LOOKAT.fn
    GLOBAL.ACTIONS.LOOKAT.fn = function(act)
        if act.target and act.target.prefab then CraftFinder(act.target.prefab) ; return old_LOOKAT(act) end
        if act.invobject and act.invobject.prefab then CraftFinder(act.invobject.prefab) ; return old_LOOKAT(act) end
        return old_LOOKAT(act)
    end
end)
