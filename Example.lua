-- Fetch the Plague Library
local Plague = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/plague/refs/heads/main/Library.lua"))()

-- Create the Main Window
local Window = Plague:CreateWindow({
    Title = "plague showcase",
    ConfigFolder = "plague_configs"
})

-- Create a Tab
local MainTab = Window:CreateTab("elements")

-- Create a Left Section
local LeftSec = MainTab:CreateSection("basic elements", "Left")

-- 1. Label (with optional description)
LeftSec:CreateLabel("welcome to plague", "this script showcases every ui element.")

-- 2. Toggle
local exampleToggle = LeftSec:CreateToggle("example_toggle", "example toggle", false, function(state)
    print("Toggle is now:", state)
end)

-- 3. Button
LeftSec:CreateButton("example button", function()
    print("Button was clicked!")
end)

-- 4. Slider (Flag, Name, Min, Max, Default, Decimals, Callback)
LeftSec:CreateSlider("example_slider", "example slider", 0, 100, 50, 1, function(value)
    print("Slider set to:", value)
end)

-- 5. Color Picker
LeftSec:CreateColorPicker("example_color", "example color", Color3.fromRGB(155, 95, 135), function(color)
    print("Color changed to RGB:", color.R * 255, color.G * 255, color.B * 255)
end)


-- Create a Right Section
local RightSec = MainTab:CreateSection("advanced elements", "Right")

-- 6. Dropdown
RightSec:CreateDropdown("example_dropdown", "example dropdown", {"option 1", "option 2", "option 3"}, "option 1", function(selected)
    print("Dropdown selected:", selected)
end)

-- 7. Keybind
RightSec:CreateKeybind("example_keybind", "example keybind", Enum.KeyCode.F, function(key)
    print("Keybind pressed:", key.Name)
end)

-- 8. Notification Trigger (using a button)
RightSec:CreateButton("trigger notification", function()
    Plague:Notify("notification", "this is an example notification triggered by a button.", 3)
end)

-- Create a Second Tab to demonstrate tab switching
local VisualsTab = Window:CreateTab("visuals")
local EspSec = VisualsTab:CreateSection("esp settings", "Left")

EspSec:CreateToggle("esp_enabled", "enable esp", true, function(state)
    print("ESP Enabled:", state)
end)
EspSec:CreateColorPicker("esp_color", "esp color", Color3.fromRGB(255, 80, 80), function(color)
    print("ESP Color changed.")
end)

-- Note: The "settings" tab is automatically created and placed at the very end of your tabs.
