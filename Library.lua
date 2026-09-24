-- plague by Vhyse | v1

local Plague = {
    Flags = {},
    Connections = {},
    Toggled = true,
    ToggleKey = Enum.KeyCode.Insert,
    IsBinding = false
}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

if getgenv().Plague_Instance then
    getgenv().Plague_Instance:Destroy()
end
if getgenv().Plague_Connections then
    for _, conn in pairs(getgenv().Plague_Connections) do
        conn:Disconnect()
    end
end
getgenv().Plague_Connections = Plague.Connections

local Theme = {
    Background = Color3.fromRGB(16, 16, 18),
    Topbar = Color3.fromRGB(18, 18, 20),
    Section = Color3.fromRGB(20, 20, 23),
    Element = Color3.fromRGB(24, 24, 27),
    Accent = Color3.fromRGB(155, 95, 135),
    Text = Color3.fromRGB(160, 160, 170),
    SubText = Color3.fromRGB(130, 130, 140),
    Border = Color3.fromRGB(35, 35, 40),
    Font = Enum.Font.GothamMedium -- Thicker, more readable font
}

local fastTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function Tween(instance, properties)
    local tween = TweenService:Create(instance, fastTween, properties)
    tween:Play()
    return tween
end

function Plague:CreateWindow(config)
    local titleText = config.Title or "Plague"
    local configFolder = config.ConfigFolder or "PlagueConfigs"
    
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PlagueUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    local success, _ = pcall(function() ScreenGui.Parent = gethui() end)
    if not success then ScreenGui.Parent = CoreGui end
    getgenv().Plague_Instance = ScreenGui

    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "NotifContainer"
    NotifContainer.Size = UDim2.new(0, 300, 1, -20)
    NotifContainer.Position = UDim2.new(1, -320, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.BorderSizePixel = 0
    NotifContainer.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.Padding = UDim.new(0, 10)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Parent = NotifContainer

    local MainGroup = Instance.new("CanvasGroup")
    MainGroup.Name = "Main"
    MainGroup.Size = UDim2.new(0, 450, 0, 450)
    MainGroup.Position = UDim2.new(0.5, -225, 0.5, -225)
    MainGroup.BackgroundColor3 = Theme.Background
    MainGroup.BorderSizePixel = 0
    MainGroup.GroupTransparency = 1
    MainGroup.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainGroup

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Transparency = 1
    MainStroke.Parent = MainGroup

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 26)
    TitleBar.BackgroundColor3 = Theme.Topbar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainGroup

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.Font = Theme.Font
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Parent = TitleBar

    local TitleLine = Instance.new("Frame")
    TitleLine.Size = UDim2.new(1, 0, 0, 1)
    TitleLine.Position = UDim2.new(0, 0, 1, -1)
    TitleLine.BackgroundColor3 = Theme.Border
    TitleLine.BorderSizePixel = 0
    TitleLine.Parent = TitleBar

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 34)
    TabBar.Position = UDim2.new(0, 0, 0, 26)
    TabBar.BackgroundColor3 = Theme.Topbar
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainGroup

    local TabLine = Instance.new("Frame")
    TabLine.Size = UDim2.new(1, 0, 0, 1)
    TabLine.Position = UDim2.new(0, 0, 1, -1)
    TabLine.BackgroundColor3 = Theme.Border
    TabLine.BorderSizePixel = 0
    TabLine.Parent = TabBar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -10, 1, -1)
    TabContainer.Position = UDim2.new(0, 5, 0, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.ScrollingDirection = Enum.ScrollingDirection.X
    TabContainer.Parent = TabBar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Parent = TabContainer

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X, 0, 0)
    end)

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, 0, 1, -60)
    ContentArea.Position = UDim2.new(0, 0, 0, 60)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainGroup

    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainGroup.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    table.insert(Plague.Connections, RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainGroup.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    -- UI Toggle Listener (Ignores input if currently binding a key)
    table.insert(Plague.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or Plague.IsBinding then return end
        
        if input.KeyCode == Plague.ToggleKey then
            Plague.Toggled = not Plague.Toggled
            
            if Plague.Toggled then
                MainGroup.Visible = true
                Tween(MainGroup, {GroupTransparency = 0})
                Tween(MainStroke, {Transparency = 0})
            else
                local fadeOut = Tween(MainGroup, {GroupTransparency = 1})
                Tween(MainStroke, {Transparency = 1})
                
                task.spawn(function()
                    fadeOut.Completed:Wait()
                    if not Plague.Toggled then
                        MainGroup.Visible = false
                    end
                end)
            end
        end
    end))

    Tween(MainGroup, {GroupTransparency = 0})
    Tween(MainStroke, {Transparency = 0})

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
        CurrentTabBtn = nil
    }

    function Plague:Notify(title, desc, duration)
        duration = duration or 3
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, 60)
        notif.BackgroundColor3 = Theme.Section
        notif.BackgroundTransparency = 1
        notif.BorderSizePixel = 0
        notif.Parent = NotifContainer

        local nCorner = Instance.new("UICorner")
        nCorner.CornerRadius = UDim.new(0, 5)
        nCorner.Parent = notif

        local nStroke = Instance.new("UIStroke")
        nStroke.Color = Theme.Border
        nStroke.Transparency = 1
        nStroke.Parent = notif

        local nTitle = Instance.new("TextLabel")
        nTitle.Size = UDim2.new(1, -20, 0, 20)
        nTitle.Position = UDim2.new(0, 10, 0, 8)
        nTitle.BackgroundTransparency = 1
        nTitle.BorderSizePixel = 0
        nTitle.Text = title
        nTitle.TextColor3 = Theme.Accent
        nTitle.TextTransparency = 1
        nTitle.Font = Theme.Font
        nTitle.TextSize = 13
        nTitle.TextXAlignment = Enum.TextXAlignment.Left
        nTitle.Parent = notif

        local nDesc = Instance.new("TextLabel")
        nDesc.Size = UDim2.new(1, -20, 0, 18)
        nDesc.Position = UDim2.new(0, 10, 0, 30)
        nDesc.BackgroundTransparency = 1
        nDesc.BorderSizePixel = 0
        nDesc.Text = desc
        nDesc.TextColor3 = Theme.SubText
        nDesc.TextTransparency = 1
        nDesc.Font = Theme.Font
        nDesc.TextSize = 12
        nDesc.TextXAlignment = Enum.TextXAlignment.Left
        nDesc.Parent = notif

        Tween(notif, {BackgroundTransparency = 0})
        Tween(nStroke, {Transparency = 0})
        Tween(nTitle, {TextTransparency = 0})
        Tween(nDesc, {TextTransparency = 0})

        task.delay(duration, function()
            Tween(notif, {BackgroundTransparency = 1})
            Tween(nStroke, {Transparency = 1})
            Tween(nTitle, {TextTransparency = 1})
            Tween(nDesc, {TextTransparency = 1})
            task.wait(0.2)
            notif:Destroy()
        end)
    end

    function WindowObj:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 60, 1, 0)
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.SubText
        TabBtn.Font = Theme.Font
        TabBtn.TextSize = 13
        TabBtn.Selectable = false
        TabBtn.LayoutOrder = (name == "settings") and 9999 or 0 -- Forces settings tab to always be last
        TabBtn.Parent = TabContainer

        local TabPad = Instance.new("UIPadding", TabBtn)
        TabPad.PaddingLeft = UDim.new(0, 10)
        TabPad.PaddingRight = UDim.new(0, 10)

        local TabCanvas = Instance.new("CanvasGroup")
        TabCanvas.Size = UDim2.new(1, 0, 1, 0)
        TabCanvas.BackgroundTransparency = 1
        TabCanvas.BorderSizePixel = 0
        TabCanvas.GroupTransparency = 1
        TabCanvas.Visible = false
        TabCanvas.Parent = ContentArea

        local ScrollContent = Instance.new("ScrollingFrame")
        ScrollContent.Size = UDim2.new(1, 0, 1, 0)
        ScrollContent.BackgroundTransparency = 1
        ScrollContent.BorderSizePixel = 0
        ScrollContent.ScrollBarThickness = 2
        ScrollContent.ScrollBarImageColor3 = Theme.Accent
        ScrollContent.Parent = TabCanvas

        local ScrollPadding = Instance.new("UIPadding", ScrollContent)
        ScrollPadding.PaddingTop = UDim.new(0, 12)
        ScrollPadding.PaddingBottom = UDim.new(0, 12)
        ScrollPadding.PaddingLeft = UDim.new(0, 12)
        ScrollPadding.PaddingRight = UDim.new(0, 12)

        local LeftColumn = Instance.new("Frame")
        LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
        LeftColumn.Position = UDim2.new(0, 0, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.BorderSizePixel = 0
        LeftColumn.Parent = ScrollContent

        local RightColumn = Instance.new("Frame")
        RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.BorderSizePixel = 0
        RightColumn.Parent = ScrollContent

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 12)
        LeftLayout.Parent = LeftColumn

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 12)
        RightLayout.Parent = RightColumn

        local function updateCanvas()
            local maxH = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
            ScrollContent.CanvasSize = UDim2.new(0, 0, 0, maxH + 24)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

        if not self.CurrentTab then
            self.CurrentTab = TabCanvas
            self.CurrentTabBtn = TabBtn
            TabCanvas.Visible = true
            TabCanvas.GroupTransparency = 0
            TabBtn.TextColor3 = Theme.Accent
        end

        TabBtn.MouseButton1Click:Connect(function()
            if WindowObj.CurrentTab == TabCanvas then return end

            if WindowObj.CurrentTabBtn then
                Tween(WindowObj.CurrentTabBtn, {TextColor3 = Theme.SubText})
            end
            Tween(TabBtn, {TextColor3 = Theme.Accent})
            WindowObj.CurrentTabBtn = TabBtn

            if WindowObj.CurrentTab then
                local oldTab = WindowObj.CurrentTab
                local fadeOut = Tween(oldTab, {GroupTransparency = 1})
                
                task.spawn(function()
                    fadeOut.Completed:Wait()
                    if WindowObj.CurrentTab ~= oldTab then
                        oldTab.Visible = false
                    end
                end)
            end

            WindowObj.CurrentTab = TabCanvas
            TabCanvas.Visible = true
            Tween(TabCanvas, {GroupTransparency = 0})
        end)

        local TabObj = {}
        
        function TabObj:CreateSection(secName, side)
            side = side or "Left"
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.BackgroundColor3 = Theme.Section
            Section.BorderSizePixel = 0
            Section.Parent = side == "Right" and RightColumn or LeftColumn

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 5)
            SecCorner.Parent = Section
            
            local SecStroke = Instance.new("UIStroke")
            SecStroke.Color = Theme.Border
            SecStroke.Parent = Section

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Size = UDim2.new(1, -20, 0, 28)
            SecTitle.Position = UDim2.new(0, 10, 0, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.BorderSizePixel = 0
            SecTitle.Text = secName
            SecTitle.TextColor3 = Theme.Accent
            SecTitle.Font = Theme.Font
            SecTitle.TextSize = 13
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Parent = Section

            local SecContainer = Instance.new("Frame")
            SecContainer.Size = UDim2.new(1, 0, 1, -28)
            SecContainer.Position = UDim2.new(0, 0, 0, 28)
            SecContainer.BackgroundTransparency = 1
            SecContainer.BorderSizePixel = 0
            SecContainer.Parent = Section
            
            local SecPadding = Instance.new("UIPadding", SecContainer)
            SecPadding.PaddingLeft = UDim.new(0, 10)
            SecPadding.PaddingRight = UDim.new(0, 10)
            SecPadding.PaddingBottom = UDim.new(0, 10)

            local SecLayout = Instance.new("UIListLayout")
            SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecLayout.Padding = UDim.new(0, 8)
            SecLayout.Parent = SecContainer

            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, 0, 0, SecLayout.AbsoluteContentSize.Y + 38)
            end)

            local Elements = {}

            function Elements:CreateToggle(flag, name, default, callback)
                local state = default or false
                Plague.Flags[flag] = state

                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Text = ""
                ToggleFrame.AutoButtonColor = false
                ToggleFrame.Selectable = false
                ToggleFrame.Parent = SecContainer

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -30, 1, 0)
                Title.Position = UDim2.new(0, 0, 0, 0)
                Title.BackgroundTransparency = 1
                Title.BorderSizePixel = 0
                Title.Text = name
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 12
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = ToggleFrame

                local OuterBox = Instance.new("Frame")
                OuterBox.Size = UDim2.new(0, 16, 0, 16)
                OuterBox.Position = UDim2.new(1, -16, 0.5, -8)
                OuterBox.BackgroundColor3 = Theme.Element
                OuterBox.BorderSizePixel = 0
                OuterBox.Parent = ToggleFrame
                Instance.new("UICorner", OuterBox).CornerRadius = UDim.new(0, 4)
                
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Theme.Border
                BoxStroke.Parent = OuterBox

                local InnerBox = Instance.new("Frame")
                InnerBox.Size = state and UDim2.new(1, -4, 1, -4) or UDim2.new(0, 0, 0, 0)
                InnerBox.Position = UDim2.new(0.5, 0, 0.5, 0)
                InnerBox.AnchorPoint = Vector2.new(0.5, 0.5)
                InnerBox.BackgroundColor3 = Theme.Accent
                InnerBox.BackgroundTransparency = state and 0 or 1
                InnerBox.BorderSizePixel = 0
                InnerBox.Parent = OuterBox
                Instance.new("UICorner", InnerBox).CornerRadius = UDim.new(0, 2)

                local function trigger(forceState)
                    if forceState ~= nil then state = forceState else state = not state end
                    Plague.Flags[flag] = state
                    Tween(InnerBox, {
                        Size = state and UDim2.new(1, -4, 1, -4) or UDim2.new(0,0,0,0),
                        BackgroundTransparency = state and 0 or 1
                    })
                    Tween(BoxStroke, {Color = state and Theme.Accent or Theme.Border})
                    if callback then task.spawn(callback, state) end
                end

                ToggleFrame.MouseButton1Click:Connect(function() trigger() end)
                if state then trigger(true) end

                return { Set = function(self, val) trigger(val) end }
            end

            function Elements:CreateButton(name, callback)
                local BtnWrapper = Instance.new("Frame")
                BtnWrapper.Size = UDim2.new(1, 0, 0, 32)
                BtnWrapper.BackgroundTransparency = 1
                BtnWrapper.BorderSizePixel = 0
                BtnWrapper.Parent = SecContainer

                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
                ButtonFrame.Position = UDim2.new(0, 0, 0.5, -14)
                ButtonFrame.BackgroundColor3 = Theme.Element
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Text = name
                ButtonFrame.TextColor3 = Theme.Accent
                ButtonFrame.Font = Theme.Font
                ButtonFrame.TextSize = 13
                ButtonFrame.AutoButtonColor = false
                ButtonFrame.Selectable = false
                ButtonFrame.Parent = BtnWrapper

                Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 4)
                local btnStroke = Instance.new("UIStroke", ButtonFrame)
                btnStroke.Color = Theme.Border

                ButtonFrame.MouseButton1Down:Connect(function()
                    Tween(btnStroke, {Color = Theme.Accent})
                end)
                ButtonFrame.MouseButton1Up:Connect(function()
                    Tween(btnStroke, {Color = Theme.Border})
                    if callback then task.spawn(callback) end
                end)
                
                return { Set = function(self, newText) ButtonFrame.Text = newText end }
            end

            function Elements:CreateSlider(flag, name, min, max, default, decimals, callback)
                local value = default or min
                Plague.Flags[flag] = value

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 40)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = SecContainer

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -50, 0, 18)
                Title.Position = UDim2.new(0, 0, 0, 2)
                Title.BackgroundTransparency = 1
                Title.BorderSizePixel = 0
                Title.Text = name
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 12
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = SliderFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0, 50, 0, 18)
                ValLabel.Position = UDim2.new(1, -50, 0, 2)
                ValLabel.BackgroundTransparency = 1
                ValLabel.BorderSizePixel = 0
                ValLabel.Text = string.format("%."..decimals.."f", value)
                ValLabel.TextColor3 = Theme.Accent
                ValLabel.Font = Theme.Font
                ValLabel.TextSize = 12
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = SliderFrame

                local SlideArea = Instance.new("TextButton")
                SlideArea.Size = UDim2.new(1, 0, 0, 6)
                SlideArea.Position = UDim2.new(0, 0, 1, -10)
                SlideArea.BackgroundColor3 = Theme.Element
                SlideArea.BorderSizePixel = 0
                SlideArea.Text = ""
                SlideArea.AutoButtonColor = false
                SlideArea.Selectable = false
                SlideArea.Parent = SliderFrame
                Instance.new("UICorner", SlideArea).CornerRadius = UDim.new(1, 0)
                Instance.new("UIStroke", SlideArea).Color = Theme.Border

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = SlideArea
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                local dragging = false
                local function updateSlide(input)
                    local percent = math.clamp((input.Position.X - SlideArea.AbsolutePosition.X) / SlideArea.AbsoluteSize.X, 0, 1)
                    local rawVal = min + (max - min) * percent
                    local mult = 10^decimals
                    value = math.floor(rawVal * mult + 0.5) / mult
                    
                    Plague.Flags[flag] = value
                    ValLabel.Text = string.format("%."..decimals.."f", value)
                    Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)})
                    if callback then task.spawn(callback, value) end
                end

                SlideArea.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlide(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlide(input)
                    end
                end)

                if callback then task.spawn(callback, value) end

                return {
                    Set = function(self, val)
                        value = math.clamp(val, min, max)
                        Plague.Flags[flag] = value
                        ValLabel.Text = string.format("%."..decimals.."f", value)
                        Tween(Fill, {Size = UDim2.new((value - min)/(max - min), 0, 1, 0)})
                        if callback then task.spawn(callback, value) end
                    end
                }
            end

            function Elements:CreateDropdown(flag, name, options, default, callback)
                local selected = default or options[1]
                Plague.Flags[flag] = selected

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 50)
                DropFrame.BackgroundTransparency = 1
                DropFrame.BorderSizePixel = 0
                DropFrame.ClipsDescendants = true
                DropFrame.Parent = SecContainer

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, 0, 0, 18)
                Title.Position = UDim2.new(0, 0, 0, 2)
                Title.BackgroundTransparency = 1
                Title.BorderSizePixel = 0
                Title.Text = name
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 12
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = DropFrame

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, 0, 0, 26)
                DropBtn.Position = UDim2.new(0, 0, 0, 24)
                DropBtn.BackgroundColor3 = Theme.Element
                DropBtn.BorderSizePixel = 0
                DropBtn.Text = "  " .. tostring(selected)
                DropBtn.TextColor3 = Theme.Accent
                DropBtn.Font = Theme.Font
                DropBtn.TextSize = 12
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.AutoButtonColor = false
                DropBtn.Selectable = false
                DropBtn.Parent = DropFrame
                Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)
                local dbStroke = Instance.new("UIStroke", DropBtn)
                dbStroke.Color = Theme.Border

                local Arrow = Instance.new("TextLabel")
                Arrow.Size = UDim2.new(0, 20, 1, 0)
                Arrow.Position = UDim2.new(1, -24, 0, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.BorderSizePixel = 0
                Arrow.Text = "+"
                Arrow.TextColor3 = Theme.SubText
                Arrow.Font = Theme.Font
                Arrow.TextSize = 15
                Arrow.Parent = DropBtn

                local optionsContainer = Instance.new("Frame")
                optionsContainer.Size = UDim2.new(1, 0, 0, 0)
                optionsContainer.Position = UDim2.new(0, 0, 0, 50)
                optionsContainer.BackgroundTransparency = 1
                optionsContainer.BorderSizePixel = 0
                optionsContainer.ClipsDescendants = true
                optionsContainer.Parent = DropFrame

                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Parent = optionsContainer

                local dropped = false

                local function updateList()
                    for _, child in pairs(optionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in pairs(options) do
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 24)
                        btn.BackgroundColor3 = Theme.Section
                        btn.BackgroundTransparency = 0
                        btn.BorderSizePixel = 0
                        btn.Text = "  " .. tostring(opt)
                        btn.TextColor3 = Theme.SubText
                        btn.Font = Theme.Font
                        btn.TextSize = 12
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.AutoButtonColor = false
                        btn.Selectable = false
                        btn.Parent = optionsContainer
                        
                        btn.MouseButton1Down:Connect(function() Tween(btn, {TextColor3 = Theme.Text}) end)

                        btn.MouseButton1Click:Connect(function()
                            selected = opt
                            Plague.Flags[flag] = selected
                            DropBtn.Text = "  " .. tostring(selected)
                            dropped = false
                            Arrow.Text = "+"
                            Tween(dbStroke, {Color = Theme.Border})
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)})
                            Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)})
                            if callback then task.spawn(callback, selected) end
                        end)
                    end
                end

                DropBtn.MouseButton1Click:Connect(function()
                    dropped = not dropped
                    if dropped then
                        updateList()
                        Arrow.Text = "-"
                        Tween(dbStroke, {Color = Theme.Accent})
                        local contentHeight = #options * 24
                        Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, contentHeight)})
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50 + contentHeight)})
                    else
                        Arrow.Text = "+"
                        Tween(dbStroke, {Color = Theme.Border})
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)})
                        Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)})
                    end
                end)

                if callback then task.spawn(callback, selected) end

                return {
                    Set = function(self, val)
                        selected = val
                        Plague.Flags[flag] = selected
                        DropBtn.Text = "  " .. tostring(selected)
                        if callback then task.spawn(callback, selected) end
                    end,
                    Refresh = function(self, newOptions)
                        options = newOptions
                        updateList()
                    end
                }
            end

            function Elements:CreateKeybind(flag, name, default, callback)
                local key = default or Enum.KeyCode.Unknown
                Plague.Flags[flag] = key

                local BindFrame = Instance.new("Frame")
                BindFrame.Size = UDim2.new(1, 0, 0, 28)
                BindFrame.BackgroundTransparency = 1
                BindFrame.BorderSizePixel = 0
                BindFrame.Parent = SecContainer

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -80, 1, 0)
                Title.Position = UDim2.new(0, 0, 0, 0)
                Title.BackgroundTransparency = 1
                Title.BorderSizePixel = 0
                Title.Text = name
                Title.TextColor3 = Theme.Text
                Title.Font = Theme.Font
                Title.TextSize = 12
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = BindFrame

                local BindBtn = Instance.new("TextButton")
                BindBtn.Size = UDim2.new(0, 70, 0, 20)
                BindBtn.Position = UDim2.new(1, -70, 0.5, -10)
                BindBtn.BackgroundColor3 = Theme.Element
                BindBtn.BorderSizePixel = 0
                BindBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
                BindBtn.TextColor3 = Theme.Accent
                BindBtn.Font = Theme.Font
                BindBtn.TextSize = 11
                BindBtn.AutoButtonColor = false
                BindBtn.Selectable = false
                BindBtn.Parent = BindFrame
                Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", BindBtn).Color = Theme.Border

                local binding = false
                BindBtn.MouseButton1Click:Connect(function()
                    binding = true
                    Plague.IsBinding = true
                    BindBtn.Text = "..."
                end)

                table.insert(Plague.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
                    if binding then
                        local newKey
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            newKey = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                            newKey = input.UserInputType
                        end

                        if newKey then
                            key = newKey
                            Plague.Flags[flag] = key
                            BindBtn.Text = key.Name
                            binding = false
                            
                            -- Delays resetting the binding state so global functions don't immediately trigger
                            task.delay(0.1, function() Plague.IsBinding = false end)
                            
                            if callback then task.spawn(callback, key) end
                        end
                    else
                        if not gpe and not Plague.IsBinding and (input.KeyCode == key or input.UserInputType == key) and key ~= Enum.KeyCode.Unknown then
                            if callback then task.spawn(callback, key) end
                        end
                    end
                end))

                return {
                    Set = function(self, newKey)
                        key = newKey
                        Plague.Flags[flag] = key
                        BindBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
                    end
                }
            end

            function Elements:CreateLabel(titleText, descText)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Size = UDim2.new(1, 0, 0, descText and 36 or 20)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.BorderSizePixel = 0
                LabelFrame.Parent = SecContainer

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, 0, 0, 18)
                Title.Position = UDim2.new(0, 0, 0, 0)
                Title.BackgroundTransparency = 1
                Title.BorderSizePixel = 0
                Title.Text = titleText
                Title.TextColor3 = Theme.Accent
                Title.Font = Theme.Font
                Title.TextSize = 12
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = LabelFrame

                local Desc
                if descText then
                    Desc = Instance.new("TextLabel")
                    Desc.Size = UDim2.new(1, 0, 0, 16)
                    Desc.Position = UDim2.new(0, 0, 0, 18)
                    Desc.BackgroundTransparency = 1
                    Desc.BorderSizePixel = 0
                    Desc.Text = descText
                    Desc.TextColor3 = Theme.SubText
                    Desc.Font = Theme.Font
                    Desc.TextSize = 11
                    Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Desc.Parent = LabelFrame
                end

                return {
                    Set = function(self, newTitle, newDesc)
                        Title.Text = newTitle
                        if Desc and newDesc then Desc.Text = newDesc end
                    end
                }
            end

            return Elements
        end
        return TabObj
    end

    -- Mandatory Settings Tab (Automatically sorted to the end)
    local SettingsTab = WindowObj:CreateTab("settings")
    local GeneralSec = SettingsTab:CreateSection("General", "Left")
    
    GeneralSec:CreateKeybind("UIToggleKey", "UI Toggle Key", Plague.ToggleKey, function(key)
        Plague.ToggleKey = key
    end)

    local ConfigSec = SettingsTab:CreateSection("Configuration", "Right")
    local cfgDropdown = ConfigSec:CreateDropdown("SelectedConfig", "Config File", {"Default"}, "Default")
    
    local function refreshConfigs()
        local files = {"Default"}
        if isfolder(configFolder) then
            for _, file in pairs(listfiles(configFolder)) do
                if file:match("%.json$") then
                    table.insert(files, file:match("([^/\\]+)%.json$"))
                end
            end
        end
        cfgDropdown:Refresh(files)
    end
    refreshConfigs()

    ConfigSec:CreateButton("Save Config", function()
        local cfgName = Plague.Flags["SelectedConfig"] or "Default"
        local path = configFolder .. "/" .. cfgName .. ".json"
        
        local saveTable = {}
        for k, v in pairs(Plague.Flags) do
            if typeof(v) == "EnumItem" then
                saveTable[k] = {Type = "Enum", Value = v.Name}
            else
                saveTable[k] = v
            end
        end
        
        writefile(path, HttpService:JSONEncode(saveTable))
        Plague:Notify("Config Saved", "Saved data to " .. cfgName, 3)
        refreshConfigs()
    end)

    ConfigSec:CreateButton("Load Config", function()
        local cfgName = Plague.Flags["SelectedConfig"] or "Default"
        local path = configFolder .. "/" .. cfgName .. ".json"
        if isfile(path) then
            local success, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
            if success and data then
                for k, v in pairs(data) do
                    if type(v) == "table" and v.Type == "Enum" then
                        Plague.Flags[k] = Enum.KeyCode[v.Value] or Enum.UserInputType[v.Value]
                    else
                        Plague.Flags[k] = v
                    end
                end
                Plague:Notify("Config Loaded", "Loaded data from " .. cfgName, 3)
            else
                Plague:Notify("Error", "Failed to parse config.", 3)
            end
        else
            Plague:Notify("Error", "Config file not found.", 3)
        end
    end)

    return WindowObj
end

return Plague
