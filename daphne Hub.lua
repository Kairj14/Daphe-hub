-- daphne hub
-- by Kai

local genv = getgenv and getgenv() or _G

-- ==================== AVISO: SCRIPT JÁ EXECUTADO ====================
local AlreadyMsg = {
    en = "The script is already running!",
    pt = "O script já está executado!",
    es = "¡El script ya se está ejecutando!",
    ru = "Скрипт уже запущен!",
}

local function PeekLang()
    local lang = "en"
    pcall(function()
        if isfile and readfile and isfile("daphne_hub_config.json") then
            local d = game:GetService("HttpService"):JSONDecode(readfile("daphne_hub_config.json"))
            if type(d) == "table" and type(d.lang) == "string" and AlreadyMsg[d.lang] then lang = d.lang end
        end
    end)
    return lang
end

local function ShowAlreadyRunning()
    task.spawn(function()
        pcall(function()
            local TweenService = game:GetService("TweenService")
            local CoreGui = game:GetService("CoreGui")
            local LP = game:GetService("Players").LocalPlayer

            local old = CoreGui:FindFirstChild("DaphneAlreadyRunning")
            if old then old:Destroy() end

            local gui = Instance.new("ScreenGui")
            gui.Name = "DaphneAlreadyRunning"
            gui.ResetOnSpawn = false
            gui.DisplayOrder = 999
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            pcall(function() gui.Parent = CoreGui end)
            if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

            local frame = Instance.new("Frame")
            frame.AnchorPoint = Vector2.new(1, 1)
            frame.Size = UDim2.fromOffset(290, 60)
            frame.Position = UDim2.new(1, 320, 1, -20)
            frame.BackgroundColor3 = Color3.fromRGB(24, 18, 36)
            frame.BorderSizePixel = 0
            frame.Parent = gui

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(180, 100, 255)
            stroke.Thickness = 1.2
            stroke.Parent = frame

            local title = Instance.new("TextLabel")
            title.BackgroundTransparency = 1
            title.Position = UDim2.fromOffset(14, 8)
            title.Size = UDim2.new(1, -28, 0, 20)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 15
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextColor3 = Color3.fromRGB(240, 230, 255)
            title.Text = "daphne hub"
            title.Parent = frame

            local msg = Instance.new("TextLabel")
            msg.BackgroundTransparency = 1
            msg.Position = UDim2.fromOffset(14, 30)
            msg.Size = UDim2.new(1, -28, 0, 20)
            msg.Font = Enum.Font.Gotham
            msg.TextSize = 13
            msg.TextXAlignment = Enum.TextXAlignment.Left
            msg.TextColor3 = Color3.fromRGB(180, 160, 210)
            msg.Text = AlreadyMsg[PeekLang()] or AlreadyMsg.en
            msg.Parent = frame

            TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { Position = UDim2.new(1, -20, 1, -20) }):Play()
            task.wait(3.5)
            local t = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { Position = UDim2.new(1, 320, 1, -20) })
            t:Play()
            t.Completed:Wait()
            gui:Destroy()
        end)
    end)
end

if genv._DaphneHubLoaded then
    ShowAlreadyRunning()
    return
end
genv._DaphneHubLoaded = true

local ok, err = pcall(function()

local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/1.6.0/main.lua"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local origFluentDestroy = Fluent.Destroy

math.randomseed(math.floor(os.clock() * 1000000) + os.time())

-- ==================== CONFIGURAÇÕES AJUSTÁVEIS ====================
local BG_TRANSPARENCY      = 0
local ELEMENT_TRANSPARENCY = 0.62   -- toggles/opções do Fluent (maior = mais transparente)
local CARD_TRANSPARENCY    = 0.5    -- cartões personalizados

local SPECIAL_USER_ID = 10702584664
local IsSpecial = LocalPlayer.UserId == SPECIAL_USER_ID

local function GetIdealSize()
    local vs = Camera.ViewportSize
    return UDim2.fromOffset(
        math.clamp(math.floor(vs.X * 0.38), 360, 520),
        math.clamp(math.floor(vs.Y * 0.48), 320, 460)
    )
end

-- ==================== IMAGENS (com cache em disco) ====================
local function ConvertGitHubUrl(url)
    if url:find("github.com", 1, true) and not url:find("raw.githubusercontent.com", 1, true) then
        local r = url:gsub("github%.com", "raw.githubusercontent.com")
        r = r:gsub("/blob/", "/")
        return r
    end
    return url
end

local function UrlHash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
    return string.format("%08x", h)
end

local ImageCache = {}

local function LoadImage(url, filename)
    if ImageCache[filename] then return ImageCache[filename] end
    if not (writefile and getcustomasset) then return nil end
    local cname = "dh_" .. UrlHash(url) .. "_" .. filename
    local success, result = pcall(function()
        if not (isfile and isfile(cname)) then
            local data = game:HttpGet(ConvertGitHubUrl(url))
            if not data or #data == 0 then error("vazio") end
            writefile(cname, data)
        end
        return getcustomasset(cname)
    end)
    if success and result then
        ImageCache[filename] = result
        return result
    end
    return nil
end

-- OBS: o Roblox NÃO suporta .webp. Converta as imagens do Rem para .png/.jpg.
local ThemesData = {
    Daphne = {
        Wallpaper = "https://raw.githubusercontent.com/Kairj14/Imagens-projeto-daphne-hub/main/39eaa07f5996adf8d7cee7a7010e496b.jpg",
        WallpaperFile = "daphne_bg.jpg",
        Button = "https://raw.githubusercontent.com/Kairj14/Imagens-projeto-daphne-hub/main/432d738f3208ac3d8e828f183ca286f6.jpg",
        ButtonFile = "daphne_btn.jpg",
        BorderColor = Color3.fromRGB(180, 100, 255),
        Accent = nil
    },
    Echidna = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/7fc8386f0c88de03b12278d8c7b5e161.jpg",
        WallpaperFile = "echidna_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/cdc29a5e973d877bf988fde59b258173.jpg",
        ButtonFile = "echidna_btn.jpg",
        BorderColor = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(200, 200, 218)
    },
    Rem = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/0e0d1960fcd44de9ab38d466eea8d332.webp",
        WallpaperFile = "rem_bg.webp",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/6e130b6dc69747c7828a122faab45b69.webp",
        ButtonFile = "rem_btn.webp",
        BorderColor = Color3.fromRGB(50, 150, 255),
        Accent = Color3.fromRGB(70, 140, 255)
    },
    ["Emília"] = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/0fc15f7ab964a63013f200d57e572b2f.jpg",
        WallpaperFile = "emilia_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/adfbfb0e6a025e038add8b615d353986.jpg",
        ButtonFile = "emilia_btn.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(175, 220, 255)
    },
    Shaula = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/5a6159c30536b4c32818c17469b87ad9.jpg",
        WallpaperFile = "shaula_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/aa78c40bf14df69b9190dd9f7c7ba53f.jpg",
        ButtonFile = "shaula_btn.jpg",
        BorderColor = Color3.fromRGB(120, 70, 40),
        Accent = Color3.fromRGB(215, 150, 90)
    },
    Beatrice = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/b664e5f267e2879c024c346136a4a8db.jpg",
        WallpaperFile = "beatrice_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/e51fca75da07924486a1481e1adc9813.jpg",
        ButtonFile = "beatrice_btn.jpg",
        BorderColor = Color3.fromRGB(255, 220, 0),
        Accent = Color3.fromRGB(255, 215, 70)
    }
}

local ThemeOrder = {"Daphne", "Echidna", "Rem", "Emília", "Shaula", "Beatrice"}

local SpecialThemes = {
    Especial = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_194907_Gallery.jpg",
        WallpaperFile = "especial_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_194907_Gallery.jpg",
        ButtonFile = "especial_bg.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(235, 235, 245)
    },
    ["Tema 2"] = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195018_Instagram.jpg",
        WallpaperFile = "tema2_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195018_Instagram.jpg",
        ButtonFile = "tema2_bg.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(235, 235, 245)
    },
    ["Tema 3"] = {
        Wallpaper = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195122_Instagram.jpg",
        WallpaperFile = "tema3_bg.jpg",
        Button = "https://github.com/Kairj14/Imagens-projeto-daphne-hub/blob/main/Screenshot_20261006_195122_Instagram.jpg",
        ButtonFile = "tema3_bg.jpg",
        BorderColor = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(235, 235, 245)
    }
}
local SpecialOrder = {"Especial", "Tema 2", "Tema 3"}

local ActiveThemes = IsSpecial and SpecialThemes or ThemesData
local ActiveOrder = IsSpecial and SpecialOrder or ThemeOrder
local DefaultThemeName = IsSpecial and "Especial" or "Daphne"

local function IndexOf(list, value)
    for i, v in ipairs(list) do
        if v == value then return i end
    end
    return nil
end

-- ==================== IDIOMAS ====================
local LangOrder = { "en", "pt", "es", "ru" }
local LangNames = { en = "English", pt = "Português (Brasil)", es = "Español", ru = "Русский" }

-- ==================== SALVAMENTO AUTOMÁTICO ====================
local CONFIG_FILE = "daphne_hub_config.json"

local Defaults = {
    ESPBox = false,
    ESPName = false,
    ESPDistance = false,
    ESPDistUnit = "Studs",
    ESPArrow = false,
    ESPOutline = false,
    ESPOutlineThin = 55,
    Fullbright = false,
    AntiSit = true,
    AutoRejoin = false,
    Noclip = false,
    CamNoclip = false,
}

local Settings = {}
for k, v in pairs(Defaults) do Settings[k] = v end

local Config = { theme = nil, lang = "en", lastQuote = nil, lastQuotes = {} }

local function LoadConfig()
    if not (isfile and readfile) then return end
    pcall(function()
        if not isfile(CONFIG_FILE) then return end
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(data) ~= "table" then return end
        if type(data.theme) == "string" and ActiveThemes[data.theme] then Config.theme = data.theme end
        if type(data.lang) == "string" and LangNames[data.lang] then Config.lang = data.lang end
        if type(data.lastQuote) == "string" then Config.lastQuote = data.lastQuote end
        if type(data.lastQuotes) == "table" then
            for k, v in pairs(data.lastQuotes) do
                if type(k) == "string" and type(v) == "string" then Config.lastQuotes[k] = v end
            end
        end
        if type(data.options) == "table" then
            for k, def in pairs(Defaults) do
                local v = data.options[k]
                if type(v) == type(def) then Settings[k] = v end
            end
        end
    end)
    if Settings.ESPDistUnit == "Metros" then Settings.ESPDistUnit = "Meters" end
    if Settings.ESPDistUnit ~= "Studs" and Settings.ESPDistUnit ~= "Meters" then
        Settings.ESPDistUnit = "Studs"
    end
    Settings.ESPOutlineThin = math.clamp(math.floor(Settings.ESPOutlineThin), 0, 90)
    Settings.Noclip = false
    Settings.CamNoclip = false
end

LoadConfig()

local SaveQueued = false
local function SaveConfig()
    if SaveQueued or not writefile then return end
    SaveQueued = true
    task.delay(0.6, function()
        SaveQueued = false
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode({
                theme = Config.theme,
                lang = Config.lang,
                lastQuote = Config.lastQuote,
                lastQuotes = Config.lastQuotes,
                options = Settings,
            }))
        end)
    end)
end

local StartThemeName = Config.theme or DefaultThemeName
Config.theme = StartThemeName

-- ==================== TRADUÇÕES ====================
local Strings = {
    en = {
        tab_info = "Information", tab_main = "Main", tab_esp = "ESP", tab_misc = "Misc",
        tab_config = "Settings", tab_themes = "Themes",
        sec_move = "Movement", sec_tp = "Teleport to player",
        noclip_t = "Noclip", noclip_d = "Walk through walls and objects.",
        camnoclip_t = "Cam Noclip", camnoclip_d = "The camera passes through walls instead of zooming in.",
        tp_select = "Select a player", tp_button = "Teleport", tp_none = "No other players",
        n_tp_ok = "Teleported to %s.", n_tp_fail = "Player not found or has no character.",
        n_tp_none = "Select a player first.",
        esp_box_t = "ESP Box", esp_box_d = "Box around the player, fitted to the avatar size.",
        esp_name_t = "ESP Name", esp_name_d = "Player name above the head.",
        esp_dist_t = "ESP Distance", esp_dist_d = "Distance to the player.",
        esp_unit_t = "Distance unit",
        esp_arrow_t = "ESP Arrow", esp_arrow_d = "RGB arrow above the head; the closer, the faster the RGB.",
        esp_out_t = "ESP Outline", esp_out_d = "Thin outline that follows the avatar shape.",
        esp_thin_t = "Outline thinness", esp_thin_d = "Higher = subtler, thinner outline.",
        fb_t = "Fullbright", fb_d = "Night vision: removes darkness and fog.",
        antisit_t = "Anti-Sit", antisit_d = "Prevents your character from sitting on seats.",
        rejoin_t = "Auto Rejoin", rejoin_d = "Reconnects you to the server automatically if your connection drops.",
        n_rejoin = "Connection lost. Trying to rejoin...",
        themes_p_c = "Tap a bar to apply the theme. The circle shows the minimize button.",
        n_theme_t = "Theme changed", n_theme_c = "Theme updated to: %s",
        n_partial_t = "Theme partially applied",
        n_partial_c = "Could not load all images for %s (.webp is not supported by Roblox).",
        cfg_p_t = "Auto-save",
        cfg_p_c = "All options (ESP, Misc, theme and language) are saved automatically and restored when you run the script again.",
        cfg_reset_t = "Restore defaults",
        cfg_reset_d = "Resets every option to default (Anti-Sit on) and the default theme.",
        n_cfg_t = "Settings", n_cfg_c = "Options restored to default.",
        lang_sec = "Language",
        dlg1_t = "Close daphne hub", dlg1_c = "Are you sure you want to delete the hub?",
        dlg_no = "No", dlg_yes = "Yes",
        dlg2_t = "Final confirmation",
        dlg2_c = "This will delete EVERYTHING and disable all features. Are you absolutely sure?",
        dlg_yes2 = "Yes, delete",
        info_p_t = "How it works",
        info_p_c = "This script automatically saves your theme, options and language. When you run it again, everything is restored.",
        info_players = "Players in server",
    },
    pt = {
        tab_info = "Informações", tab_main = "Principal", tab_esp = "ESP", tab_misc = "Diversos",
        tab_config = "Configurações", tab_themes = "Temas",
        sec_move = "Movimento", sec_tp = "Teleportar até jogador",
        noclip_t = "Noclip", noclip_d = "Atravesse paredes e objetos.",
        camnoclip_t = "Cam Noclip", camnoclip_d = "A câmera atravessa as paredes em vez de aproximar.",
        tp_select = "Selecione um jogador", tp_button = "Teleportar", tp_none = "Nenhum outro jogador",
        n_tp_ok = "Teleportado para %s.", n_tp_fail = "Jogador não encontrado ou sem personagem.",
        n_tp_none = "Selecione um jogador primeiro.",
        esp_box_t = "ESP Caixa", esp_box_d = "Caixa ao redor do jogador, ajustada ao tamanho do avatar.",
        esp_name_t = "ESP Nome", esp_name_d = "Nome do jogador acima da cabeça.",
        esp_dist_t = "ESP Distância", esp_dist_d = "Distância até o jogador.",
        esp_unit_t = "Unidade da distância",
        esp_arrow_t = "ESP Seta", esp_arrow_d = "Seta RGB acima da cabeça; quanto mais perto, mais rápido o RGB.",
        esp_out_t = "ESP Contorno", esp_out_d = "Contorno fino que segue o formato do avatar.",
        esp_thin_t = "Finura do contorno", esp_thin_d = "Maior = contorno mais sutil e fino.",
        fb_t = "Fullbright", fb_d = "Visão noturna: remove a escuridão e a neblina.",
        antisit_t = "Anti-Sit", antisit_d = "Impede que o seu personagem sente em assentos.",
        rejoin_t = "Auto Rejoin", rejoin_d = "Reconecta você ao servidor automaticamente se a sua internet cair.",
        n_rejoin = "Conexão perdida. Tentando reconectar...",
        themes_p_c = "Toque em uma barra para aplicar o tema. A bolinha mostra o botão de minimizar.",
        n_theme_t = "Tema alterado", n_theme_c = "Tema atualizado para: %s",
        n_partial_t = "Tema parcialmente aplicado",
        n_partial_c = "Não foi possível carregar todas as imagens de %s (formato .webp não é suportado pelo Roblox).",
        cfg_p_t = "Salvamento automático",
        cfg_p_c = "Todas as opções (ESP, Misc, tema e idioma) são salvas automaticamente e restauradas ao executar de novo.",
        cfg_reset_t = "Restaurar padrões",
        cfg_reset_d = "Volta todas as opções ao padrão (Anti-Sit ligado) e o tema padrão.",
        n_cfg_t = "Configurações", n_cfg_c = "Opções restauradas para o padrão.",
        lang_sec = "Idioma",
        dlg1_t = "Fechar daphne hub", dlg1_c = "Tem certeza que deseja apagar o hub?",
        dlg_no = "Não", dlg_yes = "Sim",
        dlg2_t = "Confirmação final",
        dlg2_c = "Isso vai apagar TUDO e desativar todas as funções. Tem certeza absoluta?",
        dlg_yes2 = "Sim, apagar",
        info_p_t = "Como funciona",
        info_p_c = "Este script salva automaticamente o seu tema, opções e idioma. Ao executar de novo, tudo é restaurado.",
        info_players = "Jogadores no servidor",
    },
    es = {
        tab_info = "Información", tab_main = "Principal", tab_esp = "ESP", tab_misc = "Varios",
        tab_config = "Ajustes", tab_themes = "Temas",
        sec_move = "Movimiento", sec_tp = "Teletransportar a un jugador",
        noclip_t = "Noclip", noclip_d = "Atraviesa paredes y objetos.",
        camnoclip_t = "Cam Noclip", camnoclip_d = "La cámara atraviesa las paredes en lugar de acercarse.",
        tp_select = "Selecciona un jugador", tp_button = "Teletransportar", tp_none = "No hay otros jugadores",
        n_tp_ok = "Teletransportado a %s.", n_tp_fail = "Jugador no encontrado o sin personaje.",
        n_tp_none = "Selecciona un jugador primero.",
        esp_box_t = "ESP Caja", esp_box_d = "Caja alrededor del jugador, ajustada al tamaño del avatar.",
        esp_name_t = "ESP Nombre", esp_name_d = "Nombre del jugador sobre la cabeza.",
        esp_dist_t = "ESP Distancia", esp_dist_d = "Distancia al jugador.",
        esp_unit_t = "Unidad de distancia",
        esp_arrow_t = "ESP Flecha", esp_arrow_d = "Flecha RGB sobre la cabeza; cuanto más cerca, más rápido el RGB.",
        esp_out_t = "ESP Contorno", esp_out_d = "Contorno fino que sigue la forma del avatar.",
        esp_thin_t = "Finura del contorno", esp_thin_d = "Mayor = contorno más sutil y fino.",
        fb_t = "Fullbright", fb_d = "Visión nocturna: elimina la oscuridad y la niebla.",
        antisit_t = "Anti-Sit", antisit_d = "Evita que tu personaje se siente en asientos.",
        rejoin_t = "Auto Rejoin", rejoin_d = "Te reconecta al servidor automáticamente si se cae tu internet.",
        n_rejoin = "Conexión perdida. Intentando reconectar...",
        themes_p_c = "Toca una barra para aplicar el tema. El círculo muestra el botón de minimizar.",
        n_theme_t = "Tema cambiado", n_theme_c = "Tema actualizado a: %s",
        n_partial_t = "Tema aplicado parcialmente",
        n_partial_c = "No se pudieron cargar todas las imágenes de %s (Roblox no admite .webp).",
        cfg_p_t = "Guardado automático",
        cfg_p_c = "Todas las opciones (ESP, Misc, tema e idioma) se guardan automáticamente y se restauran al ejecutar de nuevo.",
        cfg_reset_t = "Restaurar valores",
        cfg_reset_d = "Devuelve todas las opciones a su valor predeterminado (Anti-Sit activado) y el tema predeterminado.",
        n_cfg_t = "Ajustes", n_cfg_c = "Opciones restauradas a los valores predeterminados.",
        lang_sec = "Idioma",
        dlg1_t = "Cerrar daphne hub", dlg1_c = "¿Seguro que quieres borrar el hub?",
        dlg_no = "No", dlg_yes = "Sí",
        dlg2_t = "Confirmación final",
        dlg2_c = "Esto borrará TODO y desactivará todas las funciones. ¿Estás completamente seguro?",
        dlg_yes2 = "Sí, borrar",
        info_p_t = "Cómo funciona",
        info_p_c = "Este script guarda automáticamente tu tema, opciones e idioma. Al ejecutarlo de nuevo, todo se restaura.",
        info_players = "Jugadores en el servidor",
    },
    ru = {
        tab_info = "Информация", tab_main = "Главная", tab_esp = "ESP", tab_misc = "Разное",
        tab_config = "Настройки", tab_themes = "Темы",
        sec_move = "Движение", sec_tp = "Телепорт к игроку",
        noclip_t = "Noclip", noclip_d = "Проходите сквозь стены и объекты.",
        camnoclip_t = "Cam Noclip", camnoclip_d = "Камера проходит сквозь стены, а не приближается.",
        tp_select = "Выберите игрока", tp_button = "Телепорт", tp_none = "Других игроков нет",
        n_tp_ok = "Телепорт к %s выполнен.", n_tp_fail = "Игрок не найден или у него нет персонажа.",
        n_tp_none = "Сначала выберите игрока.",
        esp_box_t = "ESP Рамка", esp_box_d = "Рамка вокруг игрока по размеру аватара.",
        esp_name_t = "ESP Имя", esp_name_d = "Имя игрока над головой.",
        esp_dist_t = "ESP Дистанция", esp_dist_d = "Расстояние до игрока.",
        esp_unit_t = "Единица расстояния",
        esp_arrow_t = "ESP Стрелка", esp_arrow_d = "RGB-стрелка над головой; чем ближе, тем быстрее меняется цвет.",
        esp_out_t = "ESP Контур", esp_out_d = "Тонкий контур по форме аватара.",
        esp_thin_t = "Тонкость контура", esp_thin_d = "Больше = тоньше и незаметнее.",
        fb_t = "Fullbright", fb_d = "Ночное зрение: убирает темноту и туман.",
        antisit_t = "Anti-Sit", antisit_d = "Не даёт вашему персонажу садиться на сиденья.",
        rejoin_t = "Auto Rejoin", rejoin_d = "Автоматически возвращает вас на сервер при потере соединения.",
        n_rejoin = "Соединение потеряно. Пытаюсь переподключиться...",
        themes_p_c = "Нажмите на полосу, чтобы применить тему. Кружок показывает кнопку сворачивания.",
        n_theme_t = "Тема изменена", n_theme_c = "Тема обновлена: %s",
        n_partial_t = "Тема применена частично",
        n_partial_c = "Не удалось загрузить все изображения для %s (Roblox не поддерживает .webp).",
        cfg_p_t = "Автосохранение",
        cfg_p_c = "Все параметры (ESP, Разное, тема и язык) сохраняются автоматически и восстанавливаются при повторном запуске.",
        cfg_reset_t = "Сбросить настройки",
        cfg_reset_d = "Возвращает все параметры по умолчанию (Anti-Sit включён) и тему по умолчанию.",
        n_cfg_t = "Настройки", n_cfg_c = "Параметры сброшены по умолчанию.",
        lang_sec = "Язык",
        dlg1_t = "Закрыть daphne hub", dlg1_c = "Вы уверены, что хотите удалить хаб?",
        dlg_no = "Нет", dlg_yes = "Да",
        dlg2_t = "Окончательное подтверждение",
        dlg2_c = "Это удалит ВСЁ и отключит все функции. Вы абсолютно уверены?",
        dlg_yes2 = "Да, удалить",
        info_p_t = "Как это работает",
        info_p_c = "Скрипт автоматически сохраняет вашу тему, параметры и язык. При повторном запуске всё восстанавливается.",
        info_players = "Игроков на сервере",
    },
}

local Lang = Config.lang
if not Strings[Lang] then Lang = "en"; Config.lang = "en" end

local function T(key, ...)
    local s = (Strings[Lang] and Strings[Lang][key]) or Strings.en[key] or key
    if select("#", ...) > 0 then
        local okF, r = pcall(string.format, s, ...)
        if okF then return r end
    end
    return s
end

local RevMap = {}
do
    local ambiguous = {}
    for _, code in ipairs(LangOrder) do
        for key, txt in pairs(Strings[code]) do
            if RevMap[txt] and RevMap[txt] ~= key then ambiguous[txt] = true end
            RevMap[txt] = key
        end
    end
    for txt in pairs(ambiguous) do RevMap[txt] = nil end
end

local UIRefreshers = {}

-- ==================== FRASES POR PERSONAGEM E IDIOMA ====================
local ThemeQuotes = {
    en = {
        Daphne = {
            "I'm hungry... so hungry I could eat the whole world.",
            "Gluttony is the sin that never gets full.",
            "Eat or be eaten, that's all there is.",
            "You smell so delicious, Subaru.",
            "Even after devouring everything, my stomach is still empty.",
            "Hunger is the one truth in this world.",
            "Just a little taste... would that really be so bad?",
            "Everything alive is just a meal that hasn't been eaten yet.",
            "An empty stomach is the cruelest thing there is.",
            "I want to eat, I want to eat, I want to eat...",
            "The White Whale is so big... enough to feed everyone.",
            "Let me taste you, just once.",
        },
        Echidna = {
            "I am the Witch of Greed, Echidna.",
            "Shall we have tea together, Subaru?",
            "My thirst for knowledge can never be quenched.",
            "Curiosity is my one and only desire.",
            "Let's make a deal, you and I.",
            "A world without mysteries would be a boring world.",
            "Come, sit. The tea is getting cold.",
            "I want to know everything there is to know.",
            "You are fascinating, Natsuki Subaru.",
            "Prove to me that your wish is genuine.",
            "Knowledge is the only thing that truly satisfies me.",
            "Our little tea party is just beginning.",
        },
        Rem = {
            "Let's start from zero, Subaru-kun.",
            "Rem will always believe in you, Subaru-kun.",
            "Subaru-kun is Rem's hero.",
            "I love you, Subaru-kun. Every part of you.",
            "You don't have to carry everything alone.",
            "Rem is just a maid, but Rem is on your side.",
            "Even if the whole world turns against you, Rem will stay by your side.",
            "Thank you for saving Rem, Subaru-kun.",
            "Please keep smiling, Subaru-kun.",
            "No matter how long it takes, Rem will wait.",
            "Subaru-kun, you are wonderful just as you are.",
            "Rem has always been by your side.",
        },
        ["Emília"] = {
            "My name is Emilia. Just Emilia.",
            "I will become the queen and change this kingdom.",
            "I won't give up, no matter what.",
            "Thank you for staying with me, Subaru.",
            "Puck, I'm here.",
            "I want a future where no one has to cry.",
            "I'll do my best!",
            "Even if they call me a witch, I'll hold my head high.",
            "I want to get to know you better, Subaru.",
            "I'll never forget your kindness.",
            "I want to protect the people I love.",
            "Thank you for believing in me.",
        },
        Shaula = {
            "Shaula has waited four hundred years for this!",
            "Leave it to Shaula!",
            "Shaula only wants Master Echidna to be happy.",
            "Don't underestimate Shaula!",
            "Master, Shaula is right here!",
            "Four hundred years is a really long time, you know.",
            "Shaula never gave up on Master.",
            "Relax, Shaula will take care of everything.",
            "Nothing matters more to Shaula than Master.",
            "Shaula keeps her promises, got it?",
            "Shaula will see it through to the end!",
            "Shaula is the most loyal servant of all!",
        },
        Beatrice = {
            "I am Beatrice, keeper of the Forbidden Library.",
            "Betty has waited four hundred years for you.",
            "Take Betty's hand, Subaru.",
            "Don't treat Betty like a child, Subaru!",
            "Betty is Subaru's contracted spirit, isn't she?",
            "Betty will stay by your side, no matter what.",
            "Betty doesn't want to be alone anymore.",
            "Betty trusts you, Subaru.",
            "Fool... but that's exactly why Betty chose you.",
            "Betty wants to leave this library with you.",
            "Even small, Betty is a great spirit.",
            "This library kept Betty for four hundred years.",
        },
    },
    pt = {
        Daphne = {
            "Se você não pode comer, você morre, não é?",
            "Na vida, a Gula é o desejo mais importante de todos.",
            "Comer ou ser comido é a única relação neste mundo.",
            "Eu fico com mais fome apenas por existir...",
            "Subaruun tem um cheiro tão bom... Daphne quer devorar você.",
            "Fome... uma fome que nenhum banquete preenche.",
            "Daphne quer comer, Daphne quer comer, Daphne quer comer...",
            "Tudo o que existe neste mundo é uma refeição em potencial.",
            "Mesmo depois de comer o mundo inteiro, Daphne ainda terá fome.",
            "Um estômago vazio é a coisa mais cruel que existe.",
            "A Baleia Branca é enorme... muitas pessoas poderiam se fartar com ela.",
            "Você tem cara de saboroso, sabia?",
        },
        Echidna = {
            "Eu sou a Bruxa da Ganância, Echidna.",
            "Venha, sente-se e tome um chá comigo.",
            "Minha sede de conhecimento nunca será saciada.",
            "A curiosidade é o meu único desejo.",
            "Que tal fazermos um trato, Subaru?",
            "Um mundo sem mistérios seria um mundo sem sentido.",
            "O chá esfriou, mas a conversa está só começando.",
            "Quero conhecer tudo o que existe neste mundo.",
            "Você é fascinante, Natsuki Subaru.",
            "Prove que o seu desejo é verdadeiro.",
            "O conhecimento é a única coisa que realmente me satisfaz.",
            "Esta é a nossa pequena festa do chá, Subaru.",
        },
        Rem = {
            "Vamos recomeçar do zero, Subaru-kun.",
            "Rem sempre acreditará em você, Subaru-kun.",
            "Subaru-kun é o herói de Rem.",
            "Eu amo você, Subaru-kun. Tudo em você.",
            "Você não precisa carregar tudo sozinho.",
            "Rem é apenas uma serva, mas está do seu lado.",
            "Mesmo que o mundo inteiro te abandone, Rem ficará ao seu lado.",
            "Obrigada por ter salvado Rem, Subaru-kun.",
            "Por favor, continue sorrindo, Subaru-kun.",
            "Rem esperará, não importa quanto tempo leve.",
            "Subaru-kun, você é maravilhoso do jeito que é.",
            "Rem sempre esteve ao seu lado.",
        },
        ["Emília"] = {
            "Meu nome é Emília. Apenas Emília.",
            "Eu vou me tornar rainha e mudar este reino.",
            "Eu não vou desistir, aconteça o que acontecer.",
            "Obrigada por ficar comigo, Subaru.",
            "Puck, estou aqui.",
            "Eu quero um futuro em que ninguém precise chorar.",
            "Vou fazer o meu melhor!",
            "Mesmo que me chamem de bruxa, eu manterei a cabeça erguida.",
            "Eu quero conhecer você melhor, Subaru.",
            "Eu nunca vou esquecer a sua bondade.",
            "Eu quero proteger as pessoas que amo.",
            "Obrigada por acreditar em mim.",
        },
        Shaula = {
            "Shaula esperou quatrocentos anos por este momento!",
            "Pode deixar com a Shaula!",
            "Shaula só quer ver a Mestra Echidna feliz.",
            "Não subestime a Shaula!",
            "Mestra, Shaula está aqui!",
            "Quatrocentos anos é muito tempo, sabia?",
            "Shaula nunca desistiu da Mestra.",
            "Fique tranquilo, Shaula cuida de tudo.",
            "Nada é mais importante para Shaula do que a Mestra.",
            "Shaula cumpre o que promete, entendeu?",
            "Shaula vai até o fim!",
            "Shaula é a mais leal das servas!",
        },
        Beatrice = {
            "Eu sou Beatrice, guardiã da Biblioteca Proibida.",
            "Betty esperou quatrocentos anos por você.",
            "Pegue a mão de Betty, Subaru.",
            "Não trate Betty como criança, Subaru!",
            "Betty é o espírito contratado de Subaru, não é?",
            "Betty ficará ao seu lado, aconteça o que acontecer.",
            "Betty não quer mais ficar sozinha.",
            "Betty confia em você, Subaru.",
            "Tolo... mas é exatamente por isso que Betty te escolheu.",
            "Betty quer sair desta biblioteca com você.",
            "Mesmo pequena, Betty é uma grande espírito.",
            "Esta biblioteca guardou Betty por quatrocentos anos.",
        },
    },
    es = {
        Daphne = {
            "Tengo hambre... tanta que me comería el mundo entero.",
            "La Gula es el pecado que nunca se sacia.",
            "Comer o ser comido, eso es todo lo que hay.",
            "Hueles tan delicioso, Subaru.",
            "Aun después de devorarlo todo, mi estómago seguirá vacío.",
            "El hambre es la única verdad de este mundo.",
            "Solo un bocado... ¿tan malo sería?",
            "Todo lo que vive es una comida que aún no se ha comido.",
            "Un estómago vacío es lo más cruel que existe.",
            "Quiero comer, quiero comer, quiero comer...",
            "La Ballena Blanca es enorme... alcanzaría para alimentar a todos.",
            "Déjame probarte, solo una vez.",
        },
        Echidna = {
            "Soy la Bruja de la Avaricia, Echidna.",
            "¿Tomamos el té juntos, Subaru?",
            "Mi sed de conocimiento jamás se saciará.",
            "La curiosidad es mi único deseo.",
            "Hagamos un trato, tú y yo.",
            "Un mundo sin misterios sería un mundo aburrido.",
            "Ven, siéntate. El té se está enfriando.",
            "Quiero saberlo todo.",
            "Eres fascinante, Natsuki Subaru.",
            "Demuéstrame que tu deseo es sincero.",
            "El conocimiento es lo único que de verdad me satisface.",
            "Nuestra pequeña fiesta del té apenas comienza.",
        },
        Rem = {
            "Empecemos desde cero, Subaru-kun.",
            "Rem siempre creerá en ti, Subaru-kun.",
            "Subaru-kun es el héroe de Rem.",
            "Te quiero, Subaru-kun. Todo de ti.",
            "No tienes que cargar con todo tú solo.",
            "Rem es solo una sirvienta, pero está de tu lado.",
            "Aunque el mundo entero te dé la espalda, Rem se quedará contigo.",
            "Gracias por salvar a Rem, Subaru-kun.",
            "Por favor, sigue sonriendo, Subaru-kun.",
            "Por mucho que tarde, Rem esperará.",
            "Subaru-kun, eres maravilloso tal como eres.",
            "Rem siempre ha estado a tu lado.",
        },
        ["Emília"] = {
            "Mi nombre es Emilia. Solo Emilia.",
            "Me convertiré en reina y cambiaré este reino.",
            "No me rendiré, pase lo que pase.",
            "Gracias por quedarte conmigo, Subaru.",
            "Puck, estoy aquí.",
            "Quiero un futuro en el que nadie tenga que llorar.",
            "¡Haré lo mejor que pueda!",
            "Aunque me llamen bruja, mantendré la cabeza en alto.",
            "Quiero conocerte mejor, Subaru.",
            "Nunca olvidaré tu bondad.",
            "Quiero proteger a las personas que amo.",
            "Gracias por creer en mí.",
        },
        Shaula = {
            "¡Shaula esperó cuatrocientos años por esto!",
            "¡Déjaselo a Shaula!",
            "Shaula solo quiere que la Maestra Echidna sea feliz.",
            "¡No subestimes a Shaula!",
            "¡Maestra, Shaula está aquí!",
            "Cuatrocientos años es mucho tiempo, ¿sabes?",
            "Shaula nunca se rindió con la Maestra.",
            "Tranquilo, Shaula se encarga de todo.",
            "Nada es más importante para Shaula que la Maestra.",
            "Shaula cumple sus promesas, ¿entendido?",
            "¡Shaula llegará hasta el final!",
            "¡Shaula es la más leal de las sirvientas!",
        },
        Beatrice = {
            "Soy Beatrice, guardiana de la Biblioteca Prohibida.",
            "Betty esperó cuatrocientos años por ti.",
            "Toma la mano de Betty, Subaru.",
            "¡No trates a Betty como a una niña, Subaru!",
            "Betty es el espíritu contratado de Subaru, ¿verdad?",
            "Betty se quedará a tu lado pase lo que pase.",
            "Betty ya no quiere estar sola.",
            "Betty confía en ti, Subaru.",
            "Tonto... pero por eso mismo Betty te eligió.",
            "Betty quiere salir de esta biblioteca contigo.",
            "Aunque pequeña, Betty es un gran espíritu.",
            "Esta biblioteca guardó a Betty cuatrocientos años.",
        },
    },
    ru = {
        Daphne = {
            "Я голодна... так голодна, что съела бы весь мир.",
            "Чревоугодие — грех, который никогда не насыщается.",
            "Съесть или быть съеденным — вот и всё, что есть.",
            "Ты так вкусно пахнешь, Субару.",
            "Даже сожрав всё на свете, мой желудок останется пустым.",
            "Голод — единственная правда этого мира.",
            "Всего один кусочек... разве это так плохо?",
            "Всё живое — лишь трапеза, которую ещё не съели.",
            "Пустой желудок — самая жестокая вещь на свете.",
            "Хочу есть, хочу есть, хочу есть...",
            "Белый Кит такой огромный... хватит накормить всех.",
            "Дай мне попробовать тебя, всего раз.",
        },
        Echidna = {
            "Я — Ведьма Жадности, Ехидна.",
            "Выпьем чаю вместе, Субару?",
            "Моя жажда знаний никогда не утолится.",
            "Любопытство — моё единственное желание.",
            "Давай заключим сделку, ты и я.",
            "Мир без тайн был бы скучным миром.",
            "Садись. Чай стынет.",
            "Я хочу знать всё, что можно знать.",
            "Ты восхитителен, Нацуки Субару.",
            "Докажи, что твоё желание искренне.",
            "Только знание меня по-настоящему насыщает.",
            "Наше маленькое чаепитие только начинается.",
        },
        Rem = {
            "Начнём с нуля, Субару-кун.",
            "Рем всегда будет верить в тебя, Субару-кун.",
            "Субару-кун — герой Рем.",
            "Я люблю тебя, Субару-кун. Всего тебя.",
            "Тебе не нужно нести всё в одиночку.",
            "Рем всего лишь служанка, но она на твоей стороне.",
            "Даже если весь мир отвернётся, Рем останется рядом.",
            "Спасибо, что спас Рем, Субару-кун.",
            "Пожалуйста, улыбайся, Субару-кун.",
            "Сколько бы ни прошло времени, Рем будет ждать.",
            "Субару-кун, ты прекрасен таким, какой есть.",
            "Рем всегда была рядом с тобой.",
        },
        ["Emília"] = {
            "Меня зовут Эмилия. Просто Эмилия.",
            "Я стану королевой и изменю это королевство.",
            "Я не сдамся, что бы ни случилось.",
            "Спасибо, что остаёшься со мной, Субару.",
            "Пак, я здесь.",
            "Я хочу будущего, в котором никому не придётся плакать.",
            "Я постараюсь изо всех сил!",
            "Пусть зовут ведьмой — я не склоню головы.",
            "Я хочу узнать тебя получше, Субару.",
            "Я никогда не забуду твоей доброты.",
            "Я хочу защитить тех, кого люблю.",
            "Спасибо, что веришь в меня.",
        },
        Shaula = {
            "Шаула ждала этого четыреста лет!",
            "Предоставь это Шауле!",
            "Шаула хочет лишь, чтобы Госпожа Ехидна была счастлива.",
            "Не недооценивай Шаулу!",
            "Госпожа, Шаула здесь!",
            "Четыреста лет — это очень долго, знаешь ли.",
            "Шаула никогда не сдавалась ради Госпожи.",
            "Расслабься, Шаула обо всём позаботится.",
            "Для Шаулы нет ничего важнее Госпожи.",
            "Шаула держит свои обещания, ясно?",
            "Шаула дойдёт до конца!",
            "Шаула — самая верная из слуг!",
        },
        Beatrice = {
            "Я — Беатриче, хранительница Запретной библиотеки.",
            "Бетти ждала тебя четыреста лет.",
            "Возьми Бетти за руку, Субару.",
            "Не обращайся с Бетти как с ребёнком, Субару!",
            "Бетти — контрактный дух Субару, не так ли?",
            "Бетти будет рядом, что бы ни случилось.",
            "Бетти больше не хочет быть одна.",
            "Бетти доверяет тебе, Субару.",
            "Глупец... но именно поэтому Бетти тебя выбрала.",
            "Бетти хочет уйти из этой библиотеки вместе с тобой.",
            "Пусть Бетти и мала, она великий дух.",
            "Эта библиотека хранила Бетти четыреста лет.",
        },
    },
}

-- Nunca repete a mesma frase em execuções seguidas; na sessão só repete depois de esgotar a lista.
local SessionSeen = {}

local function RandomQuote(themeName)
    local byLang = ThemeQuotes[Lang] or ThemeQuotes.en
    local list = byLang[themeName] or ThemeQuotes.en[themeName]
    if not list or #list == 0 then return nil end

    local key = Lang .. "|" .. themeName
    local seen = SessionSeen[key]
    if not seen then seen = {}; SessionSeen[key] = seen end

    local lastTheme = Config.lastQuotes[key]
    local lastAny = Config.lastQuote

    local function build()
        local pool = {}
        for _, q in ipairs(list) do
            if q ~= lastTheme and q ~= lastAny and not seen[q] then pool[#pool + 1] = q end
        end
        return pool
    end

    local pool = build()
    if #pool == 0 then table.clear(seen); pool = build() end
    if #pool == 0 then
        for _, q in ipairs(list) do
            if q ~= lastTheme then pool[#pool + 1] = q end
        end
    end
    if #pool == 0 then pool = list end

    local quote = pool[math.random(1, #pool)]
    seen[quote] = true
    Config.lastQuotes[key] = quote
    Config.lastQuote = quote
    SaveConfig()
    return quote
end

-- ==================== TEMA FLUENT ====================
local function Hex(c) return "#" .. c:ToHex() end
local function Shade(c, k) return c:Lerp(Color3.new(0, 0, 0), k) end
local function Tint(c, k) return c:Lerp(Color3.new(1, 1, 1), k) end

local function MakeTheme(name, background, accent)
    local t = {
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

    if accent then
        local a = accent
        t.Accent = Hex(a)
        t.AcrylicMain = Hex(Shade(a, 0.9))
        t.AcrylicBorder = Hex(Shade(a, 0.82))
        t.AcrylicGradient = ColorSequence.new(Shade(a, 0.86), Shade(a, 0.93))
        t.TitleBarLine = Hex(a)
        t.Tab = Hex(Shade(a, 0.78))
        t.Element = Hex(Shade(a, 0.8))
        t.ElementBorder = Hex(Shade(a, 0.55))
        t.InElementBorder = Hex(Shade(a, 0.3))
        t.ToggleSlider = Hex(Shade(a, 0.15))
        t.ToggleToggled = Hex(Tint(a, 0.25))
        t.SliderRail = Hex(Shade(a, 0.7))
        t.CheckboxUnchecked = Hex(Shade(a, 0.55))
        t.CheckboxChecked = Hex(Shade(a, 0.15))
        t.CheckboxCheck = Hex(Tint(a, 0.85))
        t.ProgressBarRail = Hex(Shade(a, 0.75))
        t.ProgressBarFill = Hex(a)
        t.DropdownFrame = Hex(Shade(a, 0.5))
        t.DropdownHolder = Hex(Shade(a, 0.45))
        t.DropdownBorder = Hex(Shade(a, 0.6))
        t.DropdownOption = Hex(Shade(a, 0.38))
        t.Keybind = Hex(Shade(a, 0.3))
        t.Input = Hex(Shade(a, 0.5))
        t.InputFocused = Hex(Shade(a, 0.3))
        t.InputIndicator = Hex(Tint(a, 0.2))
        t.Dialog = Hex(Shade(a, 0.45))
        t.DialogHolder = Hex(Shade(a, 0.35))
        t.DialogHolderLine = Hex(Shade(a, 0.5))
        t.DialogButton = Hex(Shade(a, 0.25))
        t.DialogButtonBorder = Hex(Shade(a, 0.6))
        t.DialogBorder = Hex(Shade(a, 0.4))
        t.DialogInput = Hex(Shade(a, 0.5))
        t.DialogInputLine = Hex(Shade(a, 0.3))
        t.Hover = Hex(a)
        t.Text = Hex(Tint(a, 0.92))
        t.SubText = Hex(Tint(a, 0.55))
    end

    return t
end

local CurrentThemeName = StartThemeName
local CurrentTheme = ActiveThemes[CurrentThemeName]
local CurrentWallpaperAsset = LoadImage(CurrentTheme.Wallpaper, CurrentTheme.WallpaperFile)
local CurrentButtonAsset = LoadImage(CurrentTheme.Button, CurrentTheme.ButtonFile)

local RegisteredThemes = {}
local function ThemeKey(themeName) return "DaphneTheme_" .. themeName end

local function RegisterTheme(themeName, asset)
    local key = ThemeKey(themeName)
    if not RegisteredThemes[key] then
        local data = ActiveThemes[themeName]
        Fluent:AddTheme(MakeTheme(key, asset, data and data.Accent or nil))
        RegisteredThemes[key] = true
    end
    return key
end

local StartThemeKey = RegisterTheme(CurrentThemeName, CurrentWallpaperAsset)

local Window = Fluent:CreateWindow({
    Title = "daphne hub", SubTitle = "by Kai", TabWidth = 140, Size = GetIdealSize(),
    Acrylic = true, Theme = StartThemeKey, MinimizeKey = Enum.KeyCode.LeftControl
})

local Active, Connections, MinimizerGui, MinimizerBtnObj, MinimizerOutline = true, {}, nil, nil, nil
local ShuttingDown = false
local Cleanups = {}

local function Track(conn)
    if conn then table.insert(Connections, conn) end
    return conn
end

local function OnShutdown(fn) table.insert(Cleanups, fn) end

-- ==================== FECHAMENTO TOTAL ====================
local function ShutdownEverything()
    if ShuttingDown then return end
    ShuttingDown = true
    Active = false
    genv._DaphneHubLoaded = false

    pcall(function() if MinimizerGui then MinimizerGui:Destroy(); MinimizerGui = nil end end)
    MinimizerBtnObj, MinimizerOutline = nil, nil

    for _, fn in ipairs(Cleanups) do pcall(fn) end
    Cleanups = {}

    for _, conn in ipairs(Connections) do
        pcall(function()
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end)
    end
    Connections = {}

    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
    pcall(function() if origFluentDestroy then origFluentDestroy(Fluent) end end)

    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            local n = string.lower(gui.Name)
            if n:find("fluent") or n:find("daphne") then gui:Destroy() end
        end
    end)
end

pcall(function() Fluent.Destroy = function() ShutdownEverything() end end)

-- ==================== NOTIFICAÇÕES NO CANTO SUPERIOR DIREITO ====================
local NotifHolder = nil

local function EnsureNotificationsTopRight()
    if NotifHolder and NotifHolder.Parent then return end
    pcall(function()
        local roots = {}
        local gui = Window and Window.Root and Window.Root:FindFirstAncestorOfClass("ScreenGui")
        if gui then table.insert(roots, gui) end
        if Fluent.GUI then table.insert(roots, Fluent.GUI) end

        for _, root in ipairs(roots) do
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("Frame") and d.AnchorPoint == Vector2.new(1, 1) then
                    local layout = d:FindFirstChildOfClass("UIListLayout")
                    if layout and layout.VerticalAlignment == Enum.VerticalAlignment.Bottom then
                        d.AnchorPoint = Vector2.new(1, 0)
                        d.Position = UDim2.new(d.Position.X.Scale, d.Position.X.Offset, 0, 30)
                        d.Size = UDim2.new(d.Size.X.Scale, d.Size.X.Offset, 1, -60)
                        layout.VerticalAlignment = Enum.VerticalAlignment.Top
                        NotifHolder = d
                        return
                    end
                end
            end
        end
    end)
end

local function Notify(cfg)
    if ShuttingDown then return end
    EnsureNotificationsTopRight()
    pcall(function() Fluent:Notify(cfg) end)
    -- só reprocura se o holder ainda não foi encontrado (evita varrer a GUI toda vez)
    if not (NotifHolder and NotifHolder.Parent) then EnsureNotificationsTopRight() end
end

task.defer(EnsureNotificationsTopRight)

-- ==================== WALLPAPER ====================
local ThemeCounter = 0
local WallpaperTargets = nil

local function StyleWallpaper(obj)
    pcall(function()
        obj.ScaleType = Enum.ScaleType.Crop
        obj.ResampleMode = Enum.ResamplerMode.Default
        obj.ImageTransparency = BG_TRANSPARENCY
    end)
end

local function ApplyWallpaper(asset)
    if not asset then return false end

    if WallpaperTargets then
        local stillValid = false
        for _, obj in ipairs(WallpaperTargets) do
            if obj and obj.Parent then
                obj.Image = asset
                StyleWallpaper(obj)
                stillValid = true
            end
        end
        if stillValid then return true end
        WallpaperTargets = nil
    end

    local found = {}

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

    if #found == 0 then
        pcall(function()
            local root = Window.Root
            if not root then return end
            for _, key in ipairs({ "wallpaper", "background" }) do
                for _, d in ipairs(root:GetDescendants()) do
                    if d:IsA("ImageLabel") and string.lower(d.Name):find(key, 1, true) then
                        table.insert(found, d)
                    end
                end
                if #found > 0 then return end
            end
        end)
    end

    if #found > 0 then
        for _, obj in ipairs(found) do
            pcall(function() obj.Image = asset end)
            StyleWallpaper(obj)
        end
        WallpaperTargets = found
        return true
    end

    local applied = false
    pcall(function()
        ThemeCounter += 1
        local newName = "DaphneFallback_" .. ThemeCounter
        Fluent:AddTheme(MakeTheme(newName, asset, CurrentTheme and CurrentTheme.Accent or nil))
        Fluent:SetTheme(newName)
        applied = true
    end)
    return applied
end

task.defer(function()
    if Active and CurrentWallpaperAsset then ApplyWallpaper(CurrentWallpaperAsset) end
end)

-- ==================== BOTÃO MINIMIZAR ====================
do
    MinimizerGui = Instance.new("ScreenGui")
    MinimizerGui.Name = "DaphneMinimizer"
    MinimizerGui.ResetOnSpawn = false
    MinimizerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() MinimizerGui.Parent = CoreGui end)
    if not MinimizerGui.Parent then MinimizerGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    MinimizerBtnObj = Instance.new("ImageButton")
    MinimizerBtnObj.Name = "MinBtn"
    MinimizerBtnObj.Size = UDim2.fromOffset(52, 52)
    MinimizerBtnObj.Position = UDim2.new(0, 20, 0.5, -26)
    MinimizerBtnObj.BackgroundTransparency = 1
    MinimizerBtnObj.BorderSizePixel = 0
    MinimizerBtnObj.AutoButtonColor = false
    MinimizerBtnObj.Image = CurrentButtonAsset or ""
    MinimizerBtnObj.ScaleType = Enum.ScaleType.Crop
    MinimizerBtnObj.ResampleMode = Enum.ResamplerMode.Default
    MinimizerBtnObj.Parent = MinimizerGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = MinimizerBtnObj

    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = MinimizerBtnObj

    MinimizerOutline = Instance.new("UIStroke")
    MinimizerOutline.Name = "DaphneOutline"
    MinimizerOutline.Color = CurrentTheme.BorderColor
    MinimizerOutline.Thickness = 1.5
    MinimizerOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MinimizerOutline.LineJoinMode = Enum.LineJoinMode.Round
    MinimizerOutline.Parent = MinimizerBtnObj

    local function tweenScale(target)
        pcall(function()
            TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = target }):Play()
        end)
    end

    Track(MinimizerBtnObj.MouseEnter:Connect(function() tweenScale(1.1) end))
    Track(MinimizerBtnObj.MouseLeave:Connect(function() tweenScale(1) end))

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
        if not dragging or not MinimizerBtnObj then return end
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
                if Window.Root then Window.Root.Visible = not Window.Root.Visible end
            end)
        end
    end))
end

-- ==================== FECHAR (X da GUI: 2 confirmações) ====================
local origDialog = Window.Dialog
local CloseDialogOpen = false

local function AskDeleteHub()
    if not Active or ShuttingDown or not Window or CloseDialogOpen then return end
    CloseDialogOpen = true

    origDialog(Window, {
        Title = T("dlg1_t"),
        Content = T("dlg1_c"),
        Buttons = {
            { Title = T("dlg_no"), Callback = function() CloseDialogOpen = false end },
            { Title = T("dlg_yes"), Callback = function()
                task.delay(0.3, function()
                    if not Active or ShuttingDown then return end
                    origDialog(Window, {
                        Title = T("dlg2_t"),
                        Content = T("dlg2_c"),
                        Buttons = {
                            { Title = T("dlg_no"), Callback = function() CloseDialogOpen = false end },
                            { Title = T("dlg_yes2"), Callback = function()
                                CloseDialogOpen = false
                                ShutdownEverything()
                            end }
                        }
                    })
                end)
            end }
        }
    })
end

local function IsFluentCloseDialog(cfg)
    if type(cfg) ~= "table" then return false end
    local t = string.lower(tostring(cfg.Title or ""))
    local c = string.lower(tostring(cfg.Content or ""))
    return t == "close" or c:find("unload", 1, true) ~= nil or c:find("close the", 1, true) ~= nil
end

if origDialog then
    pcall(function()
        Window.Dialog = function(self, cfg)
            if IsFluentCloseDialog(cfg) then return AskDeleteHub() end
            return origDialog(self, cfg)
        end
    end)
end

local function AddTabSafe(title, icons)
    if type(icons) ~= "table" then icons = { icons } end
    for _, icon in ipairs(icons) do
        local valid = true
        local okIcon, res = pcall(function() return Fluent:GetIcon(icon) end)
        if okIcon and (res == nil or res == "") then valid = false end
        if valid then
            local okTab, tab = pcall(function()
                return Window:AddTab({ Title = title, Icon = icon })
            end)
            if okTab and tab then return tab end
        end
    end
    return Window:AddTab({ Title = title, Icon = icons[1] })
end

-- ==================== ABAS ====================
local InfoTab = AddTabSafe(T("tab_info"), { "solar/info-circle-bold", "info" })
local Main = AddTabSafe(T("tab_main"), { "solar/home-bold", "home" })
local ESPTab = AddTabSafe(T("tab_esp"), { "solar/eye-bold", "eye" })
local MiscTab = AddTabSafe(T("tab_misc"), { "solar/widget-bold", "solar/magic-stick-3-bold", "layout-grid" })
local ConfigTab = AddTabSafe(T("tab_config"), { "solar/settings-bold", "solar/settings-minimalistic-bold", "settings" })
local ThemesTab = AddTabSafe(T("tab_themes"), { "solar/pallete-2-bold", "solar/palette-bold", "palette" })

local Toggles = {}
local Dropdowns = {}
local OutlineSlider = nil

local function AddSetting(tab, key, titleKey, descKey, onChange)
    Toggles[key] = tab:AddToggle("T_" .. key, {
        Title = T(titleKey),
        Description = T(descKey),
        Default = Settings[key],
        Callback = function(v)
            if not Active then return end
            Settings[key] = v
            SaveConfig()
            if onChange then onChange(v) end
        end
    })
end

-- ==================== HELPERS DE UI PERSONALIZADA ====================
local COL_TEXT = Color3.fromRGB(245, 245, 252)
local COL_SUB = Color3.fromRGB(185, 185, 202)
local COL_CARD = Color3.fromRGB(24, 24, 32)
local COL_LINE = Color3.fromRGB(130, 130, 150)

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = parent
    return c
end

-- Só dispara em toque/clique CURTO. Arrastar para rolar não dispara.
local function OnTap(btn, fn)
    local downPos = nil
    Track(btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            downPos = input.Position
        end
    end))
    Track(btn.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) and downPos then
            local moved = (input.Position - downPos).Magnitude
            downPos = nil
            if moved < 12 and Active then fn() end
        end
    end))
end

local function MakeCard(container, order, height)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = COL_CARD
    f.BackgroundTransparency = CARD_TRANSPARENCY
    f.BorderSizePixel = 0
    f.Size = UDim2.new(1, 0, 0, height)
    f.LayoutOrder = order
    f.Parent = container
    Corner(f, UDim.new(0, 10))
    local s = Instance.new("UIStroke")
    s.Color = COL_LINE
    s.Thickness = 1
    s.Transparency = 0.55
    s.Parent = f
    return f, s
end

local function MakeText(parent, text, size, font, color, pos, sz)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = font
    l.TextSize = size
    l.TextColor3 = color
    l.TextStrokeColor3 = Color3.new(0, 0, 0)
    l.TextStrokeTransparency = 0.75
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Text = text
    l.Position = pos
    l.Size = sz
    l.Parent = parent
    return l
end

local function MakeTapOverlay(parent)
    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Size = UDim2.fromScale(1, 1)
    btn.ZIndex = 10
    btn.Parent = parent
    return btn
end

-- trava/destrava a rolagem da aba enquanto o usuário mexe num controle interno
local function LockScroll(container, locked)
    pcall(function() container.ScrollingEnabled = not locked end)
end

-- ==================== TROCA DE IDIOMA ====================
local function Retranslate()
    local roots = {}
    pcall(function()
        local gui = Window and Window.Root and Window.Root:FindFirstAncestorOfClass("ScreenGui")
        if gui then table.insert(roots, gui) end
    end)
    pcall(function()
        if Fluent.GUI and Fluent.GUI ~= roots[1] then table.insert(roots, Fluent.GUI) end
    end)
    for _, root in ipairs(roots) do
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local key = RevMap[d.Text]
                if key then
                    local new = T(key)
                    if new ~= d.Text then pcall(function() d.Text = new end) end
                end
            end
        end
    end
end

local LangBars = {}

local function SetLangSelected()
    for code, b in pairs(LangBars) do
        local sel = (code == Lang)
        b.stroke.Color = sel and Color3.new(1, 1, 1) or COL_LINE
        b.stroke.Thickness = sel and 2 or 1
        b.stroke.Transparency = sel and 0 or 0.55
        b.label.Text = sel and ("✓  " .. LangNames[code]) or LangNames[code]
    end
end

local function ApplyLanguage(code)
    if not Active or not Strings[code] or code == Lang then return end
    Lang = code
    Config.lang = code
    SaveConfig()
    Retranslate()
    SetLangSelected()
    for _, fn in pairs(UIRefreshers) do pcall(fn) end
    Notify({ Title = T("lang_sec"), Content = LangNames[code], Duration = 3 })
end

-- ==================== ABA INFORMAÇÕES ====================
local function BuildInfoUI(tab)
    local container = tab.Container
    if typeof(container) ~= "Instance" then return false end

    -- cartão do usuário: avatar à ESQUERDA, nomes à direita (layout horizontal garantido)
    local profile = MakeCard(container, 100, 84)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = profile

    local hLayout = Instance.new("UIListLayout")
    hLayout.FillDirection = Enum.FillDirection.Horizontal
    hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    hLayout.SortOrder = Enum.SortOrder.LayoutOrder
    hLayout.Padding = UDim.new(0, 12)
    hLayout.Parent = profile

    local avatar = Instance.new("ImageLabel")
    avatar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    avatar.BorderSizePixel = 0
    avatar.Size = UDim2.fromOffset(64, 64)
    avatar.ScaleType = Enum.ScaleType.Crop
    avatar.LayoutOrder = 1
    avatar.Parent = profile
    Corner(avatar, UDim.new(1, 0))

    local textCol = Instance.new("Frame")
    textCol.BackgroundTransparency = 1
    textCol.Size = UDim2.new(1, -76, 1, 0)
    textCol.LayoutOrder = 2
    textCol.Parent = profile

    local vLayout = Instance.new("UIListLayout")
    vLayout.FillDirection = Enum.FillDirection.Vertical
    vLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    vLayout.SortOrder = Enum.SortOrder.LayoutOrder
    vLayout.Padding = UDim.new(0, 2)
    vLayout.Parent = textCol

    local nameLbl = MakeText(textCol, LocalPlayer.DisplayName, 18, Enum.Font.GothamBold, COL_TEXT,
        UDim2.new(), UDim2.new(1, 0, 0, 24))
    nameLbl.LayoutOrder = 1
    local userLbl = MakeText(textCol, "@" .. LocalPlayer.Name, 14, Enum.Font.Gotham, COL_SUB,
        UDim2.new(), UDim2.new(1, 0, 0, 20))
    userLbl.LayoutOrder = 2

    task.spawn(function()
        local okT, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if okT and content and avatar.Parent then avatar.Image = content end
    end)

    -- jogadores no servidor
    local card = MakeCard(container, 101, 54)
    local playersLbl = MakeText(card, "", 12, Enum.Font.Gotham, COL_SUB,
        UDim2.fromOffset(14, 7), UDim2.new(1, -28, 0, 16))
    local playersVal = MakeText(card, "", 16, Enum.Font.GothamBold, COL_TEXT,
        UDim2.fromOffset(14, 25), UDim2.new(1, -28, 0, 22))

    local function UpdatePlayers(exclude)
        local n = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= exclude then n += 1 end
        end
        playersVal.Text = string.format("%d / %d", n, Players.MaxPlayers)
    end

    UIRefreshers.info = function() playersLbl.Text = T("info_players") end
    UIRefreshers.info()
    UpdatePlayers()

    Track(Players.PlayerAdded:Connect(function() UpdatePlayers() end))
    Track(Players.PlayerRemoving:Connect(function(p) UpdatePlayers(p) end))
    return true
end

InfoTab:AddParagraph({ Title = T("info_p_t"), Content = T("info_p_c") })
BuildInfoUI(InfoTab)

-- ==================== MAIN: NOCLIP (robusto e leve) ====================
-- Mantém uma lista em cache das peças do personagem (atualizada por eventos, sem GetDescendants por frame).
-- Se o jogo tentar reativar CanCollide, o evento reverte na hora.
local NC = { on = false, parts = {}, partConns = {}, charConns = {}, stepConn = nil, charAddedConn = nil }

local function NCUntrack(part)
    local c = NC.partConns[part]
    if c then c:Disconnect(); NC.partConns[part] = nil end
    NC.parts[part] = nil
end

local function NCTrack(part)
    if not part:IsA("BasePart") or NC.parts[part] ~= nil then return end
    NC.parts[part] = part.CanCollide
    part.CanCollide = false
    NC.partConns[part] = part:GetPropertyChangedSignal("CanCollide"):Connect(function()
        if NC.on and part.CanCollide then part.CanCollide = false end
    end)
end

local function NCClearChar(restore)
    for _, c in ipairs(NC.charConns) do c:Disconnect() end
    NC.charConns = {}
    for part, orig in pairs(NC.parts) do
        if NC.partConns[part] then NC.partConns[part]:Disconnect() end
        if restore and orig and part.Parent then pcall(function() part.CanCollide = true end) end
    end
    NC.parts, NC.partConns = {}, {}
end

local function NCBind(char)
    NCClearChar(false)
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do NCTrack(d) end
    table.insert(NC.charConns, char.DescendantAdded:Connect(NCTrack))
    table.insert(NC.charConns, char.DescendantRemoving:Connect(NCUntrack))
end

local function SetNoclip(on)
    if on then
        if NC.on then return end
        NC.on = true
        NCBind(LocalPlayer.Character)
        NC.charAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
            if not NC.on then return end
            char:WaitForChild("HumanoidRootPart", 10)
            if NC.on then NCBind(char) end
        end)
        NC.stepConn = RunService.Stepped:Connect(function()
            for part in pairs(NC.parts) do
                if part.CanCollide then part.CanCollide = false end
            end
        end)
    else
        if not NC.on then return end
        NC.on = false
        if NC.stepConn then NC.stepConn:Disconnect(); NC.stepConn = nil end
        if NC.charAddedConn then NC.charAddedConn:Disconnect(); NC.charAddedConn = nil end
        NCClearChar(true)
    end
end

OnShutdown(function() SetNoclip(false) end)

local camOrigMode, camConn
local function SetCamNoclip(on)
    if on then
        if camConn then return end
        camOrigMode = LocalPlayer.DevCameraOcclusionMode
        pcall(function() LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam end)
        camConn = LocalPlayer:GetPropertyChangedSignal("DevCameraOcclusionMode"):Connect(function()
            if Active and Settings.CamNoclip
            and LocalPlayer.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
                pcall(function() LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam end)
            end
        end)
    else
        if camConn then camConn:Disconnect(); camConn = nil end
        if camOrigMode then
            pcall(function() LocalPlayer.DevCameraOcclusionMode = camOrigMode end)
            camOrigMode = nil
        end
    end
end

OnShutdown(function() SetCamNoclip(false) end)

Main:AddSection(T("sec_move"))
AddSetting(Main, "Noclip", "noclip_t", "noclip_d", SetNoclip)
AddSetting(Main, "CamNoclip", "camnoclip_t", "camnoclip_d", SetCamNoclip)

-- ==================== MAIN: TELEPORTE ATÉ JOGADOR ====================
local TP = { selected = nil }
local ROW_H = 38

local function TPButtonColor()
    local a = CurrentTheme and CurrentTheme.Accent or Color3.fromRGB(150, 90, 230)
    return Shade(a, 0.35)
end

local function BuildTeleportUI(tab)
    local container = tab.Container
    if typeof(container) ~= "Instance" then return false end

    local header = MakeText(container, T("sec_tp"), 15, Enum.Font.GothamBold, COL_TEXT,
        UDim2.new(), UDim2.new(1, 0, 0, 26))
    header.LayoutOrder = 100

    local row = Instance.new("Frame")
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, 42)
    row.LayoutOrder = 101
    row.Parent = container

    local selector = Instance.new("Frame")
    selector.BackgroundColor3 = COL_CARD
    selector.BackgroundTransparency = CARD_TRANSPARENCY
    selector.BorderSizePixel = 0
    selector.Size = UDim2.new(1, -112, 1, 0)
    selector.Parent = row
    Corner(selector, UDim.new(0, 8))
    local selStroke = Instance.new("UIStroke")
    selStroke.Color = COL_LINE
    selStroke.Transparency = 0.55
    selStroke.Parent = selector

    local selText = MakeText(selector, "", 14, Enum.Font.GothamMedium, COL_TEXT,
        UDim2.fromOffset(12, 0), UDim2.new(1, -40, 1, 0))
    local arrow = MakeText(selector, "▾", 16, Enum.Font.GothamBold, COL_SUB,
        UDim2.new(1, -26, 0, 0), UDim2.fromOffset(20, 42))
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    local selBtn = MakeTapOverlay(selector)

    local tpFrame = Instance.new("Frame")
    tpFrame.AnchorPoint = Vector2.new(1, 0)
    tpFrame.Position = UDim2.new(1, 0, 0, 0)
    tpFrame.Size = UDim2.fromOffset(104, 42)
    tpFrame.BackgroundColor3 = TPButtonColor()
    tpFrame.BackgroundTransparency = 0.15
    tpFrame.BorderSizePixel = 0
    tpFrame.Parent = row
    Corner(tpFrame, UDim.new(0, 8))
    local tpText = MakeText(tpFrame, "", 14, Enum.Font.GothamBold, Color3.new(1, 1, 1),
        UDim2.fromOffset(4, 0), UDim2.new(1, -8, 1, 0))
    tpText.TextXAlignment = Enum.TextXAlignment.Center
    local tpBtn = MakeTapOverlay(tpFrame)

    -- lista com rolagem própria (não "briga" com a rolagem da aba)
    local list = Instance.new("ScrollingFrame")
    list.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    list.BackgroundTransparency = 0.35
    list.BorderSizePixel = 0
    list.Size = UDim2.new(1, 0, 0, 160)
    list.LayoutOrder = 102
    list.Visible = false
    list.Active = true
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.ElasticBehavior = Enum.ElasticBehavior.Never
    list.ScrollBarThickness = 4
    list.ScrollBarImageTransparency = 0.3
    list.CanvasSize = UDim2.new()
    list.AutomaticCanvasSize = Enum.AutomaticSize.None
    list.Parent = container
    Corner(list, UDim.new(0, 8))
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = list
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    -- enquanto o dedo/mouse está na lista, só ela rola
    Track(list.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            LockScroll(container, true)
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            LockScroll(container, false)
        end
    end))
    Track(list.MouseEnter:Connect(function() LockScroll(container, true) end))
    Track(list.MouseLeave:Connect(function() LockScroll(container, false) end))

    local function RefreshSelector()
        local sel = TP.selected
        if sel and sel.Parent == Players then
            selText.Text = sel.DisplayName .. "  (@" .. sel.Name .. ")"
            selText.TextColor3 = COL_TEXT
        else
            TP.selected = nil
            selText.Text = T("tp_select")
            selText.TextColor3 = COL_SUB
        end
        tpText.Text = T("tp_button")
    end

    local function RebuildList(exclude)
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
        end
        local n = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr ~= exclude then
                n += 1
                local b = Instance.new("TextButton")
                b.BackgroundColor3 = COL_CARD
                b.BackgroundTransparency = 0.3
                b.BorderSizePixel = 0
                b.AutoButtonColor = false
                b.Size = UDim2.new(1, 0, 0, ROW_H - 4)
                b.LayoutOrder = n
                b.Font = Enum.Font.Gotham
                b.TextSize = 13
                b.TextColor3 = COL_TEXT
                b.TextXAlignment = Enum.TextXAlignment.Left
                b.TextTruncate = Enum.TextTruncate.AtEnd
                b.Text = "  " .. plr.DisplayName .. "  (@" .. plr.Name .. ")"
                b.Parent = list
                Corner(b, UDim.new(0, 6))
                OnTap(b, function()
                    TP.selected = plr
                    list.Visible = false
                    LockScroll(container, false)
                    RefreshSelector()
                end)
            end
        end
        if n == 0 then
            local e = MakeText(list, T("tp_none"), 13, Enum.Font.Gotham, COL_SUB,
                UDim2.new(), UDim2.new(1, 0, 0, ROW_H - 4))
            e.TextXAlignment = Enum.TextXAlignment.Center
            n = 1
        end
        local contentH = n * ROW_H + 4
        list.CanvasSize = UDim2.new(0, 0, 0, contentH)
        list.Size = UDim2.new(1, 0, 0, math.min(contentH + 4, 170))
    end

    OnTap(selBtn, function()
        list.Visible = not list.Visible
        if list.Visible then RebuildList() else LockScroll(container, false) end
    end)

    OnTap(tpBtn, function()
        local target = TP.selected
        if not target or target.Parent ~= Players then
            Notify({ Title = T("sec_tp"), Content = T("n_tp_none"), Duration = 3 })
            return
        end
        local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not (tRoot and myRoot) then
            Notify({ Title = T("sec_tp"), Content = T("n_tp_fail"), Duration = 3 })
            return
        end
        myRoot.CFrame = tRoot.CFrame
        pcall(function()
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
        Notify({ Title = T("sec_tp"), Content = T("n_tp_ok", target.DisplayName), Duration = 3 })
    end)

    Track(Players.PlayerAdded:Connect(function()
        if list.Visible then RebuildList() end
    end))
    Track(Players.PlayerRemoving:Connect(function(p)
        if TP.selected == p then TP.selected = nil end
        RefreshSelector()
        if list.Visible then RebuildList(p) end
    end))

    UIRefreshers.tp = function()
        header.Text = T("sec_tp")
        RefreshSelector()
        if list.Visible then RebuildList() end
    end
    UIRefreshers.tpColor = function() tpFrame.BackgroundColor3 = TPButtonColor() end

    RefreshSelector()
    return true
end

BuildTeleportUI(Main)

-- ==================== ESP ====================
local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "DaphneESP"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 5
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ESPGui.Parent = CoreGui end)
if not ESPGui.Parent then ESPGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Entries = {}
local ESPConn = nil
local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local R6 = Enum.HumanoidRigType.R6
local V3_UP = Vector3.new(0, 1, 0)

local function MakeLabel(textSize, anchorY)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = textSize
    l.TextColor3 = WHITE
    l.TextStrokeColor3 = BLACK
    l.TextStrokeTransparency = 0.2
    l.AnchorPoint = Vector2.new(0.5, anchorY)
    l.Size = UDim2.fromOffset(200, textSize + 4)
    l.Text = ""
    l.Visible = false
    l.ZIndex = 3
    l.Parent = ESPGui
    return l
end

local function MakeBoxFrame(strokeColor, thickness, z)
    local f = Instance.new("Frame")
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = z
    f.Parent = ESPGui
    local s = Instance.new("UIStroke")
    s.Color = strokeColor
    s.Thickness = thickness
    s.Parent = f
    return f
end

local function OutlineAlpha()
    return math.clamp(Settings.ESPOutlineThin, 0, 90) / 100
end

-- Highlight criado só quando necessário (economiza memória e o limite de 31 do Roblox)
local function EnsureHighlight(e)
    if e.hl then return e.hl end
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineTransparency = OutlineAlpha()
    hl.OutlineColor = WHITE
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    hl.Parent = ESPGui
    e.hl = hl
    return hl
end

local function DropHighlight(e)
    if e.hl then e.hl:Destroy(); e.hl = nil end
end

local function HideEntry(e)
    if not e.shown then return end
    e.shown = false
    e.boxOut.Visible = false
    e.box.Visible = false
    e.name.Visible = false
    e.dist.Visible = false
    e.arrow.Visible = false
end

local function ResolveEntry(e, rebuild)
    local char = e.plr.Character
    e.char = char
    e.hrp = char and char:FindFirstChild("HumanoidRootPart")
    e.head = char and char:FindFirstChild("Head")
    e.hum = char and char:FindFirstChildOfClass("Humanoid")

    if rebuild then DropHighlight(e) end

    if e.hum ~= e.connHum then
        if e.humConn then e.humConn:Disconnect(); e.humConn = nil end
        e.connHum = e.hum
        if e.hum then
            e.humConn = e.hum.Died:Connect(function()
                HideEntry(e)
                if e.hl then e.hl.Enabled = false end
            end)
        end
    end
end

local function AddEntry(plr)
    if plr == LocalPlayer or Entries[plr] then return end
    local e = {
        plr = plr,
        conns = {},
        boxOut = MakeBoxFrame(BLACK, 3, 1),
        box = MakeBoxFrame(WHITE, 1.2, 2),
        name = MakeLabel(13, 1),
        dist = MakeLabel(12, 0),
        arrow = MakeLabel(20, 1),
        hue = math.random(),
        shown = false,
        lastName = "", lastDist = "",
    }
    e.arrow.Text = "▼"
    e.arrow.Font = Enum.Font.Arial
    e.arrow.TextYAlignment = Enum.TextYAlignment.Bottom
    Entries[plr] = e

    local function onChar(char)
        task.spawn(function()
            char:WaitForChild("HumanoidRootPart", 15)
            char:WaitForChild("Head", 15)
            char:WaitForChild("Humanoid", 15)
            if Entries[plr] ~= e or plr.Character ~= char then return end
            ResolveEntry(e, true)
        end)
    end
    table.insert(e.conns, plr.CharacterAdded:Connect(onChar))
    table.insert(e.conns, plr.CharacterRemoving:Connect(function()
        HideEntry(e)
        DropHighlight(e)
        e.char, e.hrp, e.head, e.hum = nil, nil, nil, nil
    end))
    if plr.Character then onChar(plr.Character) end
end

local function RemoveEntry(plr)
    local e = Entries[plr]
    if not e then return end
    Entries[plr] = nil
    for _, c in ipairs(e.conns) do pcall(function() c:Disconnect() end) end
    if e.humConn then pcall(function() e.humConn:Disconnect() end) end
    pcall(function()
        e.boxOut:Destroy(); e.box:Destroy(); e.name:Destroy()
        e.dist:Destroy(); e.arrow:Destroy(); DropHighlight(e)
    end)
end

local function ForceRefreshAll()
    for _, e in pairs(Entries) do ResolveEntry(e, true) end
end

local function ESPUpdate(dt)
    local cam = workspace.CurrentCamera
    if not cam then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local origin = myRoot and myRoot.Position or cam.CFrame.Position

    local sBox, sName, sDist, sArrow, sOut =
        Settings.ESPBox, Settings.ESPName, Settings.ESPDistance, Settings.ESPArrow, Settings.ESPOutline
    local metros = Settings.ESPDistUnit == "Meters"
    local drawAny = sBox or sName or sDist or sArrow

    for plr, e in pairs(Entries) do
        local char = plr.Character
        if e.char ~= char then
            ResolveEntry(e, true)
        elseif char and not (e.hrp and e.head and e.hum and e.hrp.Parent and e.head.Parent) then
            ResolveEntry(e, false)
        end

        local hrp, head, hum = e.hrp, e.head, e.hum
        local alive = hrp and head and hum and hrp.Parent and head.Parent and hum.Health > 0

        if alive and sOut then
            local hl = EnsureHighlight(e)
            if hl.Adornee ~= char then hl.Adornee = char end
            if not hl.Enabled then hl.Enabled = true end
        elseif e.hl and e.hl.Enabled then
            e.hl.Enabled = false
        end

        if alive and drawAny then
            local hrpPos, hrpSize = hrp.Position, hrp.Size
            local legs = (hum.RigType == R6 or hum.HipHeight < 0.1) and hrpSize.Y or hum.HipHeight
            local topPos = head.Position + V3_UP * (head.Size.Y * 0.5 + 0.1)
            local botPos = hrpPos - V3_UP * (hrpSize.Y * 0.5 + legs)
            local tp = cam:WorldToViewportPoint(topPos)
            local bp = cam:WorldToViewportPoint(botPos)

            if tp.Z > 0 and bp.Z > 0 then
                local worldH = math.max(topPos.Y - botPos.Y, 0.1)
                local h = math.max(bp.Y - tp.Y, 2)
                local w = h * ((hrpSize.X * 1.6) / worldH)
                local cx = (tp.X + bp.X) * 0.5
                local x = math.floor(cx - w * 0.5 + 0.5)
                local y = math.floor(tp.Y + 0.5)
                local fw, fh = math.floor(w + 0.5), math.floor(h + 0.5)
                local cxr = math.floor(cx + 0.5)
                local dist = (origin - hrpPos).Magnitude

                e.shown = true

                if sBox then
                    local pos, size = UDim2.fromOffset(x, y), UDim2.fromOffset(fw, fh)
                    e.boxOut.Position, e.boxOut.Size = pos, size
                    e.box.Position, e.box.Size = pos, size
                end
                e.boxOut.Visible = sBox
                e.box.Visible = sBox

                local arrowH = 0
                if sArrow then
                    arrowH = math.clamp(math.floor(h * 0.3), 12, 44)
                    local a = e.arrow
                    a.Size = UDim2.fromOffset(arrowH * 2, arrowH)
                    a.TextSize = arrowH
                    a.Position = UDim2.fromOffset(cxr, y - 1)
                    local t = 1 - math.clamp(dist / 300, 0, 1)
                    e.hue = (e.hue + dt * (0.15 + 3.85 * t * t)) % 1
                    a.TextColor3 = Color3.fromHSV(e.hue, 1, 1)
                end
                e.arrow.Visible = sArrow

                if sName then
                    local n = e.name
                    local dn = plr.DisplayName
                    if e.lastName ~= dn then e.lastName = dn; n.Text = dn end
                    n.Position = UDim2.fromOffset(cxr, y - 2 - arrowH)
                end
                e.name.Visible = sName

                if sDist then
                    local txt
                    if metros then
                        txt = string.format("%.1f m", math.floor(dist * 0.28 * 10 + 0.5) / 10)
                    else
                        txt = string.format("%d studs", math.floor(dist + 0.5))
                    end
                    if e.lastDist ~= txt then e.lastDist = txt; e.dist.Text = txt end
                    e.dist.Position = UDim2.fromOffset(cxr, y + fh + 2)
                end
                e.dist.Visible = sDist
            else
                HideEntry(e)
            end
        else
            HideEntry(e)
        end
    end
end

local function RefreshESP()
    local any = Settings.ESPBox or Settings.ESPName or Settings.ESPDistance
        or Settings.ESPArrow or Settings.ESPOutline
    if any and not ESPConn then
        ESPConn = RunService.RenderStepped:Connect(ESPUpdate)
    elseif not any and ESPConn then
        ESPConn:Disconnect()
        ESPConn = nil
    end
    if not any then
        for _, e in pairs(Entries) do HideEntry(e) end
    end
    if not Settings.ESPOutline then
        for _, e in pairs(Entries) do DropHighlight(e) end
    end
end

local function OnESPToggle(v)
    RefreshESP()
    if v then ForceRefreshAll() end
end

for _, plr in ipairs(Players:GetPlayers()) do AddEntry(plr) end
Track(Players.PlayerAdded:Connect(AddEntry))
Track(Players.PlayerRemoving:Connect(RemoveEntry))

OnShutdown(function()
    if ESPConn then ESPConn:Disconnect(); ESPConn = nil end
    for plr in pairs(Entries) do RemoveEntry(plr) end
    pcall(function() ESPGui:Destroy() end)
end)

ESPTab:AddSection(T("tab_esp"))
AddSetting(ESPTab, "ESPBox", "esp_box_t", "esp_box_d", OnESPToggle)
AddSetting(ESPTab, "ESPName", "esp_name_t", "esp_name_d", OnESPToggle)
AddSetting(ESPTab, "ESPDistance", "esp_dist_t", "esp_dist_d", OnESPToggle)
Dropdowns.ESPDistUnit = ESPTab:AddDropdown("ESPDistUnit", {
    Title = T("esp_unit_t"),
    Values = { "Studs", "Meters" },
    Multi = false,
    Default = IndexOf({ "Studs", "Meters" }, Settings.ESPDistUnit) or 1,
    Callback = function(v)
        if not Active or (v ~= "Studs" and v ~= "Meters") then return end
        Settings.ESPDistUnit = v
        SaveConfig()
    end
})
AddSetting(ESPTab, "ESPArrow", "esp_arrow_t", "esp_arrow_d", OnESPToggle)
AddSetting(ESPTab, "ESPOutline", "esp_out_t", "esp_out_d", OnESPToggle)

-- Slider próprio (o slider do Fluent com descrição estava quebrando o layout e criando a caixa gigante)
local function BuildOutlineSlider(tab)
    local container = tab.Container
    if typeof(container) ~= "Instance" then return false end

    local MIN, MAX = 0, 90
    local card = MakeCard(container, 150, 72)

    MakeText(card, T("esp_thin_t"), 14, Enum.Font.GothamMedium, COL_TEXT,
        UDim2.fromOffset(12, 6), UDim2.new(1, -70, 0, 18))
    local valLbl = MakeText(card, "", 14, Enum.Font.GothamBold, COL_TEXT,
        UDim2.new(1, -58, 0, 6), UDim2.fromOffset(46, 18))
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    MakeText(card, T("esp_thin_d"), 11, Enum.Font.Gotham, COL_SUB,
        UDim2.fromOffset(12, 26), UDim2.new(1, -24, 0, 14))

    local track = Instance.new("Frame")
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    track.BackgroundTransparency = 0.3
    track.BorderSizePixel = 0
    track.Position = UDim2.new(0, 14, 0, 54)
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Parent = card
    Corner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(190, 140, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.fromScale(0, 1)
    fill.Parent = track
    Corner(fill, UDim.new(1, 0))

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.fromScale(0, 0.5)
    knob.ZIndex = 3
    knob.Parent = track
    Corner(knob, UDim.new(1, 0))

    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.Position = UDim2.new(0, 0, 0, 42)
    hit.Size = UDim2.new(1, 0, 0, 30)
    hit.ZIndex = 10
    hit.Parent = card

    local function visual(v)
        local a = (v - MIN) / (MAX - MIN)
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, 0.5)
        valLbl.Text = tostring(v)
    end

    local function setValue(v)
        v = math.clamp(math.floor(v + 0.5), MIN, MAX)
        if Settings.ESPOutlineThin ~= v then
            Settings.ESPOutlineThin = v
            SaveConfig()
            local a = OutlineAlpha()
            for _, e in pairs(Entries) do
                if e.hl then e.hl.OutlineTransparency = a end
            end
        end
        visual(v)
    end

    local dragging = false
    local function fromX(x)
        local w = track.AbsoluteSize.X
        if w <= 0 then return end
        local a = math.clamp((x - track.AbsolutePosition.X) / w, 0, 1)
        setValue(MIN + a * (MAX - MIN))
    end

    Track(hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            LockScroll(container, true)
            fromX(input.Position.X)
        end
    end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            fromX(input.Position.X)
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            LockScroll(container, false)
        end
    end))

    visual(Settings.ESPOutlineThin)
    OutlineSlider = { set = function(v) setValue(v) end }
    return true
end

BuildOutlineSlider(ESPTab)

-- ==================== MISC: ANTI-SIT ====================
local antiSitCharConn, antiSitHumConn

local function ProtectHumanoid(hum)
    if antiSitHumConn then antiSitHumConn:Disconnect(); antiSitHumConn = nil end
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)
    local function release()
        local seat = hum.SeatPart
        local weld = seat and seat:FindFirstChild("SeatWeld")
        if weld then weld:Destroy() end
        hum.Sit = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    if hum.Sit then release() end
    antiSitHumConn = hum:GetPropertyChangedSignal("Sit"):Connect(function()
        if Settings.AntiSit and hum.Sit then release() end
    end)
end

local function SetAntiSit(on)
    if on then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then ProtectHumanoid(hum) end
        if not antiSitCharConn then
            antiSitCharConn = LocalPlayer.CharacterAdded:Connect(function(c)
                local h = c:WaitForChild("Humanoid", 10)
                if h and Settings.AntiSit and Active then ProtectHumanoid(h) end
            end)
        end
    else
        if antiSitCharConn then antiSitCharConn:Disconnect(); antiSitCharConn = nil end
        if antiSitHumConn then antiSitHumConn:Disconnect(); antiSitHumConn = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end) end
    end
end

OnShutdown(function() SetAntiSit(false) end)

-- ==================== MISC: FULLBRIGHT ====================
local FBProps = {
    Brightness = 2,
    ClockTime = 14,
    FogEnd = 1e6,
    GlobalShadows = false,
    Ambient = Color3.fromRGB(178, 178, 178),
    OutdoorAmbient = Color3.fromRGB(178, 178, 178),
}
local FBOrig, FBAtmos, FBConns = nil, nil, {}
local FBApplying = false

local function ApplyFullbright()
    if FBApplying then return end
    FBApplying = true
    for p, v in pairs(FBProps) do
        if Lighting[p] ~= v then pcall(function() Lighting[p] = v end) end
    end
    if FBAtmos then
        for atm in pairs(FBAtmos) do
            if atm.Parent then
                if atm.Density ~= 0 then atm.Density = 0 end
                if atm.Haze ~= 0 then atm.Haze = 0 end
            end
        end
    end
    FBApplying = false
end

local function SetFullbright(on)
    if on then
        if FBOrig then return end
        FBOrig, FBAtmos = {}, {}
        for p in pairs(FBProps) do FBOrig[p] = Lighting[p] end
        for _, c in ipairs(Lighting:GetChildren()) do
            if c:IsA("Atmosphere") then FBAtmos[c] = { Density = c.Density, Haze = c.Haze } end
        end
        ApplyFullbright()
        for p in pairs(FBProps) do
            table.insert(FBConns, Lighting:GetPropertyChangedSignal(p):Connect(function()
                if FBOrig and Lighting[p] ~= FBProps[p] then ApplyFullbright() end
            end))
        end
        for atm in pairs(FBAtmos) do
            for _, prop in ipairs({ "Density", "Haze" }) do
                table.insert(FBConns, atm:GetPropertyChangedSignal(prop):Connect(function()
                    if FBOrig then ApplyFullbright() end
                end))
            end
        end
    else
        if not FBOrig then return end
        for _, c in ipairs(FBConns) do c:Disconnect() end
        FBConns = {}
        for p, v in pairs(FBOrig) do pcall(function() Lighting[p] = v end) end
        for atm, v in pairs(FBAtmos or {}) do
            if atm.Parent then atm.Density = v.Density; atm.Haze = v.Haze end
        end
        FBOrig, FBAtmos = nil, nil
    end
end

OnShutdown(function() SetFullbright(false) end)

-- ==================== MISC: AUTO REJOIN ====================
local rejoining = false

local function DoRejoin()
    if rejoining or not Active or not Settings.AutoRejoin then return end
    rejoining = true
    Notify({ Title = "Auto Rejoin", Content = T("n_rejoin"), Duration = 6 })
    task.spawn(function()
        local attempt = 0
        while Active and Settings.AutoRejoin do
            attempt += 1
            pcall(function()
                if attempt % 3 == 0 or #Players:GetPlayers() <= 1 then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            task.wait(6)
        end
        rejoining = false
    end)
end

local function SetupRejoinWatch()
    task.spawn(function()
        pcall(function()
            local gui = CoreGui:WaitForChild("RobloxPromptGui", 15)
            local overlay = gui and gui:WaitForChild("promptOverlay", 15)
            if overlay and Active then
                Track(overlay.ChildAdded:Connect(function(child)
                    if child.Name == "ErrorPrompt" then DoRejoin() end
                end))
            end
        end)
    end)
    pcall(function()
        Track(GuiService.ErrorMessageChanged:Connect(function()
            local msg = ""
            pcall(function() msg = GuiService:GetErrorMessage() end)
            if msg ~= "" then DoRejoin() end
        end))
    end)
end

SetupRejoinWatch()

MiscTab:AddSection(T("tab_misc"))
AddSetting(MiscTab, "Fullbright", "fb_t", "fb_d", SetFullbright)
AddSetting(MiscTab, "AntiSit", "antisit_t", "antisit_d", SetAntiSit)
AddSetting(MiscTab, "AutoRejoin", "rejoin_t", "rejoin_d", nil)

-- ==================== TEMAS ====================
local ThemeToken = 0
local ThemeBars = {}

local function SetBarSelected(name)
    for n, b in pairs(ThemeBars) do
        local sel = (n == name)
        b.stroke.Color = sel and Color3.new(1, 1, 1) or Color3.fromRGB(120, 120, 140)
        b.stroke.Thickness = sel and 2 or 1
        b.stroke.Transparency = sel and 0 or 0.55
        b.label.Text = sel and ("✓  " .. n) or n
    end
end

local function SetBarImages(name, wall, btn)
    local b = ThemeBars[name]
    if not b then return end
    if wall then b.wall.Image = wall end
    if btn then b.ball.Image = btn end
end

local function ApplyTheme(Value)
    if not Active or Value == CurrentThemeName then return end
    local selectedData = ActiveThemes[Value]
    if not selectedData then return end

    ThemeToken += 1
    local token = ThemeToken

    task.spawn(function()
        local newWall = LoadImage(selectedData.Wallpaper, selectedData.WallpaperFile)
        local newButton = LoadImage(selectedData.Button, selectedData.ButtonFile)

        if not Active or token ~= ThemeToken then return end
        SetBarImages(Value, newWall, newButton)

        CurrentThemeName = Value
        CurrentTheme = selectedData
        Config.theme = Value
        SaveConfig()
        SetBarSelected(Value)
        if UIRefreshers.tpColor then pcall(UIRefreshers.tpColor) end

        if MinimizerOutline then MinimizerOutline.Color = selectedData.BorderColor end
        if MinimizerBtnObj and newButton then MinimizerBtnObj.Image = newButton end

        pcall(function() Fluent:SetTheme(RegisterTheme(Value, newWall)) end)

        local wallOk = newWall and ApplyWallpaper(newWall)

        if newWall and newButton and wallOk then
            local quote = (not IsSpecial) and RandomQuote(Value) or nil
            Notify({
                Title = quote and Value or T("n_theme_t"),
                Content = quote or T("n_theme_c", Value),
                Duration = 4
            })
        else
            Notify({ Title = T("n_partial_t"), Content = T("n_partial_c", Value), Duration = 5 })
        end
    end)
end

local function BuildThemeBars(tab)
    local container = tab.Container
    if typeof(container) ~= "Instance" then return false end

    for i, name in ipairs(ActiveOrder) do
        local data = ActiveThemes[name]

        local bar = Instance.new("Frame")
        bar.Name = "ThemeBar_" .. name
        bar.Size = UDim2.new(1, 0, 0, 64)
        bar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        bar.BorderSizePixel = 0
        bar.LayoutOrder = 100 + i
        bar.Parent = container
        Corner(bar, UDim.new(0, 12))

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(120, 120, 140)
        stroke.Thickness = 1
        stroke.Transparency = 0.55
        stroke.Parent = bar

        local wall = Instance.new("ImageLabel")
        wall.Name = "Wall"
        wall.BackgroundTransparency = 1
        wall.Size = UDim2.fromScale(1, 1)
        wall.ScaleType = Enum.ScaleType.Crop
        wall.Image = ImageCache[data.WallpaperFile] or ""
        wall.ZIndex = 1
        wall.Parent = bar
        Corner(wall, UDim.new(0, 12))

        local shade = Instance.new("Frame")
        shade.BackgroundColor3 = Color3.new(0, 0, 0)
        shade.BorderSizePixel = 0
        shade.Size = UDim2.fromScale(1, 1)
        shade.ZIndex = 2
        shade.Parent = bar
        Corner(shade, UDim.new(0, 12))
        local grad = Instance.new("UIGradient")
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.6, 0.75),
            NumberSequenceKeypoint.new(1, 1),
        })
        grad.Parent = shade

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(16, 0)
        label.Size = UDim2.new(1, -90, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.4
        label.Text = name
        label.ZIndex = 3
        label.Parent = bar

        local ball = Instance.new("ImageLabel")
        ball.Name = "Ball"
        ball.AnchorPoint = Vector2.new(1, 0.5)
        ball.Position = UDim2.new(1, -12, 0.5, 0)
        ball.Size = UDim2.fromOffset(44, 44)
        ball.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        ball.ScaleType = Enum.ScaleType.Crop
        ball.Image = ImageCache[data.ButtonFile] or ""
        ball.ZIndex = 3
        ball.Parent = bar
        Corner(ball, UDim.new(1, 0))
        local ballStroke = Instance.new("UIStroke")
        ballStroke.Color = data.BorderColor
        ballStroke.Thickness = 1.5
        ballStroke.Parent = ball

        local btn = MakeTapOverlay(bar)
        OnTap(btn, function() ApplyTheme(name) end)

        ThemeBars[name] = { bar = bar, wall = wall, ball = ball, label = label, stroke = stroke }
    end

    SetBarSelected(CurrentThemeName)

    local function reapply(img, asset)
        if asset and not img.IsLoaded then
            img.Image = ""
            task.defer(function()
                if img.Parent then img.Image = asset end
            end)
        end
    end
    local function RefreshBarVisuals()
        for n, b in pairs(ThemeBars) do
            local d = ActiveThemes[n]
            reapply(b.wall, ImageCache[d.WallpaperFile])
            reapply(b.ball, ImageCache[d.ButtonFile])
        end
    end
    Track(container:GetPropertyChangedSignal("Visible"):Connect(function()
        if container.Visible then task.delay(0.1, RefreshBarVisuals) end
    end))
    task.delay(1, RefreshBarVisuals)
    return true
end

ThemesTab:AddParagraph({ Title = T("tab_themes"), Content = T("themes_p_c") })

if not BuildThemeBars(ThemesTab) then
    for _, name in ipairs(ActiveOrder) do
        ThemesTab:AddButton({ Title = name, Callback = function() ApplyTheme(name) end })
    end
end

-- ==================== CONFIG ====================
ConfigTab:AddParagraph({ Title = T("cfg_p_t"), Content = T("cfg_p_c") })

ConfigTab:AddButton({
    Title = T("cfg_reset_t"),
    Description = T("cfg_reset_d"),
    Callback = function()
        if not Active then return end
        for key, t in pairs(Toggles) do
            pcall(function() t:SetValue(Defaults[key]) end)
        end
        pcall(function() Dropdowns.ESPDistUnit:SetValue(Defaults.ESPDistUnit) end)
        if OutlineSlider then pcall(OutlineSlider.set, Defaults.ESPOutlineThin) end
        ApplyTheme(DefaultThemeName)
        Notify({ Title = T("n_cfg_t"), Content = T("n_cfg_c"), Duration = 3 })
    end
})

ConfigTab:AddSection(T("lang_sec"))

local function BuildLangBars(tab)
    local container = tab.Container
    if typeof(container) ~= "Instance" then return false end

    for i, code in ipairs(LangOrder) do
        local bar, stroke = MakeCard(container, 200 + i, 44)
        local label = MakeText(bar, LangNames[code], 15, Enum.Font.GothamBold, COL_TEXT,
            UDim2.fromOffset(16, 0), UDim2.new(1, -32, 1, 0))
        local btn = MakeTapOverlay(bar)
        OnTap(btn, function() ApplyLanguage(code) end)
        LangBars[code] = { stroke = stroke, label = label }
    end
    SetLangSelected()
    return true
end

if not BuildLangBars(ConfigTab) then
    for _, code in ipairs(LangOrder) do
        ConfigTab:AddButton({ Title = LangNames[code], Callback = function() ApplyLanguage(code) end })
    end
end

pcall(function() Window:SelectTab(1) end)

-- ==================== PRÉ-CARREGAMENTO (um tema por vez, sem travar) ====================
task.spawn(function()
    for _, name in ipairs(ActiveOrder) do
        if not Active then return end
        local data = ActiveThemes[name]
        if data then
            for attempt = 1, 3 do
                local w = LoadImage(data.Wallpaper, data.WallpaperFile)
                local b = LoadImage(data.Button, data.ButtonFile)
                SetBarImages(name, w, b)
                if w and b then
                    local list = { w }
                    if b ~= w then table.insert(list, b) end
                    pcall(function() ContentProvider:PreloadAsync(list) end)
                    break
                end
                task.wait(1)
            end
            task.wait() -- cede o frame entre temas
        end
    end
end)

-- ==================== FRASE INICIAL ====================
if not IsSpecial then
    local quote = RandomQuote(CurrentThemeName)
    if quote then
        Notify({ Title = CurrentThemeName, Content = quote, Duration = 5 })
    end
end

-- aplica os estados salvos que dependem de efeitos (Anti-Sit liga por padrão)
if Settings.AntiSit then SetAntiSit(true) end
if Settings.Fullbright then SetFullbright(true) end
if Settings.ESPBox or Settings.ESPName or Settings.ESPDistance or Settings.ESPArrow or Settings.ESPOutline then
    RefreshESP()
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
