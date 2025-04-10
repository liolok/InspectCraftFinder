local function T(en, zh, zht) return ChooseTranslationTable({ en, zh = zh, zht = zht or zh }) end

name = T('Inspect Craft Finder', '检查材料展示制作配方')
author = T('Sinny Deas, liolok', 'Sinny Deas、李皓奇')
local date = '2025-04-06'
version = date .. '' -- for revision in same day
description = T(
  [[
- Show possible crafting recipes, in the crafting menu, when inspecting something.
- Item can be on the ground or in the inventory.
- Both Keyboard/Mouse and Gamepad and supported.
]],
  [[
- 检查物品时弹出制作目录并展示所有以它为材料的制作配方
- 物品可以在地上或者格子里
- 支持键鼠以及手柄
]]
) .. '󰀰 ' .. date -- Florid Postern（绚丽之门）
api_version = 10
dst_compatible = true
client_only_mod = true
icon_atlas = 'icon.xml'
icon = 'icon.tex'
configuration_options = {
  {
    name = 'auto_open_craft_menu',
    label = T('Auto Open Craft Menu', '自动打开制作目录'),
    options = {
      { data = true, description = T('Enabled', '启用') },
      { data = false, description = T('Disabled', '禁用') },
    },
    default = true,
  },
  {
    name = 'enable_inspect_on_ground',
    label = T('Items on the Ground', '地面物品'),
    hover = T('Show recipes when inspecting items on the ground.', '检查地面物品时展示配方'),
    options = {
      { data = true, description = T('Enabled', '启用') },
      { data = false, description = T('Disabled', '禁用') },
    },
    default = true,
  },
}
