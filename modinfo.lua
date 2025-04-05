local function T(en, zh, zht) return ChooseTranslationTable({ en, zh = zh, zht = zht or zh }) end

name = T('Inspect Craft Finder', '检查材料查找制作配方')
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
- 检查物品时弹出制作菜单并显示所有以它为材料的制作配方
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
