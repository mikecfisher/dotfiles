-- Kanata Layer Overlay for Hammerspoon
-- Connects to kanata TCP server and displays visual overlay when layer changes

local M = {}

-- Layer mappings extracted from kanata config
local layerMappings = {
  leader = {
    { key = "a", action = "Apps" },
    { key = "b", action = "Browser" },
    { key = "i", action = "Intelligence" },
    { key = "k", action = "Kanata" },
    { key = "n", action = "Clear Notifications" },
    { key = "r", action = "Raycast" },
    { key = "s", action = "System" },
    { key = "w", action = "Windows" },
    { key = "esc", action = "Exit" },
  },
  apps = {
    { key = "1", action = "1Password" },
    { key = "a", action = "Akiflow" },
    { key = "b", action = "Atlas" },
    { key = "c", action = "Zed" },
    { key = "d", action = "Discord" },
    { key = "e", action = "Superhuman" },
    { key = "f", action = "Finder" },
    { key = "g", action = "Chrome" },
    { key = "i", action = "ChatGPT" },
    { key = "m", action = "Messaging" },
    { key = "n", action = "Notion" },
    { key = "o", action = "Simulator" },
    { key = "p", action = "Perplexity" },
    { key = "r", action = "Reflect" },
    { key = "s", action = "Slack" },
    { key = "t", action = "cmux" },
    { key = "v", action = "VS Code" },
    { key = "w", action = "Teams" },
    { key = "x", action = "Lexicon" },
    { key = "y", action = "Figma" },
    { key = "z", action = "Cursor" },
  },
  messaging = {
    { key = "m", action = "Messages" },
    { key = "w", action = "WhatsApp" },
    { key = "b", action = "Beeper" },
  },
  intelligence = {
    { key = "c", action = "Claude" },
    { key = "g", action = "ChatGPT" },
  },
  windows = {
    { key = "h", action = "Left" },
    { key = "j", action = "Bottom" },
    { key = "k", action = "Top" },
    { key = "l", action = "Right" },
    { key = "c", action = "Center ⅓" },
    { key = "f", action = "Maximize" },
    { key = "[", action = "Prev Display" },
    { key = "]", action = "Next Display" },
    { key = "-", action = "Prev Desktop" },
    { key = "=", action = "Next Desktop" },
  },
  browser = {
    { key = "c", action = "ChatGPT" },
    { key = "g", action = "GitHub" },
    { key = "h", action = "Hacker News" },
    { key = "l", action = "LinkedIn" },
    { key = "p", action = "Perplexity" },
    { key = "r", action = "Reddit" },
    { key = "t", action = "Twitter" },
    { key = "y", action = "YouTube" },
  },
  raycast = {
    { key = "c", action = "Camera" },
    { key = "e", action = "Emoji" },
    { key = "g", action = "Google" },
    { key = "h", action = "Clipboard" },
    { key = "i", action = "AI Chat" },
    { key = "n", action = "Notifications" },
    { key = "p", action = "Confetti" },
  },
  system = {
    { key = "d", action = "Do Not Disturb" },
    { key = "l", action = "Lock Screen" },
    { key = "e", action = "Emoji Picker" },
  },
  ["kanata-cmds"] = {
    { key = "r", action = "Reload Config" },
  },
  lexicon = {
    { key = "⌘h", action = "← Left" },
    { key = "⌘j", action = "↓ Down" },
    { key = "⌘k", action = "↑ Up" },
    { key = "⌘l", action = "→ Right" },
  },
}

-- Configuration
local config = {
  host = "127.0.0.1",
  port = 5829,
  reconnectDelay = 3,

  -- Layout
  padding = 24,
  itemSpacing = 8,
  columnGap = 16,
  rowHeight = 32,
  keyBadgeWidth = 36,
  keyBadgeHeight = 26,
  itemWidth = 140,
  cornerRadius = 16,
  keyBadgeRadius = 6,

  -- Typography
  headerFontSize = 13,
  keyFontSize = 13,
  actionFontSize = 13,
  fontName = "SF Pro Text",
  monoFontName = "SF Mono",

  -- Colors
  bgColor = { red = 0.1, green = 0.1, blue = 0.12, alpha = 0.88 },
  borderColor = { white = 0.3, alpha = 0.3 },
  headerColor = { red = 0.55, green = 0.75, blue = 1.0, alpha = 1 },
  keyBadgeBg = { red = 0.35, green = 0.78, blue = 0.75, alpha = 1 },  -- Soft teal
  keyTextColor = { red = 0.05, green = 0.15, blue = 0.15, alpha = 1 },
  actionColor = { white = 0.92, alpha = 1 },
  mutedColor = { white = 0.5, alpha = 1 },

  -- Animation
  fadeInDuration = 0.12,
  fadeOutDuration = 0.08,

  -- Grid threshold - use grid for layers with more than this many items
  gridThreshold = 8,
  maxColumns = 3,
}

-- State
local client = nil
local overlay = nil
local reconnectTimer = nil
local buffer = ""
local fadeTimer = nil

-- Helper: Calculate grid dimensions
local function calculateGridLayout(numItems)
  if numItems <= config.gridThreshold then
    return 1, numItems  -- Single column
  end

  local cols = math.min(config.maxColumns, math.ceil(numItems / 7))
  local rows = math.ceil(numItems / cols)
  return cols, rows
end

-- Create the overlay canvas
local function createOverlay(layerName, mappings)
  if fadeTimer then
    fadeTimer:stop()
    fadeTimer = nil
  end

  if overlay then
    overlay:delete()
    overlay = nil
  end

  local numItems = #mappings
  local cols, rows = calculateGridLayout(numItems)

  -- Calculate dimensions
  local contentWidth = cols * config.itemWidth + (cols - 1) * config.columnGap
  local contentHeight = rows * config.rowHeight + (rows - 1) * config.itemSpacing
  local headerHeight = 44

  local width = contentWidth + config.padding * 2
  local height = headerHeight + contentHeight + config.padding * 2

  -- Get screen and position overlay at center
  local screen = hs.screen.mainScreen():frame()
  local x = screen.x + (screen.w - width) / 2
  local y = screen.y + (screen.h - height) / 2

  overlay = hs.canvas.new({ x = x, y = y, w = width, h = height })
  overlay:alpha(0)

  -- Background
  overlay:insertElement({
    type = "rectangle",
    fillColor = config.bgColor,
    strokeColor = config.borderColor,
    strokeWidth = 0.5,
    roundedRectRadii = { xRadius = config.cornerRadius, yRadius = config.cornerRadius },
    frame = { x = 0, y = 0, w = width, h = height },
  })

  -- Header text
  local headerText = hs.styledtext.new(layerName:upper(), {
    font = { name = config.fontName, size = config.headerFontSize },
    color = config.headerColor,
    paragraphStyle = { alignment = "center" },
    kerning = 2.0,
  })

  overlay:insertElement({
    type = "text",
    text = headerText,
    frame = { x = config.padding, y = config.padding, w = contentWidth, h = 20 },
  })

  -- Key mappings in grid
  local startY = headerHeight + config.padding - 8

  for i, mapping in ipairs(mappings) do
    local col = (i - 1) % cols
    local row = math.floor((i - 1) / cols)

    local itemX = config.padding + col * (config.itemWidth + config.columnGap)
    local itemY = startY + row * (config.rowHeight + config.itemSpacing)

    -- Key badge background
    overlay:insertElement({
      type = "rectangle",
      fillColor = config.keyBadgeBg,
      roundedRectRadii = { xRadius = config.keyBadgeRadius, yRadius = config.keyBadgeRadius },
      frame = {
        x = itemX,
        y = itemY + (config.rowHeight - config.keyBadgeHeight) / 2,
        w = config.keyBadgeWidth,
        h = config.keyBadgeHeight
      },
    })

    -- Key text (centered in badge)
    local keyText = hs.styledtext.new(mapping.key, {
      font = { name = config.monoFontName, size = config.keyFontSize },
      color = config.keyTextColor,
      paragraphStyle = { alignment = "center" },
    })

    overlay:insertElement({
      type = "text",
      text = keyText,
      frame = {
        x = itemX,
        y = itemY + (config.rowHeight - config.keyFontSize) / 2 - 1,
        w = config.keyBadgeWidth,
        h = config.keyBadgeHeight
      },
    })

    -- Action text
    local actionText = hs.styledtext.new(mapping.action, {
      font = { name = config.fontName, size = config.actionFontSize },
      color = config.actionColor,
    })

    overlay:insertElement({
      type = "text",
      text = actionText,
      frame = {
        x = itemX + config.keyBadgeWidth + 10,
        y = itemY + (config.rowHeight - config.actionFontSize) / 2,
        w = config.itemWidth - config.keyBadgeWidth - 12,
        h = config.rowHeight
      },
    })
  end

  overlay:level(hs.canvas.windowLevels.overlay)
  overlay:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
  overlay:show()

  -- Fade in animation
  local startTime = hs.timer.secondsSinceEpoch()
  fadeTimer = hs.timer.doEvery(0.016, function()
    local elapsed = hs.timer.secondsSinceEpoch() - startTime
    local progress = math.min(elapsed / config.fadeInDuration, 1)
    if overlay then
      overlay:alpha(progress)
    end
    if progress >= 1 and fadeTimer then
      fadeTimer:stop()
      fadeTimer = nil
    end
  end)
end

-- Hide the overlay with fade out
local function hideOverlay()
  if fadeTimer then
    fadeTimer:stop()
    fadeTimer = nil
  end

  if not overlay then return end

  local startAlpha = overlay:alpha()
  local startTime = hs.timer.secondsSinceEpoch()

  fadeTimer = hs.timer.doEvery(0.016, function()
    local elapsed = hs.timer.secondsSinceEpoch() - startTime
    local progress = math.min(elapsed / config.fadeOutDuration, 1)

    if overlay then
      overlay:alpha(startAlpha * (1 - progress))
    end

    if progress >= 1 then
      if fadeTimer then
        fadeTimer:stop()
        fadeTimer = nil
      end
      if overlay then
        overlay:delete()
        overlay = nil
      end
    end
  end)
end

-- Layers that should never show an overlay (app-specific layers)
local silentLayers = {
  base = true,
  lexicon = true,
}

-- Handle layer change event
local function onLayerChange(layerName)
  if silentLayers[layerName] then
    hideOverlay()
    return
  end

  local mappings = layerMappings[layerName]
  if mappings then
    createOverlay(layerName, mappings)
  else
    hideOverlay()
  end
end

-- Process received data
local function processData(data)
  buffer = buffer .. data

  -- Process complete lines
  while true do
    local newlinePos = buffer:find("\n")
    if not newlinePos then break end

    local line = buffer:sub(1, newlinePos - 1)
    buffer = buffer:sub(newlinePos + 1)

    if line and line ~= "" then
      local success, decoded = pcall(hs.json.decode, line)
      if success and decoded and decoded.LayerChange then
        onLayerChange(decoded.LayerChange.new)
      end
    end
  end
end

-- TCP callback
local function tcpCallback(data, tag)
  if data then
    processData(data)
    -- Continue reading
    if client then
      client:read("\n")
    end
  end
end

-- Connect to kanata
local function connect()
  if client then
    client:disconnect()
    client = nil
  end

  client = hs.socket.new(function(data, tag)
    if data == nil then
      -- Connection lost
      hs.alert.show("Kanata disconnected")
      hideOverlay()
      client = nil
      -- Schedule reconnect
      if reconnectTimer then
        reconnectTimer:stop()
      end
      reconnectTimer = hs.timer.doAfter(config.reconnectDelay, connect)
    else
      tcpCallback(data, tag)
    end
  end)

  local success = client:connect(config.host, config.port, function()
    hs.alert.show("Connected to Kanata")
    buffer = ""
    client:read("\n")
  end)

  if not success then
    hs.alert.show("Kanata not running")
    client = nil
    -- Schedule reconnect
    if reconnectTimer then
      reconnectTimer:stop()
    end
    reconnectTimer = hs.timer.doAfter(config.reconnectDelay, connect)
  end
end

-- Disconnect from kanata
local function disconnect()
  if reconnectTimer then
    reconnectTimer:stop()
    reconnectTimer = nil
  end
  if client then
    client:disconnect()
    client = nil
  end
  hideOverlay()
end

-- Manual toggle overlay (for testing)
local function toggleOverlay(layerName)
  if overlay then
    hideOverlay()
  else
    onLayerChange(layerName or "leader")
  end
end

-- Send layer change command to kanata
local function sendLayerChange(layerName)
  if client and client:connected() then
    local cmd = '{"ChangeLayer":{"new":"' .. layerName .. '"}}\n'
    client:write(cmd)
  end
end

-- App-specific layer switching
local appLayers = {
  ["Lexicon"] = "lexicon",
  ["Lexicon-Beta"] = "lexicon",
  -- Add more apps here as needed
}

local appWatcher = hs.application.watcher.new(function(name, event, app)
  if event == hs.application.watcher.activated then
    local targetLayer = appLayers[name]
    if targetLayer then
      sendLayerChange(targetLayer)
    else
      sendLayerChange("base")
    end
  end
end)

appWatcher:start()

-- Expose functions
M.connect = connect
M.disconnect = disconnect
M.toggleOverlay = toggleOverlay
M.hideOverlay = hideOverlay
M.sendLayerChange = sendLayerChange

-- URL handler for hiding overlay (used by Kanata reload command)
hs.urlevent.bind("hideKanataOverlay", function()
  hideOverlay()
end)

-- USB watcher: restart kanata when a new keyboard is plugged in
-- Uses launchctl bootout/bootstrap for a clean restart with enough delay
-- for the old process to fully release device handles
local usbRestartInProgress = false
local usbWatcher = hs.usb.watcher.new(function(event)
  if event.eventType == "added" and not usbRestartInProgress then
    usbRestartInProgress = true
    -- Delay to let the device fully initialize
    hs.timer.doAfter(1, function()
      hs.alert.show("Keyboard connected — restarting Kanata")
      disconnect()
      -- Full service restart: stop, wait for device release, start
      hs.execute("launchctl bootout system/com.kanata", true)
      hs.timer.doAfter(3, function()
        hs.execute("launchctl bootstrap system /Library/LaunchDaemons/com.kanata.plist", true)
        hs.timer.doAfter(2, function()
          connect()
          usbRestartInProgress = false
        end)
      end)
    end)
  end
end)
usbWatcher:start()

-- Auto-connect on load
connect()

return M
