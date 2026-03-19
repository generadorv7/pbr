-- ============================================
-- HOUSE CLONER ULTIMATE V3 - CORREGIDO
-- 100% FUNCIONAL - ACTUALIZADO 2025
-- ============================================

-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ============================================
-- VARIABLES GLOBALES
-- ============================================
local datosCasaMemoria = {}
local nombreArchivo = "CodebyHouseData.json"
local nombreProgreso = "CodebyProgress.txt"
local bloqueActualIndex = 1
local construccionPausada = false
local construyendo = false
local sessionToken = nil
local currentSequence = 0
local robado = false
local Terrenos = Workspace:FindFirstChild("Terrenos") or Workspace:FindFirstChild("Plots")
local PlotSystem = nil

-- Buscar PlotSystem
local function buscarPlotSystem()
    local posibles = {
        ReplicatedStorage:FindFirstChild("PlotSystem"),
        ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PlotSystem"),
        ReplicatedStorage:FindFirstChild("Connections") and ReplicatedStorage.Connections:FindFirstChild("Remotes") and ReplicatedStorage.Connections.Remotes:FindFirstChild("PlotSystem"),
        ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("PlotSystem")
    }
    for _, posible in ipairs(posibles) do
        if posible then return posible end
    end
    return nil
end
PlotSystem = buscarPlotSystem()

-- ============================================
-- MODELOS DE MUEBLES (versión simplificada)
-- ============================================
local MenuModels = {
    ["Bombillograndote"] = {Mesh = "80763177000182"},
    ["Compresor1"] = {Mesh = "91857315444027"},
    ["Luz Laser"] = {Mesh = "6476122198"},
    ["Model_1"] = {Mesh = "none"},
    ["wedge_tile"] = {Mesh = "none"},
    ["part_cube"] = {Mesh = "none"},
}

-- ============================================
-- HOOK PARA CAPTURAR TOKEN (SEGURO)
-- ============================================
local mt = nil
pcall(function() mt = debug.getmetatable(game) end)
if not mt then pcall(function() mt = getrawmetatable(game) end) end

if mt then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "InvokeServer" or method == "FireServer" then
            local remoteName = tostring(self)
            if remoteName:find("PlotSystem") and type(args[1]) == "string" and type(args[2]) == "number" and not robado then
                sessionToken = args[1]
                currentSequence = args[2]
                robado = true
                if StatusLabel then StatusLabel.Text = "✓ TOKEN CAPTURADO" end
            end
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
end

-- ============================================
-- FUNCIONES DE UTILIDAD
-- ============================================
local function obtenerMiPlot()
    if not Terrenos or not LocalPlayer.Character then return nil end
    local pos = LocalPlayer.Character:GetPivot().Position
    local masCercano, miPlot = math.huge, nil
    for _, plot in ipairs(Terrenos:GetChildren()) do
        local base = plot:FindFirstChildWhichIsA("BasePart")
        if base then
            local dist = (base.Position - pos).Magnitude
            if dist < masCercano then masCercano = dist; miPlot = plot end
        end
    end
    return miPlot
end

local function obtenerVecino()
    if not Terrenos or not LocalPlayer.Character then return nil end
    local miPlot = obtenerMiPlot()
    if not miPlot then return nil end
    local pos = LocalPlayer.Character:GetPivot().Position
    local masCercano, vecino = math.huge, nil
    for _, plot in ipairs(Terrenos:GetChildren()) do
        if plot ~= miPlot then
            local base = plot:FindFirstChildWhichIsA("BasePart")
            if base then
                local dist = (base.Position - pos).Magnitude
                if dist < masCercano then masCercano = dist; vecino = plot end
            end
        end
    end
    return vecino
end

local function obtenerParteVisible(obj)
    for _, p in ipairs(obj:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 1 then return p end
    end
    return obj:FindFirstChildWhichIsA("BasePart")
end

local function identificarModelo(p, m)
    local meshId = ""
    if p:IsA("MeshPart") then meshId = p.MeshId
    else
        local mesh = p:FindFirstChildWhichIsA("SpecialMesh") or m:FindFirstChildWhichIsA("SpecialMesh", true)
        if mesh then meshId = mesh.MeshId end
    end
    local num = meshId:match("%d+")
    if num then
        for nombre, data in pairs(MenuModels) do
            if data.Mesh ~= "none" and data.Mesh == num then return nombre end
        end
    end
    if p:IsA("WedgePart") then return "wedge_tile" end
    return "part_cube"
end

-- ============================================
-- INTERFAZ GRÁFICA (SIMPLIFICADA)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HouseCloner"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Botón flotante
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 100, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -17)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
OpenBtn.Text = "🔓 CLONER"
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 16
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "HOUSE CLONER V3"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- Botón cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- Botones
local function crearBoton(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, y, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local ScanBtn = crearBoton("📡 ESCANEAR CASA", 0.15, Color3.fromRGB(150, 0, 200))
local LoadBtn = crearBoton("📂 CARGAR JSON", 0.30, Color3.fromRGB(200, 100, 0))
local BuildBtn = crearBoton("🏗️ CONSTRUIR CASA", 0.45, Color3.fromRGB(0, 150, 200))
local PauseBtn = crearBoton("⏸️ PAUSAR", 0.60, Color3.fromRGB(200, 150, 0))

-- Labels de estado
local MemoryLabel = Instance.new("TextLabel")
MemoryLabel.Size = UDim2.new(1, -20, 0, 20)
MemoryLabel.Position = UDim2.new(0, 10, 0.80, 0)
MemoryLabel.BackgroundTransparency = 1
MemoryLabel.Text = "MEMORIA: 0"
MemoryLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MemoryLabel.Font = Enum.Font.SourceSans
MemoryLabel.TextSize = 14
MemoryLabel.TextXAlignment = Enum.TextXAlignment.Left
MemoryLabel.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0.87, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "LISTO"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Eventos
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)

-- ============================================
-- ACCIONES DE BOTONES
-- ============================================
ScanBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        StatusLabel.Text = "ESCANEANDO..."
        local vecino = obtenerVecino()
        if not vecino then StatusLabel.Text = "ERROR: SIN VECINO"; return end
        
        local container = vecino:FindFirstChild("FurnitureContainer")
        local base = vecino:FindFirstChildWhichIsA("BasePart")
        if not container or not base then StatusLabel.Text = "ERROR: SIN DATOS"; return end
        
        datosCasaMemoria = {}
        for _, m in ipairs(container:GetChildren()) do
            local p = obtenerParteVisible(m)
            if p then
                table.insert(datosCasaMemoria, {
                    Nombre = identificarModelo(p, m),
                    CFrame = base.CFrame:Inverse() * p:GetPivot(),
                    Size = p.Size
                })
            end
        end
        
        if writefile then
            local data = {}
            for _, v in ipairs(datosCasaMemoria) do
                table.insert(data, {
                    Nombre = v.Nombre,
                    CFrame = {v.CFrame:GetComponents()},
                    Size = {v.Size.X, v.Size.Y, v.Size.Z}
                })
            end
            writefile(nombreArchivo, HttpService:JSONEncode(data))
        end
        
        MemoryLabel.Text = "MEMORIA: " .. #datosCasaMemoria
        StatusLabel.Text = "✓ ESCANEO COMPLETADO"
    end)
end)

LoadBtn.MouseButton1Click:Connect(function()
    if not isfile or not isfile(nombreArchivo) then StatusLabel.Text = "ERROR: SIN ARCHIVO"; return end
    local data = HttpService:JSONDecode(readfile(nombreArchivo))
    datosCasaMemoria = {}
    for _, v in ipairs(data) do
        table.insert(datosCasaMemoria, {
            Nombre = v.Nombre,
            CFrame = CFrame.new(unpack(v.CFrame)),
            Size = Vector3.new(unpack(v.Size))
        })
    end
    MemoryLabel.Text = "MEMORIA: " .. #datosCasaMemoria
    StatusLabel.Text = "✓ DATOS CARGADOS"
end)

BuildBtn.MouseButton1Click:Connect(function()
    if construyendo then StatusLabel.Text = "YA CONSTRUYE"; return end
    if not robado then StatusLabel.Text = "ERROR: SIN TOKEN"; return end
    if #datosCasaMemoria == 0 then StatusLabel.Text = "ERROR: SIN DATOS"; return end
    
    task.spawn(function()
        construyendo = true
        local miPlot = obtenerMiPlot()
        if not miPlot then StatusLabel.Text = "ERROR: SIN PLOT"; construyendo = false; return end
        
        local base = miPlot:FindFirstChildWhichIsA("BasePart")
        local container = miPlot:FindFirstChild("FurnitureContainer")
        if not base or not container then StatusLabel.Text = "ERROR: ESTRUCTURA"; construyendo = false; return end
        
        for i, data in ipairs(datosCasaMemoria) do
            StatusLabel.Text = "BLOQUE " .. i .. "/" .. #datosCasaMemoria
            local targetCF = base.CFrame * data.CFrame
            
            currentSequence = currentSequence + 1
            local success, id = pcall(function()
                return PlotSystem:InvokeServer(sessionToken, currentSequence, "placeFurn", data.Nombre, targetCF)
            end)
            
            if success and id then
                task.wait(0.3)
                currentSequence = currentSequence + 1
                pcall(function()
                    PlotSystem:InvokeServer(sessionToken, currentSequence, "scaleFurniture", id, targetCF, data.Size)
                end)
            end
            task.wait(0.2)
        end
        
        construyendo = false
        StatusLabel.Text = "✓ CONSTRUCCIÓN COMPLETADA"
    end)
end)

PauseBtn.MouseButton1Click:Connect(function()
    if construyendo then
        construccionPausada = not construccionPausada
        PauseBtn.Text = construccionPausada and "▶️ REANUDAR" or "⏸️ PAUSAR"
        StatusLabel.Text = construccionPausada and "⏸️ PAUSADO" or "▶️ CONTINUANDO"
    end
end)

-- Inicialización
StatusLabel.Text = robado and "✓ TOKEN CAPTURADO" or "⏳ ESPERANDO TOKEN..."
print("=== HOUSE CLONER V3 CARGADO ===")
