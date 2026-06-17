local function T(en, zh, zht) return ChooseTranslationTable({ en, zh = zh, zht = zht or zh }) end

name = T('What to Craft with This?', '这个能造啥？')
author = T('Sinny Deas, liolok', 'Sinny Deas、李皓奇')
local date = '2026-06-17'
version = date .. '' -- for revision in same day
description = T(
  [[
- Inspect inventory item, popup crafting menu and show all possible recipes.
- Inspecting supports both Keyboard/Mouse and Gamepad.
- If don't like inspecting, feel free to bind a key in-game to show recipes.
- Key binding is in Settings->Controls page, scroll down to find it.
]],
  [[
- 检查格子里的物品，弹出制作目录并展示所有可能的配方。
- 检查支持键鼠以及手柄。
- 如果不喜欢检查，也可以在游戏内绑定一个按键来展示配方。
- 按键绑定在设置->控制页面，往下翻就能找到。
]]
) .. '󰀰 ' .. date -- Florid Postern（绚丽之门）
api_version = 10
dst_compatible = true
client_only_mod = true
icon = 'modicon.tex'
icon_atlas = 'modicon.xml'

local keyboard = { -- from STRINGS.UI.CONTROLSSCREEN.INPUTS[1] of strings.lua, need to match constants.lua too.
  { 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Print', 'ScrolLock', 'Pause' },
  { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' },
  { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M' },
  { 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' },
  { 'Escape', 'Tab', 'CapsLock', 'LShift', 'LCtrl', 'LSuper', 'LAlt' },
  { 'Space', 'RAlt', 'RSuper', 'RCtrl', 'RShift', 'Enter', 'Backspace' },
  { 'BackQuote', 'Minus', 'Equals', 'LeftBracket', 'RightBracket' },
  { 'Backslash', 'Semicolon', 'Quote', 'Period', 'Slash' }, -- punctuation
  { 'Up', 'Down', 'Left', 'Right', 'Insert', 'Delete', 'Home', 'End', 'PageUp', 'PageDown' }, -- navigation
}
local numpad = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'Period', 'Divide', 'Multiply', 'Minus', 'Plus' }
local mouse = { '\238\132\130', '\238\132\131', '\238\132\132' } -- Middle Mouse Button, Mouse Button 4 and 5
local key_disabled = { description = 'Disabled', data = 'KEY_DISABLED' }
keys = { key_disabled }
for i = 1, #mouse do
  keys[#keys + 1] = { description = mouse[i], data = mouse[i] }
end
for i = 1, #keyboard do
  for j = 1, #keyboard[i] do
    local key = keyboard[i][j]
    keys[#keys + 1] = { description = key, data = 'KEY_' .. key:upper() }
  end
  keys[#keys + 1] = key_disabled
end
for i = 1, #numpad do
  local key = numpad[i]
  keys[#keys + 1] = { description = 'Numpad ' .. key, data = 'KEY_KP_' .. key:upper() }
end

configuration_options = {
  {
    name = 'key_to_show_recipes',
    label = T('Show Recipes', '展示配方'),
    hover = T(
      'Without key binding, Inspect/Examine item to show recipes.',
      '未绑定按键时，检查/查看物品来展示配方。'
    ),
    options = keys,
    default = 'KEY_DISABLED',
  },
}
