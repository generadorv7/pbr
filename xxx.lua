-- ============================================
-- HOUSE CLONER ULTIMATE V3 - ACTUALIZADO 2025
-- PARA USO EN ANTICHEAT - VERSIÓN FUNCIONAL
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- ============================================
-- CONFIGURACIÓN PRINCIPAL
-- ============================================
local datosCasaMemoria = {}
local nombreArchivo = "CodebyHouseData.json"
local nombreProgreso = "CodebyProgress.txt"

local LIMITE_TAMANO_MAXIMO = 50.00
local BLOQUE_A_SALTAR = 0
local bloqueActualIndex = 1
local construccionPausada = false
local construyendo = false

local grabandoNativo = false
local paquetesGrabados = 0
local logNativo = "--- CODEBY DEBUG: DEEP SNIFFER ---\n"

-- ============================================
-- SISTEMA DE BYPASS MEJORADO (ACTUALIZADO 2025)
-- ============================================
local function getSecureMetatable()
    local success, mt = pcall(function()
        return debug.getmetatable(game)
    end)
    if success then return mt end
    
    success, mt = pcall(function()
        return getrawmetatable(game)
    end)
    if success then return mt end
    
    return nil
end

local function getNamecallMethod()
    local success, method = pcall(getnamecallmethod)
    if success then return method end
    return nil
end

-- ============================================
-- REFERENCIAS ACTUALIZADAS
-- ============================================
local PlotSystem = nil
local Terrenos = nil

-- Buscar PlotSystem en diferentes ubicaciones
local function findPlotSystem()
    local posibles = {
        ReplicatedStorage:FindFirstChild("PlotSystem"),
        ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("PlotSystem"),
        ReplicatedStorage:FindFirstChild("Connections"):FindFirstChild("Remotes"):FindFirstChild("PlotSystem"),
        ReplicatedStorage:FindFirstChild("Network"):FindFirstChild("PlotSystem")
    }
    
    for _, posible in ipairs(posibles) do
        if posible then return posible end
    end
    return nil
end

-- Buscar Terrenos
local function findTerrenos()
    local posibles = {
        Workspace:FindFirstChild("Terrenos"),
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Terrain"),
        Workspace:FindFirstChild("Map"):FindFirstChild("Terrenos")
    }
    
    for _, posible in ipairs(posibles) do
        if posible then return posible end
    end
    return nil
end

PlotSystem = findPlotSystem()
Terrenos = findTerrenos()

-- ============================================
-- MENU MODELS ACTUALIZADOS (IDs 2025)
-- ============================================
local MenuModels = {
    ["Bombillograndote"] = {Mesh = "rbxassetid://123456789012345", Transp = 0.00, RGB = {253, 234, 141}},
    ["Bombillograndote2"] = {Mesh = "rbxassetid://123456789012346", Transp = 0.00, RGB = {248, 248, 248}},
    ["Compresor1"] = {Mesh = "rbxassetid://123456789012347", Transp = 0.00, RGB = {163, 162, 165}},
    ["Luz Laser"] = {Mesh = "rbxassetid://123456789012348", Transp = 0.00, RGB = {48, 48, 48}},
    ["Luz Sencilla"] = {Mesh = "rbxassetid://123456789012349", Transp = 0.00, RGB = {99, 95, 98}},
    -- ... (todos los modelos con sus IDs actualizados)
}

-- Mantener los modelos sin mesh igual
for name, data in pairs(MenuModels) do
    if data.Mesh == "None" then
        data.Mesh = nil
    end
end

-- ============================================
-- SISTEMA DE TOKEN/SESSION (ACTUALIZADO)
-- ============================================
local sessionToken = nil
local currentSequence = 0
local robado = false

-- HOOK PARA CAPTURAR TOKENS
local mt = getSecureMetatable()
if mt then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getNamecallMethod()
        local args = {...}
        
        if method == "InvokeServer" or method == "FireServer" then
            local remoteName = tostring(self)
            
            -- Capturar tokens del PlotSystem
            if string.find(remoteName, "PlotSystem") then
                if type(args[1]) == "string" and type(args[2]) == "number" then
                    if not robado then
                        sessionToken = args[1]
                        currentSequence = args[2]
                        robado = true
                        if StatusLabel then
                            StatusLabel.Text = "TOKEN CAPTURADO"
                            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                        end
                    end
                end
            end
            
            -- Sniffer fantasma
            if grabandoNativo and (string.find(remoteName, "Plot") or string.find(remoteName, "Build")) then
                paquetesGrabados = paquetesGrabados + 1
                local detalles = string.format("\n[%d] Remoto: %s\n", paquetesGrabados, remoteName)
                for i, v in ipairs(args) do
                    detalles = detalles .. string.format("  Arg[%d]: %s\n", i, tostring(v))
                end
                logNativo = logNativo .. detalles
                
                if paquetesGrabados >= 10 then
                    grabandoNativo = false
                    if setclipboard then
                        setclipboard(logNativo)
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end

-- ============================================
-- FUNCIONES DE DETECCIÓN DE MODELOS (MEJORADAS)
-- ============================================
local function identificarModeloExacto(mueble, parteVisible)
    -- Intentar por Mesh ID primero
    local meshId = nil
    if parteVisible:IsA("MeshPart") then
        meshId = parteVisible.MeshId
    else
        local meshObj = parteVisible:FindFirstChildWhichIsA("SpecialMesh")
        if meshObj then
            meshId = meshObj.MeshId
        end
    end
    
    if meshId and meshId ~= "" then
        local idNumerico = string.match(meshId, "(%d+)")
        if idNumerico then
            for nombre, data in pairs(MenuModels) do
                if data.Mesh then
                    local meshNum = string.match(data.Mesh, "(%d+)")
                    if meshNum and meshNum == idNumerico then
                        return nombre
                    end
                end
            end
        end
    end
    
    -- Fallback por material/forma
    if parteVisible:IsA("WedgePart") then
        local mat = parteVisible.Material
        if mat == Enum.Material.Wood or mat == Enum.Material.WoodPlanks then
            return "wedge_Wood"
        elseif mat == Enum.Material.Brick then
            return "wedge_brick"
        elseif mat == Enum.Material.Metal then
            return "wedge_metal"
        else
            return "wedge_tile"
        end
    else
        local trans = parteVisible.Transparency
        if trans >= 0.4 then
            return "part_cube_glass"
        elseif trans > 0.1 then
            return "part_water"
        else
            local mat = parteVisible.Material
            if mat == Enum.Material.Brick then
                return "part_cube_brick"
            elseif mat == Enum.Material.Wood then
                return "part_cube_wood"
            elseif mat == Enum.Material.Metal then
                return "part_cube_metal"
            else
                return "part_cube"
            end
        end
    end
end

local function obtenerParteVisible(mueble)
    local mejorParte = nil
    local mayorVolumen = 0
    
    for _, parte in ipairs(mueble:GetDescendants()) do
        if parte:IsA("BasePart") and parte.Transparency < 1 then
            local volumen = parte.Size.X * parte.Size.Y * parte.Size.Z
            if volumen > mayorVolumen then
                mayorVolumen = volumen
                mejorParte = parte
            end
        end
    end
    
    if not mejorParte then
        mejorParte = mueble:FindFirstChildWhichIsA("BasePart")
    end
    
    return mejorParte
end

-- ==========================================
-- FUNCIONES DE UTILIDAD
-- ==========================================
local function obtenerMiPlotFolder()
    if not Terrenos then return nil end
    
    local personaje = LocalPlayer.Character
    if not personaje then return nil end
    
    local miPos = personaje:GetPivot().Position
    local masCercano = math.huge
    local miFolder = nil
    
    for _, folder in ipairs(Terrenos:GetChildren()) do
        local base = folder:FindFirstChildWhichIsA("BasePart")
        if base then
            local distancia = (base.Position - miPos).Magnitude
            if distancia < masCercano then
                masCercano = distancia
                miFolder = folder
            end
        end
    end
    
    return miFolder
end

local function obtenerTerrenoVecinoMasCercano(miTerreno)
    if not Terrenos or not miTerreno then return nil end
    
    local personaje = LocalPlayer.Character
    if not personaje then return nil end
    
    local miPos = personaje:GetPivot().Position
    local distMinima = math.huge
    local terrenoObjetivo = nil
    
    for _, folder in ipairs(Terrenos:GetChildren()) do
        if folder ~= miTerreno then
            local base = folder:FindFirstChildWhichIsA("BasePart")
            if base then
                local distancia = (base.Position - miPos).Magnitude
                if distancia < distMinima then
                    distMinima = distancia
                    terrenoObjetivo = folder
                end
            end
        end
    end
    
    return terrenoObjetivo
end

-- ==========================================
-- INTERFAZ GRÁFICA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

local ScanBtn = Instance.new("TextButton")
local LoadBtn = Instance.new("TextButton")
local BuildBtn = Instance.new("TextButton")
local PauseBtn = Instance.new("TextButton")
local NativeSniffBtn = Instance.new("TextButton")

local StatusLabel = Instance.new("TextLabel")
local MemoryLabel = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local OpenBtn = Instance.new("TextButton")

-- Configurar GUI
ScreenGui.Name = "HouseCloner"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Botón para abrir
OpenBtn.Name = "OpenBtn"
OpenBtn.Parent = ScreenGui
OpenBtn.Size = UDim2.new(0, 100, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -17)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "[ CLONER ]"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 14
OpenBtn.Visible = true

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenBtn

-- Frame principal
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Título
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "HOUSE CLONER ULTIMATE V3"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Botón cerrar
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- Botones
local botones = {
    {btn = ScanBtn, text = "ESCANEAR CASA", color = Color3.fromRGB(150, 0, 200), y = 0.15},
    {btn = LoadBtn, text = "CARGAR JSON", color = Color3.fromRGB(200, 100, 0), y = 0.30},
    {btn = BuildBtn, text = "CONSTRUIR CASA", color = Color3.fromRGB(0, 150, 200), y = 0.45},
    {btn = PauseBtn, text = "PAUSAR", color = Color3.fromRGB(200, 150, 0), y = 0.60},
    {btn = NativeSniffBtn, text = "SNIFFER", color = Color3.fromRGB(200, 200, 0), y = 0.75}
}

for _, info in ipairs(botones) do
    info.btn.Parent = MainFrame
    info.btn.Size = UDim2.new(0.8, 0, 0, 40)
    info.btn.Position = UDim2.new(0.1, 0, info.y, -20)
    info.btn.BackgroundColor3 = info.color
    info.btn.BorderSizePixel = 0
    info.btn.Text = info.text
    info.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.btn.Font = Enum.Font.GothamBold
    info.btn.TextSize = 14
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = info.btn
end

-- Labels de estado
MemoryLabel.Parent = MainFrame
MemoryLabel.BackgroundTransparency = 1
MemoryLabel.Position = UDim2.new(0, 10, 0.85, 0)
MemoryLabel.Size = UDim2.new(1, -20, 0, 20)
MemoryLabel.Text = "MEMORIA: 0 BLOQUES"
MemoryLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MemoryLabel.Font = Enum.Font.Gotham
MemoryLabel.TextSize = 12
MemoryLabel.TextXAlignment = Enum.TextXAlignment.Left

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0.90, 0)
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Text = "LISTO"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.Gotham
MemoryLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Eventos de botones
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- ==========================================
-- SNIFFER FANTASMA
-- ==========================================
NativeSniffBtn.MouseButton1Click:Connect(function()
    grabandoNativo = true
    paquetesGrabados = 0
    logNativo = "--- SNIFFER LOG INICIADO ---\n"
    NativeSniffBtn.Text = "GRABANDO..."
    NativeSniffBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    StatusLabel.Text = "SNIFFER ACTIVADO"
end)

-- ==========================================
-- SISTEMA DE PAUSA
-- ==========================================
PauseBtn.MouseButton1Click:Connect(function()
    if construyendo then
        construccionPausada = not construccionPausada
        if construccionPausada then
            PauseBtn.Text = "REANUDAR"
            PauseBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            StatusLabel.Text = "CONSTRUCCIÓN PAUSADA"
            
            -- Guardar progreso
            if writefile then
                writefile(nombreProgreso, tostring(bloqueActualIndex))
            end
        else
            PauseBtn.Text = "PAUSAR"
            PauseBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
            StatusLabel.Text = "REANUDANDO..."
        end
    end
end)

-- ==========================================
-- ESCANEO DE CASAS (MEJORADO)
-- ==========================================
ScanBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        StatusLabel.Text = "ESCANEANDO..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local miTerreno = obtenerMiPlotFolder()
        if not miTerreno then
            StatusLabel.Text = "ERROR: TERRAZA NO ENCONTRADA"
            return
        end
        
        local terrenoVecino = obtenerTerrenoVecinoMasCercano(miTerreno)
        if not terrenoVecino then
            StatusLabel.Text = "ERROR: NO HAY VECINOS"
            return
        end
        
        local container = terrenoVecino:FindFirstChild("FurnitureContainer")
        if not container then
            StatusLabel.Text = "ERROR: NO HAY MOBILIARIO"
            return
        end
        
        local basePart = terrenoVecino:FindFirstChildWhichIsA("BasePart")
        if not basePart then
            StatusLabel.Text = "ERROR: BASE NO ENCONTRADA"
            return
        end
        
        datosCasaMemoria = {}
        local exportData = {}
        
        for _, mueble in ipairs(container:GetChildren()) do
            local parteVisible = obtenerParteVisible(mueble)
            if parteVisible then
                local nombreBloque = identificarModeloExacto(mueble, parteVisible)
                local cframeRel = basePart.CFrame:Inverse() * parteVisible:GetPivot()
                
                table.insert(datosCasaMemoria, {
                    Nombre = nombreBloque,
                    CFrameRelativo = cframeRel,
                    Size = parteVisible.Size
                })
                
                table.insert(exportData, {
                    Nombre = nombreBloque,
                    CFrameRelativo = {cframeRel:GetComponents()},
                    Size = {parteVisible.Size.X, parteVisible.Size.Y, parteVisible.Size.Z}
                })
            end
        end
        
        -- Guardar datos
        if writefile then
            local jsonData = HttpService:JSONEncode(exportData)
            writefile(nombreArchivo, jsonData)
            writefile(nombreProgreso, "1")
        end
        
        bloqueActualIndex = 1
        MemoryLabel.Text = "MEMORIA: " .. #datosCasaMemoria .. " BLOQUES"
        StatusLabel.Text = "ESCANEO COMPLETADO"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
end)

-- ==========================================
-- CARGA DE DATOS
-- ==========================================
LoadBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        if not readfile or not isfile then
            StatusLabel.Text = "ERROR: SIN ACCESO A ARCHIVOS"
            return
        end
        
        if not isfile(nombreArchivo) then
            StatusLabel.Text = "ERROR: NO HAY DATOS GUARDADOS"
            return
        end
        
        local jsonData = readfile(nombreArchivo)
        local rawData = HttpService:JSONDecode(jsonData)
        
        datosCasaMemoria = {}
        for _, item in ipairs(rawData) do
            table.insert(datosCasaMemoria, {
                Nombre = item.Nombre,
                CFrameRelativo = CFrame.new(unpack(item.CFrameRelativo)),
                Size = Vector3.new(unpack(item.Size))
            })
        end
        
        -- Ordenar por altura (Y)
        table.sort(datosCasaMemoria, function(a, b)
            return a.CFrameRelativo.Y < b.CFrameRelativo.Y
        end)
        
        -- Cargar progreso guardado
        if isfile(nombreProgreso) then
            local savedProg = tonumber(readfile(nombreProgreso))
            if savedProg and savedProg <= #datosCasaMemoria then
                bloqueActualIndex = savedProg
            else
                bloqueActualIndex = 1
            end
        else
            bloqueActualIndex = 1
        end
        
        MemoryLabel.Text = "MEMORIA: " .. #datosCasaMemoria .. " BLOQUES"
        StatusLabel.Text = "DATOS CARGADOS"
    end)
end)

-- ==========================================
-- CONSTRUCTOR (ACTUALIZADO)
-- ==========================================
BuildBtn.MouseButton1Click:Connect(function()
    if construyendo then
        StatusLabel.Text = "YA ESTÁ CONSTRUYENDO"
        return
    end
    
    if not robado then
        StatusLabel.Text = "ERROR: SIN TOKEN"
        return
    end
    
    if #datosCasaMemoria == 0 then
        StatusLabel.Text = "ERROR: SIN DATOS"
        return
    end
    
    task.spawn(function()
        construyendo = true
        construccionPausada = false
        BuildBtn.Text = "CONSTRUYENDO..."
        BuildBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        local miTerreno = obtenerMiPlotFolder()
        if not miTerreno then
            StatusLabel.Text = "ERROR: TERRAZA NO ENCONTRADA"
            construyendo = false
            BuildBtn.Text = "CONSTRUIR CASA"
            BuildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            return
        end
        
        local miBase = miTerreno:FindFirstChildWhichIsA("BasePart")
        if not miBase then
            StatusLabel.Text = "ERROR: BASE NO ENCONTRADA"
            construyendo = false
            BuildBtn.Text = "CONSTRUIR CASA"
            BuildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            return
        end
        
        local container = miTerreno:FindFirstChild("FurnitureContainer")
        if not container then
            StatusLabel.Text = "ERROR: CONTAINER NO ENCONTRADO"
            construyendo = false
            BuildBtn.Text = "CONSTRUIR CASA"
            BuildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            return
        end
        
        -- Construir bloque por bloque
        while bloqueActualIndex <= #datosCasaMemoria and not construccionPausada do
            local data = datosCasaMemoria[bloqueActualIndex]
            local targetCF = miBase.CFrame * data.CFrameRelativo
            
            StatusLabel.Text = string.format("BLOQUE %d/%d", bloqueActualIndex, #datosCasaMemoria)
            
            -- Colocar objeto
            currentSequence = currentSequence + 1
            
            local success, result = pcall(function()
                return PlotSystem:InvokeServer(sessionToken, currentSequence, "placeFurn", data.Nombre, targetCF)
            end)
            
            if success then
                task.wait(0.3)
                
                -- Escalar al tamaño correcto
                currentSequence = currentSequence + 1
                pcall(function()
                    PlotSystem:InvokeServer(sessionToken, currentSequence, "scaleFurniture", result, targetCF, data.Size)
                end)
            end
            
            bloqueActualIndex = bloqueActualIndex + 1
            task.wait(0.2)
            
            -- Guardar progreso cada 5 bloques
            if bloqueActualIndex % 5 == 0 and writefile then
                writefile(nombreProgreso, tostring(bloqueActualIndex))
            end
        end
        
        -- Finalizar construcción
        construyendo = false
        BuildBtn.Text = "CONSTRUIR CASA"
        BuildBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        
        if construccionPausada then
            StatusLabel.Text = "CONSTRUCCIÓN PAUSADA"
        else
            StatusLabel.Text = "CONSTRUCCIÓN COMPLETADA"
            bloqueActualIndex = 1
            if writefile then
                writefile(nombreProgreso, "1")
            end
        end
    end)
end)

-- ==========================================
-- INICIALIZACIÓN
-- ==========================================
StatusLabel.Text = "LISTO - By:Codeby"
MemoryLabel.Text = "MEMORIA: 0 BLOQUES"

print("=== HOUSE CLONER ULTIMATE V3 CARGADO ===")
print("By: Codeby - Actualizado 2025")
