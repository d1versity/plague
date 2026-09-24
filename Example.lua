local Plague = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/plague/refs/heads/main/Library.lua"))()

local Window = Plague:CreateWindow({
    Title = "Plague",
    ConfigFolder = "PlagueConfigs"
})

local MainTab = Window:CreateTab("Combat")

local AimbotSec = MainTab:CreateSection("Aimbot Logic", "Left")
AimbotSec:CreateLabel("Aimbot Status", "Adjust your targeting features.")

local aimToggle = AimbotSec:CreateToggle("AimEnabled", "Enable Aimbot", false, function(state)
    print("Aimbot is now:", state)
end)

AimbotSec:CreateDropdown("AimPart", "Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(val)
    print("Aiming at:", val)
end)

local AdjustSec = MainTab:CreateSection("Adjustments", "Right")

AdjustSec:CreateSlider("AimSmooth", "Smoothness", 0, 10, 5, 2, function(val)
    print("Smoothness set to:", val)
end)

AdjustSec:CreateToggle("SilentAim", "Silent Aim", false)

local VisualsTab = Window:CreateTab("Visuals")

local ESPSec = VisualsTab:CreateSection("ESP Components", "Left")
ESPSec:CreateToggle("EspBoxes", "Show Boxes", true)
ESPSec:CreateToggle("EspNames", "Show Names", false)

local MiscSec = VisualsTab:CreateSection("Miscellaneous", "Right")
MiscSec:CreateButton("Test Notification", function()
    Plague:Notify("Notification", "The custom UI system is fully operational.", 3)
end)

MiscSec:CreateButton("Force Turn On Aimbot", function()
    aimToggle:Set(true)
    Plague:Notify("Updated", "Forced Aimbot Toggle to ON.", 3)
end)
