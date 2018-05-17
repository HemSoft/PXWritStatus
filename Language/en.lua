-- EN Language file, made by PhaeroX
local strings = {
  -- V1.0.0
  PXWS_SETTINGS_DISPLAY_NAME                         = "PhaeroX Writ Status",
  PXWS_SETTINGS_AUTHOR                               = "|c28b712PhaeroX|r",
  PXWS_SETTINGS_HEADER_TEXT                          = "PhaeroX Writ Status Settings:",
  PXWS_SETTINGS_SHOW_WINDOW                          = "Show Window",
  PXWS_SETTINGS_WINDOW_SETTINGS                      = "Window Settings",
  PXWS_SETTINGS_FONT_COLOR                           = "Font Color",
  PXWS_SETTINGS_FONT_COLOR_TOOLTIP                   = "Select the font color to display the writ status:",
  PXWS_SETTINGS_FONT_SCALE                           = "Font Scale",
  PXWS_SETTINGS_BACKGROUND_TRANSPARENCY              = "Background Transparency",
}

for stringId, stringValue in pairs(strings) do
  ZO_CreateStringId(stringId, stringValue)
  SafeAddVersion(stringId, 1)
end