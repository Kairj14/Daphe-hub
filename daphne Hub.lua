-- daphne hub
-- by Kai

local genv = getgenv and getgenv() or _G
if genv._DaphneHubLoaded then return end
genv._DaphneHubLoaded = true

local ok, err = pcall(function()

local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/1.6.0/main.lua"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function GetIdealSize()
    local vs = Camera.ViewportSize
    return UDim2.fromOffset(
        math.clamp(math.floor(vs.X * 0.38), 360, 520),
        math.clamp(math.floor(vs.Y * 0.48), 320, 460)
    )
end

local function ConvertGitHubUrl(url)
    if url:find("github.com") and not url:find("raw.githubusercontent.com") then
        return url:gsub("github.com", "raw.githubusercontent.com"):gsub("/blob/", "/")
    end
    return url
end

local function LoadImage(url, filename)
    local directUrl = ConvertGitHubUrl(url)
    local success, result = pcall(function()
        if writefile and getcustomasset then
            writefile(filename, game:HttpGet(directUrl))
            return getcustomasset(filename)
        end
        return nil
    end)
    return (success and result) and result or nil
end

local ThemesData = {
    Daphne = {
        Wallpaper = "https://raw.githubusercontent.com/Kairj14/Imagens-projeto-daphne-hub/main/39eaa07f5996adf8d7cee7a7010e496b.jpg",
        Button = "https://raw.githubusercontent.com/Kairj14/Imagens-projeto-daphne-hub/main/432d738f3208ac3d8e828f183ca286f6.jpg",
        BorderColor = Color3.fromRGB(180, 100, 255),
        FileName = "daphne_btn.jpg"
    },
    Echidna = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/7fc8386f0c88de03b12278d8c7b5e161.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/cdc29a5e973d877bf988fde59b258173.jpg",
        BorderColor = Color3.fromRGB(0, 0, 0),
        FileName = "echidna_btn.jpg"
    },
    Rem = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/0e0d1960fcd44de9ab38d466eea8d332.webp",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/6e130b6dc69747c7828a122faab45b69.webp",
        BorderColor = Color3.fromRGB(50, 150, 255),
        FileName = "rem_btn.webp"
    },
    Emília = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/0fc15f7ab964a63013f200d57e572b2f.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/adfbfb0e6a025e038add8b615d353986.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255),
        FileName = "emilia_btn.jpg"
    },
    Shaula = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/5a6159c30536b4c32818c17469b87ad9.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/aa78c40bf14df69b9190dd9f7c7ba53f.jpg",
        BorderColor = Color3.fromRGB(120, 70, 40),
        FileName = "shaula_btn.jpg"
    },
    Beatrice = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/b664e5f267e2879c024c346136a4a8db.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/e51fca75da07924486a1481e1adc9813.jpg",
        BorderColor = Color3.fromRGB(255, 220, 0),
        FileName = "beatrice_btn.jpg"
    }
}

local CurrentTheme = ThemesData["Daphne"]
local CurrentAsset = LoadImage(CurrentTheme.Button, CurrentTheme.FileName)

Fluent:AddTheme({
    Name = "DaphneCustom", Accent = "#b464ff", AcrylicMain = "#14101e", AcrylicBorder = "#28193c",
    AcrylicGradient = ColorSequence.new(Color3.fromHex("#191228"), Color3.fromHex("#0f0a19")), AcrylicNoise = 0.85,
    TitleBarLine = "#a050ff", Tab = "#322346", Element = "#2d1e41", ElementBorder = "#503278", InElementBorder = "#8c5adc",
    ElementTransparency = 0.85, ElementBorderThickness = 0.5, ToggleSlider = "#8c46e6", ToggleToggled = "#c88cff",
    SliderRail = "#3c285a", CheckboxUnchecked = "#503278", CheckboxChecked = "#8c5adc", CheckboxCheck = "#e6c8ff",
    ProgressBarRail = "#2e1450", ProgressBarFill = "#a078f0", DropdownFrame = "#6433b4", DropdownHolder = "#6e46be",
    DropdownBorder = "#502890", DropdownOption = "#7850c8", DropdownBorderThickness = 0.5, Keybind = "#8256d2",
    Input = "#6433b4", InputFocused = "#966ee6", InputIndicator = "#aa82fa", Dialog = "#6e46be", DialogHolder = "#8256d2",
    DialogHolderLine = "#5a32aa", DialogButton = "#8c64dc", DialogButtonBorder = "#502890", DialogBorder = "#7850c8",
    DialogInput = "#6433b4", DialogInputLine = "#966ee6", Text = "#f0e6ff", SubText = "#b4a0d2", Hover = "#b464ff",
    HoverChange = 0.5, Background = ConvertGitHubUrl(CurrentTheme.Wallpaper), BackgroundTransparency = 0.25,
})

local Window = Fluent:CreateWindow({
    Title = "daphne hub", SubTitle = "by Kai", TabWidth = 140, Size = GetIdealSize(),
    Acrylic = true, Theme = "DaphneCustom", MinimizeKey = Enum.KeyCode.LeftControl
})

local Active, Connections, MinimizerGui, MinimizerBtnObj, MinimizerOutline = true, {}, nil, nil, nil

local function Track(conn)
    if conn then table.insert(Connections, conn) end
    return conn
end

local function ShutdownEverything()
    Active = false
    genv._DaphneHubLoaded = false
    for _, conn in ipairs(Connections) do
        pcall(function()
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end)
    end
    Connections = {}
    pcall(function() if MinimizerGui then MinimizerGui:Destroy(); MinimizerGui = nil end end)
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
    pcall(function() if Fluent and Fluent.Destroy then Fluent:Destroy() end end)
    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            local n = string.lower(gui.Name)
            if n:find("fluent") or n:find("daphne") then gui:Destroy() end
        end
    end)
end

-- ==================== BOTÃO MINIMIZAR ====================
do
    MinimizerGui = Instance.new("ScreenGui")
    MinimizerGui.Name = "DaphneMinimizer"
    MinimizerGui.ResetOnSpawn = false
    MinimizerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() MinimizerGui.Parent = CoreGui end)
    if not MinimizerGui.Parent then
        MinimizerGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    MinimizerBtnObj = Instance.new("ImageButton")
    MinimizerBtnObj.Name = "MinBtn"
    MinimizerBtnObj.Size = UDim2.fromOffset(48, 48)
    MinimizerBtnObj.Position = UDim2.new(0, 20, 0.5, -24)
    MinimizerBtnObj.BackgroundTransparency = 1
    MinimizerBtnObj.BorderSizePixel = 0
    MinimizerBtnObj.AutoButtonColor = false
    MinimizerBtnObj.Image = CurrentAsset or ConvertGitHubUrl(CurrentTheme.Button)
    MinimizerBtnObj.ScaleType = Enum.ScaleType.Crop
    MinimizerBtnObj.Parent = MinimizerGui

    MinimizerOutline = Instance.new("UIStroke")
    MinimizerOutline.Name = "DaphneOutline"
    MinimizerOutline.Color = CurrentTheme.BorderColor
    MinimizerOutline.Thickness = 1.5
    MinimizerOutline.Transparency = 0
    MinimizerOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MinimizerOutline.LineJoinMode = Enum.LineJoinMode.Round
    MinimizerOutline.Parent = MinimizerBtnObj

    local dragging, moved, dragStart, startPos = false, false, nil, nil

    Track(MinimizerBtnObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, dragStart, startPos = true, false, input.Position, MinimizerBtnObj.Position
        end
    end))

    Track(MinimizerBtnObj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        if delta.Magnitude > 8 then
            moved = true
            MinimizerBtnObj.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))

    Track(MinimizerBtnObj.MouseButton1Click:Connect(function()
        if not Active or moved then return end
        local okMin = pcall(function() Window:Minimize() end)
        if not okMin then
            pcall(function()
                if Window.Root then
                    Window.Root.Visible = not Window.Root.Visible
                end
            end)
        end
    end))
end

-- ==================== FECHAR ====================
local function AskDeleteHub()
    if not Active or not Window then return end
    Window:Dialog({
        Title = "Fechar daphne hub",
        Content = "Tem certeza que deseja apagar o hub?",
        Buttons = {
            { Title = "Não", Callback = function() end },
            { Title = "Sim", Callback = function()
                task.defer(function()
                    if not Active then return end
                    Window:Dialog({
                        Title = "Confirmação final",
                        Content = "Isso vai apagar TUDO e desativar todas as funções. Tem certeza absoluta?",
                        Buttons = {
                            { Title = "Não", Callback = function() end },
                            { Title = "Sim, apagar", Callback = function() ShutdownEverything() end }
                        }
                    })
                end)
            end }
        }
    })
end

task.defer(function()
    local root = Window and Window.Root
    if not root then return end
    local function tryHook(obj)
        if not (obj:IsA("TextButton") or obj:IsA("ImageButton")) then return end
        local parentName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
        local objName = string.lower(obj.Name)
        if objName:find("close") or parentName:find("title") then
            Track(obj.MouseButton1Click:Connect(function()
                if Active then AskDeleteHub() end
            end))
        end
    end
    for _, d in ipairs(root:GetDescendants()) do pcall(tryHook, d) end
end)

-- ==================== ABA MAIN ====================
local Main = Window:AddTab({ Title = "Main", Icon = "solar/home-bold" })

Main:AddParagraph({ Title = "Bem-vindo", Content = "daphne hub by Kai" })

Main:AddButton({
    Title = "Botão de Exemplo",
    Description = "Clique para testar",
    Callback = function()
        if not Active then return end
        Fluent:Notify({ Title = "daphne hub", Content = "Botão funcionando!", Duration = 3 })
    end
})

Main:AddToggle("ExemploToggle", {
    Title = "Toggle de Exemplo",
    Default = false,
    Callback = function(Value)
        if not Active then return end
        print("Toggle:", Value)
    end
})

Main:AddSlider("ExemploSlider", {
    Title = "Slider de Exemplo",
    Description = "Valor de 0 a 100",
    Default = 50, Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value)
        if not Active then return end
        print("Slider:", Value)
    end
})

Main:AddDropdown("ExemploDropdown", {
    Title = "Dropdown de Exemplo",
    Values = {"Opção 1", "Opção 2", "Opção 3"},
    Multi = false, Default = 1,
    Callback = function(Value)
        if not Active then return end
        print("Dropdown:", Value)
    end
})

Main:AddKeybind("ExemploKeybind", {
    Title = "Keybind de Exemplo",
    Mode = "Toggle", Default = "E",
    Callback = function(Value)
        if not Active then return end
        print("Keybind:", Value)
    end
})

-- ==================== ABA CONFIG ====================
local ConfigTab = Window:AddTab({ Title = "Config", Icon = "solar/settings-bold" })

ConfigTab:AddParagraph({ Title = "Configurações de Tema", Content = "Alterne o tema do hub para mudar o papel de parede e o botão flutuante." })

ConfigTab:AddDropdown("ThemeDropdown", {
    Title = "Selecionar Tema",
    Values = {"Daphne", "Echidna", "Rem", "Emília", "Shaula", "Beatrice"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        if not Active then return end
        local selectedData = ThemesData[Value]
        if selectedData then
            CurrentTheme = selectedData
            local newAsset = LoadImage(selectedData.Button, selectedData.FileName)
            if MinimizerBtnObj then
                MinimizerBtnObj.Image = newAsset or ConvertGitHubUrl(selectedData.Button)
            end
            if MinimizerOutline then
                MinimizerOutline.Color = selectedData.BorderColor
            end
            pcall(function()
                if Fluent.Window and Fluent.Window.AcrylicPaint and Fluent.Window.AcrylicPaint.Wallpaper then
                    Fluent.Window.AcrylicPaint.Wallpaper.Image = ConvertGitHubUrl(selectedData.Wallpaper)
                end
            end)
            Fluent:Notify({
                Title = "Tema Alterado",
                Content = "Tema atualizado para: " .. Value,
                Duration = 3
            })
        end
    end
})

Window:SelectTab(1)

-- ==================== FRASES DA WEB NOVEL ====================
local daphneQuotes = {
    "Se você não pode comer, você morre, não é?",
    "Na vida, a Gula é o desejo mais importante de todos.",
    "Mesmo que o coração se sinta saciado, as pessoas morrem se não comerem.",
    "Comer ou ser comido é a única relação neste mundo.",
    "O estômago de Daphne nunca foi satisfeito em toda a minha vida.",
    "Tente, se for capaz.",
    "Eu fico com mais fome apenas por existir...",
    "Você não acha que todos tratam a gula de forma muito leviana?",
    "Aquelas crianças herdaram o estômago vazio de Daphne.",
    "Não é vergonhoso querer comer sem o risco de ser devorado?",
    "A Baleia Branca é enorme... muitas pessoas poderiam se fartar com ela.",
    "Com o Grande Coelho, ninguém jamais teria que passar fome.",
    "A fome extrema pode transformar as pessoas em algo pior do que feras.",
    "O que você quer ouvir de Daphne, Subaruun?",
    "Subaruun tem um cheiro tão bom... Daphne quer devorar você."
}

local quote = daphneQuotes[math.random(1, #daphneQuotes)]

pcall(function()
    Fluent:Notify({
        Title = "Daphne",
        Content = quote,
        Duration = 5
    })
end)

end)

if not ok then
    genv._DaphneHubLoaded = false
    warn("[daphne hub] ERRO:", err)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "daphne hub - ERRO",
            Text = tostring(err),
            Duration = 8
        })
    end)
end
