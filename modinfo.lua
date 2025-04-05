local function T(en, zh, zht) return ChooseTranslationTable({ en, zh = zh, zht = zht or zh }) end

name = T('Inspect Craft Finder', '检查材料展示制作配方')
author = T('Sinny Deas, liolok', 'Sinny Deas、李皓奇')
version = '2025.04.06'
description = T(
  [[
- Show possible crafting recipes, in the crafting menu, when inspecting something.
- Item can be on the ground or in the inventory.
- Both Keyboard/Mouse and Gamepad and supported.
Last updated at:
]],
  [[
- 检查物品时弹出制作菜单并展示所有以它为材料的制作配方
- 物品可以在地上或者格子里
- 支持键鼠以及手柄
最后更新于：
]]
) .. version
api_version = 10
dst_compatible = true
client_only_mod = true
icon_atlas = 'icon.xml'
icon = 'icon.tex'
configuration_options = {
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
