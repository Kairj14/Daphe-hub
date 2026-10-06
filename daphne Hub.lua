-- daphne hub
-- by Kai

local genv = getgenv and getgenv() or _G
if genv._DaphneHubLoaded then
    warn("[daphne hub] O Hub já está em execução!")
    return
end
genv._DaphneHubLoaded = true

local ok, err = pcall(function()

local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/1.6.0/main.lua"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== CONFIGURAÇÕES AJUSTÁVEIS ====================
-- Transparência (0 = totalmente opaco, 1 = invisível)
local BG_TRANSPARENCY      = 0.15  -- wallpaper (menor = wallpaper mais forte)
local ELEMENT_TRANSPARENCY = 0.35  -- botões/toggles/sliders (menor = mais sólidos e legíveis)

-- Usuário com tema exclusivo
local SPECIAL_USER_ID = 10702584664
local IsSpecial = LocalPlayer.UserId == SPECIAL_USER_ID

local function GetIdealSize()
    local vs = Camera.ViewportSize
    return UDim2.fromOffset(
        math.clamp(math.floor(vs.X * 0.38), 360, 520),
        math.clamp(math.floor(vs.Y * 0.48), 320, 460)
    )
end

-- ==================== IMAGENS ====================
local function ConvertGitHubUrl(url)
    if url:find("github.com", 1, true) and not url:find("raw.githubusercontent.com", 1, true) then
        local r = url:gsub("github%.com", "raw.githubusercontent.com")
        r = r:gsub("/blob/", "/")
        return r
    end
    return url
end

local ImageCache = {}

-- Retorna um asset local (rbxasset://) ou nil se falhar. Usa cache (instantâneo na 2ª vez).
local function LoadImage(url, filename)
    if ImageCache[filename] then return ImageCache[filename] end
    if not (writefile and getcustomasset) then return nil end
    local directUrl = ConvertGitHubUrl(url)
    local success, result = pcall(function()
        local data = game:HttpGet(directUrl)
        writefile(filename, data)
        return getcustomasset(filename)
    end)
    if success and result then
        ImageCache[filename] = result
        return result
    end
    return nil
end

-- OBS: o Roblox NÃO suporta .webp. Se o tema Rem não aparecer,
-- converta as imagens para .png/.jpg, suba no GitHub e troque URLs e extensões abaixo.
local ThemesData = {
    Daphne = {
        Wallpaper = "https://raw.githubusercontent.com/Kairj14/Imagens-projeto-daphne-hub/main/39eaa07f5996adf8d7cee7a7010e496b.jpg",
        WallpaperFile = "daphne_bg.jpg",
        Button = "https://raw.githubusercontent.com/Kairj14/Imagens-projeto-daphne-hub/main/432d738f3208ac3d8e828f183ca286f6.jpg",
        ButtonFile = "daphne_btn.jpg",
        BorderColor = Color3.fromRGB(180, 100, 255)
    },
    Echidna = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/7fc8386f0c88de03b12278d8c7b5e161.jpg",
        WallpaperFile = "echidna_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/cdc29a5e973d877bf988fde59b258173.jpg",
        ButtonFile = "echidna_btn.jpg",
        BorderColor = Color3.fromRGB(0, 0, 0)
    },
    Rem = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/0e0d1960fcd44de9ab38d466eea8d332.webp",
        WallpaperFile = "rem_bg.webp",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/6e130b6dc69747c7828a122faab45b69.webp",
        ButtonFile = "rem_btn.webp",
        BorderColor = Color3.fromRGB(50, 150, 255)
    },
    ["Emília"] = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/0fc15f7ab964a63013f200d57e572b2f.jpg",
        WallpaperFile = "emilia_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/adfbfb0e6a025e038add8b615d353986.jpg",
        ButtonFile = "emilia_btn.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255)
    },
    Shaula = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/5a6159c30536b4c32818c17469b87ad9.jpg",
        WallpaperFile = "shaula_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/aa78c40bf14df69b9190dd9f7c7ba53f.jpg",
        ButtonFile = "shaula_btn.jpg",
        BorderColor = Color3.fromRGB(120, 70, 40)
    },
    Beatrice = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/b664e5f267e2879c024c346136a4a8db.jpg",
        WallpaperFile = "beatrice_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/e51fca75da07924486a1481e1adc9813.jpg",
        ButtonFile = "beatrice_btn.jpg",
        BorderColor = Color3.fromRGB(255, 220, 0)
    }
}

local ThemeOrder = {"Daphne", "Echidna", "Rem", "Emília", "Shaula", "Beatrice"}

-- Temas exclusivos (usados só pelo SPECIAL_USER_ID).
-- Wallpaper e botão de minimizar usam a mesma imagem.
local SpecialThemes = {
    Especial = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_194907_Gallery.jpg",
        WallpaperFile = "especial_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_194907_Gallery.jpg",
        ButtonFile = "especial_bg.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255)
    },
    ["Tema 2"] = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195018_Instagram.jpg",
        WallpaperFile = "tema2_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195018_Instagram.jpg",
        ButtonFile = "tema2_bg.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255)
    },
    ["Tema 3"] = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195122_Instagram.jpg",
        WallpaperFile = "tema3_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195122_Instagram.jpg",
        ButtonFile = "tema3_bg.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255)
    }
}
local SpecialOrder = {"Tema 2", "Tema 3"}

-- Tabelas ativas conforme o usuário
local ActiveThemes = IsSpecial and SpecialThemes or ThemesData
local ActiveOrder = IsSpecial and SpecialOrder or ThemeOrder
local DefaultThemeName = IsSpecial and "Especial" or "Daphne"

-- ==================== FRASES POR PERSONAGEM ====================
-- Versões em pt-br das falas (revise a redação se quiser a tradução oficial exata).
local ThemeQuotes = {
    Daphne = {
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
        "O que você ouvir de Daphne, Subaruun?",
        "Subaruun tem um cheiro tão bom... Daphne quer devorar você."
    },
    Echidna = {
        "Eu sou a Bruxa da Ganância, Echidna.",
        "Minha sede de conhecimento nunca será saciada.",
        "Venha, sente-se e tome um chá comigo.",
        "Tudo o que eu quero é saber."
    },
    Rem = {
        "Subaru-kun é o herói de Rem.",
        "Vamos recomeçar do zero, Subaru-kun.",
        "Rem ama Subaru-kun.",
        "Rem vai estar sempre ao seu lado."
    },
    ["Emília"] = {
        "Meu nome é Emília. Apenas Emília.",
        "Eu vou me tornar rainha e mudar este reino.",
        "Obrigada por estar comigo, Subaru.",
        "Eu não vou desistir."
    },
    Shaula = {
        "Shaula esperou quatrocentos anos por este momento.",
        "Shaula só quer ver a Mestra Echidna feliz.",
        "Pode deixar com a Shaula!"
    },
    Beatrice = {
        "Eu sou Beatrice, guardiã da Biblioteca Proibida.",
        "Betty esperou quatrocentos anos por alguém como você.",
        "De agora em diante, Betty estará ao seu lado, Subaru."
    }
}

local function RandomQuote(themeName)
    local list = ThemeQuotes[themeName]
    if not list or #list == 0 then return nil end
    return list[math.random(1, #list)]
end

-- ==================== TEMA FLUENT ====================
local CurrentThemeName = DefaultThemeName
local CurrentTheme = ActiveThemes[CurrentThemeName]
local CurrentWallpaperAsset = LoadImage(CurrentTheme.Wallpaper, CurrentTheme.WallpaperFile)
local CurrentButtonAsset = LoadImage(CurrentTheme.Button, CurrentTheme.ButtonFile)

local function MakeTheme(name, background)
    return {
        Name = name, Accent = "#b464ff", AcrylicMain = "#14101e", AcrylicBorder = "#28193c",
        AcrylicGradient = ColorSequence.new(Color3.fromHex("#191228"), Color3.fromHex("#0f0a19")), AcrylicNoise = 0.85,
        TitleBarLine = "#a050ff", Tab = "#322346", Element = "#2d1e41", ElementBorder = "#503278", InElementBorder = "#8c5adc",
        ElementTransparency = ELEMENT_TRANSPARENCY, ElementBorderThickness = 0.5, ToggleSlider = "#8c46e6", ToggleToggled = "#c88cff",
        SliderRail = "#3c285a", CheckboxUnchecked = "#503278", CheckboxChecked = "#8c5adc", CheckboxCheck = "#e6c8ff",
        ProgressBarRail = "#2e1450", ProgressBarFill = "#a078f0", DropdownFrame = "#6433b4", DropdownHolder = "#6e46be",
        DropdownBorder = "#502890", DropdownOption = "#7850c8", DropdownBorderThickness = 0.5, Keybind = "#8256d2",
        Input = "#6433b4", InputFocused = "#966ee6", InputIndicator = "#aa82fa", Dialog = "#6e46be", DialogHolder = "#8256d2",
        DialogHolderLine = "#5a32aa", DialogButton = "#8c64dc", DialogButtonBorder = "#502890", DialogBorder = "#7850c8",
        DialogInput = "#6433b4", DialogInputLine = "#966ee6", Text = "#f0e6ff", SubText = "#b4a0d2", Hover = "#b464ff",
        HoverChange = 0.5, Background = background or "", BackgroundTransparency = BG_TRANSPARENCY,
    }
end

Fluent:AddTheme(MakeTheme("DaphneCustom", CurrentWallpaperAsset))

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

-- ==================== WALLPAPER ====================
local ThemeCounter = 0
local WallpaperTargets = nil -- cache dos objetos de wallpaper (troca instantânea)

local function ApplyWallpaper(asset)
    if not asset then return false end

    -- Caminho rápido: já sabemos quais objetos mudar
    if WallpaperTargets then
        local stillValid = false
        for _, obj in ipairs(WallpaperTargets) do
            if obj and obj.Parent then
                obj.Image = asset
                stillValid = true
            end
        end
        if stillValid then return true end
        WallpaperTargets = nil
    end

    local found = {}

    -- 1) Caminhos conhecidos do Fluent
    pcall(function()
        local w = Fluent.Window
        if w and w.AcrylicPaint and w.AcrylicPaint.Wallpaper then
            table.insert(found, w.AcrylicPaint.Wallpaper)
        end
    end)

    if #found == 0 then
        pcall(function()
            if Window.AcrylicPaint and Window.AcrylicPaint.Wallpaper then
                table.insert(found, Window.AcrylicPaint.Wallpaper)
            end
        end)
    end

    -- 2) Procura ImageLabels de wallpaper/background dentro da janela
    if #found == 0 then
        pcall(function()
            local root = Window.Root
            if not root then return end
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("ImageLabel") then
                    local n = string.lower(d.Name)
                    if n:find("wallpaper") or n:find("background") then
                        table.insert(found, d)
                    end
                end
            end
        end)
    end

    if #found > 0 then
        for _, obj in ipairs(found) do
            pcall(function() obj.Image = asset end)
        end
        WallpaperTargets = found
        return true
    end

    -- 3) Último recurso: registra um tema novo com o wallpaper e aplica
    local applied = false
    pcall(function()
        ThemeCounter += 1
        local newName = "DaphneCustom_" .. ThemeCounter
        Fluent:AddTheme(MakeTheme(newName, asset))
        Fluent:SetTheme(newName)
        applied = true
    end)
    return applied
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
    MinimizerBtnObj.Image = CurrentButtonAsset or ""
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

-- Cria aba com fallback caso o ícone não exista na lib
local function AddTabSafe(title, icon)
    local okTab, tab = pcall(function()
        return Window:AddTab({ Title = title, Icon = icon })
    end)
    if okTab and tab then return tab end
    return Window:AddTab({ Title = title })
end

-- ==================== ABA MAIN (limpa) ====================
local Main = AddTabSafe("Main", "solar/home-bold")
-- Adicione suas funções aqui (Main:AddButton, Main:AddToggle, ...)

-- ==================== ABA CONFIG (abaixo da Main) ====================
local ConfigTab = AddTabSafe("Config", "solar/settings-bold")

ConfigTab:AddParagraph({
    Title = "Configurações de Tema",
    Content = "Escolha um tema para mudar o papel de parede e o botão de minimizar."
})

local ThemeToken = 0

ConfigTab:AddDropdown("ThemeDropdown", {
    Title = "Selecionar Tema",
    Values = ActiveOrder,
    Multi = false,
    Default = (not IsSpecial) and 1 or nil, -- usuário especial começa no tema exclusivo, sem seleção
    Callback = function(Value)
        if not Active then return end
        if Value == CurrentThemeName then return end -- evita recarregar no init
        local selectedData = ActiveThemes[Value]
        if not selectedData then return end

        ThemeToken += 1
        local token = ThemeToken

        task.spawn(function()
            -- Se já estiver em cache (pré-carregado), é instantâneo
            local newWall = LoadImage(selectedData.Wallpaper, selectedData.WallpaperFile)
            local newButton = LoadImage(selectedData.Button, selectedData.ButtonFile)

            -- Se o usuário trocou de tema de novo enquanto baixava, ignora este
            if not Active or token ~= ThemeToken then return end

            CurrentThemeName = Value
            CurrentTheme = selectedData

            if MinimizerOutline then
                MinimizerOutline.Color = selectedData.BorderColor
            end
            if MinimizerBtnObj and newButton then
                MinimizerBtnObj.Image = newButton
            end

            local wallOk = newWall and ApplyWallpaper(newWall)

            if newWall and newButton and wallOk then
                local quote = (not IsSpecial) and RandomQuote(Value) or nil
                Fluent:Notify({
                    Title = quote and Value or "Tema Alterado",
                    Content = quote or ("Tema atualizado para: " .. Value),
                    Duration = 4
                })
            else
                Fluent:Notify({
                    Title = "Tema parcialmente aplicado",
                    Content = "Não foi possível carregar todas as imagens de " .. Value .. " (formato .webp não é suportado pelo Roblox).",
                    Duration = 5
                })
            end
        end)
    end
})

pcall(function() Window:SelectTab(1) end)

-- ==================== PRÉ-CARREGAMENTO (troca de tema instantânea) ====================
task.spawn(function()
    for _, name in ipairs(ActiveOrder) do
        if not Active then return end
        local data = ActiveThemes[name]
        if data then
            local w = LoadImage(data.Wallpaper, data.WallpaperFile)
            local b = LoadImage(data.Button, data.ButtonFile)
            local list = {}
            if w then table.insert(list, w) end
            if b and b ~= w then table.insert(list, b) end
            if #list > 0 then
                pcall(function() ContentProvider:PreloadAsync(list) end)
            end
        end
    end
end)

-- ==================== FRASE INICIAL (não aparece para o usuário especial) ====================
if not IsSpecial then
    local quote = RandomQuote("Daphne")
    if quote then
        pcall(function()
            Fluent:Notify({
                Title = "Daphne",
                Content = quote,
                Duration = 5
            })
        end)
    end
end

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
