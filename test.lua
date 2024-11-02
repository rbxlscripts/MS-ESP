--[[

         ▄▄▄▄███▄▄▄▄      ▄████████         ▄████████    ▄████████    ▄███████▄
        ▄██▀▀▀███▀▀▀██▄   ███    ███        ███    ███   ███    ███   ███    ███
        ███   ███   ███   ███    █▀         ███    █▀    ███    █▀    ███    ███
        ███   ███   ███   ███              ▄███▄▄▄       ███          ███    ███
        ███   ███   ███ ▀███████████      ▀▀███▀▀▀     ▀███████████ ▀█████████▀
        ███   ███   ███          ███        ███    █▄           ███   ███
        ███   ███   ███    ▄█    ███        ███    ███    ▄█    ███   ███
        ▀█   ███   █▀   ▄████████▀         ██████████  ▄████████▀   ▄████▀

                    Created by mstudio45 + bacalhauz (Discord)
--]]

if getgenv().mstudio45 and getgenv().mstudio45.ESPLibrary then return getgenv().mstudio45.ESPLibrary; end

-- // Executor Functions // --
local getService = typeof(cloneref) == "function" and (function(name) return cloneref(game:GetService(name)) end) or (function(name) return game:GetService(name) end)
local DrawingLib = typeof(Drawing) == "table" and Drawing or { noDrawing = true };

-- // Services // --
local Players = getService("Players");
local CoreGui = getService("CoreGui");
--local CoreGui = typeof(gethui) == "function" and gethui() or getService("CoreGui");
local RunService = getService("RunService");
local UserInputService = getService("UserInputService");

-- // Variables // --
local localPlayer = Players.LocalPlayer;
local character;
local rootPart;
local camera;
local worldToViewport;

--// Setup Library Table \\--
local __DEBUG = false;
local __LOG = true;
local __PREFIX = "mstudio45's ESP"

local Library = {
    -- // Logging // --
    Print = function(...)
        if __LOG ~= true then return end
        print("[💭 INFO] " .. __PREFIX .. ":", ...)
    end,
    Warn = function(...)
        if __LOG ~= true then return end
        warn("[⚠ WARN] " .. __PREFIX .. ":", ...)
    end,
    Error = function(...)
        if __LOG ~= true then return end
        error("[🆘 ERROR] " .. __PREFIX .. ":", ...)
    end,
    Debug = function(...)
        if __DEBUG ~= true or __LOG ~= true then return end
        print("[🛠 DEBUG] " .. __PREFIX .. ":", ...)
    end,

    SetDebugEnabled     = function(bool) __DEBUG = bool end,
    SetIsLoggingEnabled = function(bool) __LOG = bool end,
    SetPrefix           = function(pref) __PREFIX = tostring(pref) end,

    -- // Storage // --
    ESP = {
        Billboards = {},
        Adornments = {},
        Highlights = {},
        Outlines = {},

        Arrows = {},
        Tracers = {}
    },

    Folders = {}
}

--// Global Toggles \\--
Library.Adornments = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Adornments.Enabled = bool
        end
    end,
    Enable      = function() Library.Adornments.Enabled = true end,
    Disable     = function() Library.Adornments.Enabled = false end,
    Toggle      = function() Library.Adornments.Enabled = not Library.Adornments.Enabled end
};

Library.Billboards = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Billboards.Enabled = bool
        end
    end,
    Enable      = function() Library.Billboards.Enabled = true end,
    Disable     = function() Library.Billboards.Enabled = false end,
    Toggle      = function() Library.Billboards.Enabled = not Library.Billboards.Enabled end
};

Library.Highlights = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Highlights.Enabled = bool
        end
    end,
    Enable      = function() Library.Highlights.Enabled = true end,
    Disable     = function() Library.Highlights.Enabled = false end,
    Toggle      = function() Library.Highlights.Enabled = not Library.Highlights.Enabled end
};

Library.Outlines = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Outlines.Enabled = bool
        end
    end,
    Enable      = function() Library.Outlines.Enabled = true end,
    Disable     = function() Library.Outlines.Enabled = false end,
    Toggle      = function() Library.Outlines.Enabled = not Library.Outlines.Enabled end
};

Library.Distance = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Distance.Enabled = bool;
        end;
    end,
    Enable      = function() Library.Distance.Enabled = true end,
    Disable     = function() Library.Distance.Enabled = false end,
    Toggle      = function() Library.Distance.Enabled = not Library.Distance.Enabled end
};

Library.Tracers = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Tracers.Enabled = bool
        end
    end,
    Enable      = function() Library.Tracers.Enabled = true end,
    Disable     = function() Library.Tracers.Enabled = false end,
    Toggle      = function() Library.Tracers.Enabled = not Library.Tracers.Enabled end
};

Library.Arrows = {
    Enabled = true,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Arrows.Enabled = bool
        end
    end,
    Enable      = function() Library.Arrows.Enabled = true end,
    Disable     = function() Library.Arrows.Enabled = false end,
    Toggle      = function() Library.Arrows.Enabled = not Library.Arrows.Enabled end
};

Library.Rainbow = {
    HueSetup = 0, Hue = 0, Step = 0,
    Color = Color3.new(),
    Enabled = false,

    Set = function(bool)
        if typeof(bool) == "boolean" then
            Library.Rainbow.Enabled = bool
        end
    end,
    Enable      = function() Library.Rainbow.Enabled = true end,
    Disable     = function() Library.Rainbow.Enabled = false end,
    Toggle      = function() Library.Rainbow.Enabled = not Library.Rainbow.Enabled end
};

--// Connections \\--
Library.Connections = { List = {} }
function Library.Connections.Add(connection, keyName, stopWhenKey)
    assert(typeof(connection) == "RBXScriptConnection", "Argument #1 must be a RBXScriptConnection.")
    local totalCount = 0; for _, v in pairs(Library.Connections.List) do totalCount = totalCount + 1 end
    local key = table.find({ "string", "number" }, typeof(keyName)) and tostring(keyName) or totalCount + 1

    if table.find(Library.Connections.List, key) or typeof(Library.Connections.List[key]) == "RBXScriptConnection" then
        Library.Warn(key, "already exists in Connections!")
        if stopWhenKey then return end
        key = totalCount + 1
    end

    Library.Debug(key, "connection added.")
    Library.Connections.List[key] = connection
    return key
end

function Library.Connections.Remove(key)
    if typeof(Library.Connections.List[key]) ~= "RBXScriptConnection" then return end

    if Library.Connections.List[key].Connected then
        Library.Debug(key, "connection disconnected.")
        Library.Connections.List[key]:Disconnect();

        local keyIndex = table.find(Library.Connections.List, key)
        if keyIndex then table.remove(Library.Connections.List, keyIndex) end
    end
end


--// Functions \\--
function Library.Validate(args, template)
    -- // Adds missing values depending on the 'template' argument // --
    args = type(args) == "table" and args or {}

    for key, value in pairs(template) do
        local argValue = args[key]

        if argValue == nil or type(argValue) ~= type(value) then
            args[key] = value
        elseif type(value) == "table" then
            args[key] = Library.Validate(argValue, value)
        end
    end

    return args
end

local function getFolder(name, parent, backup, typeOfInstance)
    assert(typeof(name) == "string", "Argument #1 must be a string.");
    assert(typeof(parent) == "Instance", "Argument #2 must be an Instance.");
    Library.Debug("Creating folder '" .. name .. "'.")

    local folder = parent:FindFirstChild(name) or (backup and backup:FindFirstChild(name))
    if folder == nil then
        folder = Instance.new(if typeOfInstance == nil then "Folder" else tostring(typeOfInstance))
        folder.Name = name

        local parented = pcall(function() folder.Parent = parent end)
        if not parented and backup then folder.Parent = backup end
    end

    return folder
end

local function updateVariables()
    Library.Debug("Updating variables...")
    localPlayer = Players.LocalPlayer;

    character = character or (localPlayer.Character or localPlayer.CharacterAdded:Wait());
    rootPart = rootPart or (character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")) or nil);

    camera = camera or workspace.CurrentCamera;
    worldToViewport = function(...) camera = (camera or workspace.CurrentCamera); return camera:WorldToViewportPoint(...) end;
    Library.Debug("Variables updated!")
end

local function randomString(length)
    length = tonumber(length) or math.random(10, 20)
    local array = {}

    for i = 1, length do array[i] = string.char(math.random(32, 126)) end
    return table.concat(array)
end

--[[local function hasProperty(instance, property) -- // Finds a property using a pcall call and then returns the value of it // --
    assert(typeof(instance) == "Instance", "Argument #1 must be an Instance.");
    assert(typeof(property) == "string", "Argument #2 must be a string.");

    local clone = instance;
    local success, property = pcall(function() return clone[property] end);
    return success and property or nil;
end--]]

local function createInstance(instanceType, properties)
    assert(typeof(instanceType) == "string", "Argument #1 must be a string.");
    assert(typeof(properties) == "table", "Argument #2 must be a table.");

    local success, instance = pcall(function() return Instance.new(instanceType) end);
    assert(success, "Failed to create the instance.");

    for propertyName, propertyValue in pairs(properties) do
        local success, errorMessage = pcall(function() instance[propertyName] = propertyValue end)
        if not success then Library.Warn("Failed to set '" .. propertyName .. "' property.", errorMessage) end
    end

    return instance
end

local function findPrimaryPart(inst)
    if inst == nil or typeof(inst) ~= "Instance" then return nil end
    return (inst:IsA("Model") and inst.PrimaryPart or nil) or inst:FindFirstChildWhichIsA("BasePart") or inst:FindFirstChildWhichIsA("UnionOperation") or inst
end

local function distanceFromCharacter(position, getPositionFromCamera)
    if not position then return 9e9 end
    if typeof(position) == "Instance" then position = position:GetPivot().Position; end

    if getPositionFromCamera and (camera or workspace.CurrentCamera) then
        local cameraPosition = camera and camera.CFrame.Position or workspace.CurrentCamera.CFrame.Position
        return (cameraPosition - position).Magnitude
    end

    if rootPart then
        return (rootPart.Position - position).Magnitude
    elseif camera then
        return (camera.CFrame.Position - position).Magnitude
    end

    return 9e9
end

-- // Setup ESP Info Table // --
Library.Folders.Main = getFolder("__ESP_FOLDER", CoreGui, localPlayer.PlayerGui)
Library.Folders.Billboards = getFolder("__BILLBOARDS_FOLDER", Library.Folders.Main)
Library.Folders.Adornments = getFolder("__ADORNMENTS_FOLDER", Library.Folders.Main)
Library.Folders.Highlights = getFolder("__HIGHLIGHTS_FOLDER", Library.Folders.Main)
Library.Folders.Outlines = getFolder("__OUTLINES_FOLDER", Library.Folders.Main)

Library.Folders.GUI = getFolder("__GUI", CoreGui, localPlayer.PlayerGui, "ScreenGui")
Library.Folders.GUI.IgnoreGuiInset = true

-- // ESP Templates // --
local Templates = {
    Billboard = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,
        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        Color = Color3.new(),

        Hidden = false,
        OnDestroy = nil,

        --// Library Variables \\--
        IsCreatedByDefault = false,
        ParentElement = nil,
    },

    Arrow = {
        Model = nil,
        Visible = true,
        MaxDistance = 5000,
        CenterOffset = 300,

        Color = Color3.new(),

        Hidden = false,
        OnDestroy = nil,

        --// Library Variables \\--
        IsCreatedByDefault = false,
        ParentElement = nil,
    },

    Tracer = {
        Model = nil,
        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        From = "Bottom", -- // Top, Center, Bottom, Mouse // --

        Color = Color3.new(),

        Thickness = 2,
        Transparency = 0.65,

        Hidden = false,
        OnDestroy = nil,

        --// Library Variables \\--
        IsCreatedByDefault = false,
        ParentElement = nil,
    },

    Highlight = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,

        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        FillColor = Color3.new(),
        OutlineColor = Color3.new(),
        TextColor = Color3.new(),

        FillTransparency = 0.65,
        OutlineTransparency = 0,

        Hidden = false,
        OnDestroy = nil,
    },

    Adornment = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,

        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        Color = Color3.new(),
        TextColor = Color3.new(),

        Transparency = 0.65,
        Type = "Box", -- // Box, Cylinder, Sphere // --

        Hidden = false,
        OnDestroy = nil,
    },

    Outline = {
        Name = "Instance",
        Model = nil,
        TextModel = nil,

        Visible = true,
        MaxDistance = 5000,
        StudsOffset = Vector3.new(),
        TextSize = 16,

        SurfaceColor = Color3.new(),
        BorderColor = Color3.new(),
        TextColor = Color3.new(),

        Thickness = 0.04, -- 2
        Transparency = 0.65,

        Hidden = false,
        OnDestroy = nil,
    }
}

--// ESP \\--
function Library.ESP.Clear()
    Library.Debug("---------------------------")

    for espType, storage in pairs(Library.ESP) do
        if typeof(storage) ~= "table" then continue end
        Library.Debug("Clearing '" .. espType .. "'...")

        for idx, esp in pairs(storage) do
            esp.Destroy()
        end
    end

    for name, folder in pairs(Library.Folders) do
        if name == "Main" then continue end

        Library.Debug("Clearing '" .. tostring(name) .. "' folder...")
        folder:ClearAllChildren();
    end

    Library.Debug("---------------------------")
end

function validateArgs(args_, template)
    local args = args_;

    --// Validate \\--
    assert(typeof(args) == "table", "args must be a table.");
    args = Library.Validate(args, template);

    --// Set Model \\--
    assert(typeof(args.Model) == "Instance", "args.Model must be an Instance.");
    args.TextModel = typeof(args.TextModel) == "Instance" and args.TextModel or args.Model;

    if typeof(args.Type) == "string" then args.Type = string.lower(args.Type) end

    return args
end

function createESP(args, tableName, elements, updateFunction, setVisibleFunction, createAdditionalInstances)
    assert(typeof(args) == "table", "args must be a table.");

    assert(typeof(tableName) == "string", "tableName must be a string.");
    assert(typeof(Library.ESP[tableName]) == "table", "table inside Library.ESP using tableName doesn't exists.");

    assert(typeof(elements) == "table", "elements must be a table.");

    assert(typeof(updateFunction) == "function", "updateFunction must be a function.");
    assert(typeof(setVisibleFunction) == "function", "setVisibleFunction must be a function.");

    Library.Debug("Creating " .. tostring(tableName) .. " '" .. tostring(args.Name) .. "'...")

    --// Create Table \\--
    local tableIndex = randomString(); --// uses random string for saving inside the table since the ESP kept overwriting itself \\--
    local ESPTable = {
        --// ESP Info \\--
        TableName = tableName,
        TableIndex = tableIndex,
        Settings = args,

        --// ESP \\--
        UIElements = elements,
        Connections = { },
        Instances = { },

        --// ESP Status \\--
        Hidden = args.Hidden,
        Deleted = false
    }

    --// Setup Connections \\--
    ESPTable.Connections = {
        Library.Connections.Add(args.Model.AncestryChanged:Connect(function(_, parent)
            if not parent then ESPTable.Destroy() end
        end)),

        Library.Connections.Add(args.Model.Destroying:Connect(function() ESPTable.Destroy() end))
    };

    --// Setup Delete Handler \\--
    ESPTable.Destroy = function(noDebugLogs)
        if noDebugLogs ~= true then Library.Debug("Deleting '" .. tostring(ESPTable.Settings.Name) .. "' (" .. tostring(ESPTable.TableName) .. ")...") end

        --// Disconnect connections \\--
        if typeof(ESPTable.Connections) == "table" then
            if noDebugLogs ~= true then Library.Debug("Removing connections...") end

            for index, connectionKey in pairs(ESPTable.Connections) do
                Library.Connections.Remove(connectionKey)
            end
        end

        --// Remove Elements \\--
        if typeof(ESPTable.UIElements) == "table" then
            if noDebugLogs ~= true then Library.Debug("Removing elements...") end

            for index, element in pairs(ESPTable.UIElements) do
                if element == nil or typeof(element) ~= "Instance" then continue end
                element:Destroy()
            end
        end

        --// Remove Additional Instances \\--
        for name, inst in pairs(ESPTable.Instances) do
            if typeof(inst["Destroy"]) ~= "function" then continue end
            inst.Destroy(noDebugLogs)
        end

        --// Finish \\--
        ESPTable.Deleted = true
        if typeof(Library.ESP[ESPTable.TableName]) == "table" then Library.ESP[ESPTable.TableName][ESPTable.TableIndex] = nil end

        if typeof(ESPTable.OnDestroy) == "function" then 
            local success, errorMessage = pcall(ESPTable.OnDestroy) 
            if not success then Library.Warn("OnDestroy error:", errorMessage) end
        end

        if noDebugLogs ~= true then Library.Debug("Deleted '" .. tostring(ESPTable.Settings.Name) .. "' (" .. tostring(ESPTable.TableName) .. ").") end
        if noDebugLogs ~= true then Library.Debug("----------") end
    end
    ESPTable.OnDestroy = args.OnDestroy

    --// Functions \\--
    ESPTable.GetDistance = function()
        if ESPTable.Deleted then return 9e9 end
        if ESPTable.Settings.Model == nil or ESPTable.Settings.Model.Parent == nil then return 9e9 end

        return math.round(distanceFromCharacter(ESPTable.Settings.Model))
    end

    ESPTable.Update = function(newArgs, updateVariable)
        if ESPTable.Deleted then return end

        --// Update Instances \\--
        if ESPTable.IsCreatedByDefault ~= true then
            for name, inst in pairs(ESPTable.Instances) do
                if name == "Billboard" then
                    task.spawn(inst.Update, newArgs)
                    continue
                end

                if typeof(newArgs[name]) ~= "table" then continue end
                if typeof(inst["Update"]) ~= "function" then continue end
                task.spawn(inst.Update, newArgs[name])
            end
        end

        --// Update settings \\--
        newArgs = Library.Validate(newArgs, ESPTable.Settings)
        for key, value in pairs(newArgs) do
            if value == nil or value == ESPTable.Settings[key] or typeof(value) ~= typeof(ESPTable.Settings[key]) then 
                newArgs[key] = ESPTable.Settings[key]; -- set the key to the current setting if: its same, if its nil or if the types doesnt match
                continue
            end

            if updateVariable ~= false then continue end -- if false = don't update setting, only update element
            ESPTable.Settings[key] = value -- update setting
        end

        updateFunction(ESPTable, newArgs, updateVariable);
    end

    ESPTable.SetVisible = function(visible, updateVariable)
        if ESPTable.Deleted then return end
        if typeof(visible) ~= "boolean" then return end

        if updateVariable ~= false then 
            ESPTable.Settings.Visible = visible;
        end

        --// Update Instances \\--
        if ESPTable.IsCreatedByDefault ~= true then
            for name, inst in pairs(ESPTable.Instances) do
                if typeof(inst["Update"]) ~= "function" then continue end
                task.spawn(inst.Update, { Visible = visible }, updateVariable)
            end
        end

        setVisibleFunction(ESPTable, visible);
    end

    -- // Create Arrow and Tracer // --
    if createAdditionalInstances == true then
        ESPTable.Instances.Billboard = Library.ESP.Billboard({
            Name = args.Name,
            Model = args.Model,
            TextModel = args.TextModel,
    
            MaxDistance = args.MaxDistance,
            StudsOffset = args.StudsOffset,
            Color = args.TextColor,
    
            IsCreatedByDefault = true,
            ParentElement = ESPTable
        });

        for name, template in pairs(Templates) do
            if typeof(args[name]) == "table" and (name == "Tracer" or name == "Arrow") then
                args[name]                      = Library.Validate(args[name], template)
                args[name].Enabled              = typeof(args[name].Enabled) ~= "boolean" and false or args[name].Enabled

                args[name].Model                = args.Model
                args[name].TextModel            = args.TextModel

                args[name].IsCreatedByDefault   = true
                args[name].ParentElement        = ESPTable
    
                if args[name].Enabled == true then
                    ESPTable.Instances[name] = Library.ESP[name](args[name])
                end
            end
        end
    end

    -- // Return // --
    Library.ESP[tableName][tableIndex] = ESPTable;
    return ESPTable;
end

function Library.ESP.Billboard(args)
    args = validateArgs(args, Templates.Billboard)

    --// Instances \\--
    local GUI = createInstance("BillboardGui", {
        Name = "GUI_" .. args.Name,
        Parent = Library.Folders.Billboards,

        ResetOnSpawn = false,
        Enabled = true,
        AlwaysOnTop = true,

        Size = UDim2.new(0, 200, 0, 50),
        StudsOffset = args.StudsOffset,

        Adornee = args.TextModel
    });

    local Text = createInstance("TextLabel", {
        Parent = GUI,
        Visible = true,

        Name = "Text",
        ZIndex = 0,

        Size = UDim2.new(0, 200, 0, 50),

        FontSize = Enum.FontSize.Size18,
        Font = Enum.Font.RobotoCondensed,

        Text = args.Name,
        TextColor3 = args.Color,
        TextStrokeTransparency = 0,
        TextSize = args.TextSize,

        TextWrapped = true,
        TextWrap = true,
        RichText = true,

        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    });
    createInstance("UIStroke", { Parent = Text });

    local ESPTable = createESP(args, "Billboards", { GUI, Text }, function(ESPTable, newArgs, updateVariable)
        Text.Text       = newArgs.Name;
        Text.TextColor3 = newArgs.Color;
        Text.TextSize   = newArgs.TextSize;
        GUI.Adornee     = newArgs.TextModel or newArgs.Model;
    end, function(ESPTable, visible)
        GUI.Enabled = visible;
    end);

    --// Additional Functions \\--
    ESPTable.GetDistance = function()
        if ESPTable.Deleted or ESPTable.Settings.Model == nil or not ESPTable.Settings.Model:IsDescendantOf(workspace) then return 9e9 end
        return math.round(distanceFromCharacter(ESPTable.Settings.Model))
    end

    ESPTable.SetText = function(text)
        if ESPTable.Deleted then return end

        ESPTable.Update({ Name = text }, true)
    end

    ESPTable.SetDistanceText = function(distance)
        if ESPTable.Deleted then return end
        if typeof(distance) ~= "number" then return end

        if Library.Distance.Enabled == true then
            ESPTable.Update({ Name = string.format("%s\n<font size=\"%d\">[%s]</font>", ESPTable.Settings.Name, ESPTable.Settings.TextSize - 3, distance) }, false)
        else
            ESPTable.Update({ Name = ESPTable.Settings.Name }, false)
        end
    end

    return ESPTable
end

function Library.ESP.Arrow(args)
    args = validateArgs(args, Templates.Arrow)

    -- // Instances // --
    local Arrow = createInstance("ImageLabel", {
        Parent = Library.Folders.GUI,

        Visible = true,

        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        Image = "http://www.roblox.com/asset/?id=16368985219",
        ImageColor3 = args.Color,

        Size = UDim2.new(0, 48, 0, 48),
        SizeConstraint = Enum.SizeConstraint.RelativeYY
    });

    local ESPTable = createESP(args, "Arrows", { Arrow }, function(ESPTable, newArgs, updateVariable)
        Arrow.ImageColor3 = newArgs.Color;
    end, function(ESPTable, visible)
        Arrow.Visible = visible;
    end);

    ESPTable.UpdateArrow = function(rotation, position)
        if ESPTable.Deleted or not Arrow then return; end

        ESPTable.Settings.Rotation = if typeof(rotation) == "number" then rotation else ESPTable.Settings.Rotation;
        ESPTable.Settings.Position = if typeof(position) == "UDim2"  then position else ESPTable.Settings.Position;

        Arrow.Position = ESPTable.Settings.Position or Arrow.Position;
        Arrow.Rotation = ESPTable.Settings.Rotation or Arrow.Rotation;
    end;

    return ESPTable
end

function Library.ESP.Tracer(args)
    args = validateArgs(args, Templates.Tracer)

    if DrawingLib.noDrawing == true then
        local ESPTable = createESP(args, "Tracers", { }, function(...) end, function(...) end)
        ESPTable.Destroy(true)

        return ESPTable -- empty ESPTable
    end

    -- // Instances // --
    local TracerInstance = DrawingLib.new("Line")
    TracerInstance.Color = args.Color;
    TracerInstance.Thickness = args.Thickness;
    TracerInstance.Transparency = args.Transparency;
    TracerInstance.Visible = args.Visible;

    local ESPTable = createESP(args, "Arrows", { TracerInstance }, function(ESPTable, newArgs, updateVariable)
        TracerInstance.Color        = newArgs.Color;
        TracerInstance.Thickness    = newArgs.Thickness
        TracerInstance.Transparency = newArgs.Transparency;
        TracerInstance.Visible      = newArgs.Visible;

        ESPTable.DistancePart = findPrimaryPart(ESPTable.Settings.Model);
    end, function(ESPTable, visible)
        TracerInstance.Visible = visible;
    end);

    ESPTable.DistancePart = findPrimaryPart(ESPTable.Settings.Model);
    ESPTable.UpdateTracer = function(from, to)
        if ESPTable.Deleted then return end

        TracerInstance.From = if typeof(from) == "Vector2" then from else TracerInstance.From;
        TracerInstance.To   = if typeof(to)   == "Vector2" then to else TracerInstance.To;
    end;

    return ESPTable
end

function Library.ESP.Highlight(args)
    args = validateArgs(args, Templates.Highlight)

    -- // Instances // --
    local Highlight = createInstance("Highlight", {
        Parent = Library.Folders.Highlights,

        FillColor = args.FillColor,
        OutlineColor = args.OutlineColor,

        FillTransparency = args.FillTransparency,
        OutlineTransparency = args.OutlineTransparency,

        Adornee = args.Model
    });

    local ESPTable = createESP(args, "Highlight", { Highlight }, function(ESPTable, newArgs, updateVariable)
        Highlight.FillColor     = newArgs.FillColor;
        Highlight.OutlineColor  = newArgs.OutlineColor;
    end, function(ESPTable, visible)
        Highlight.Enabled = visible;
    end, true);

    return ESPTable
end

function Library.ESP.Adornment(args) 
    args = validateArgs(args, Templates.Adornment)

    -- // Instances // --
    local ModelSize;
    if args.Model:IsA("Model") then
        _, ModelSize = args.Model:GetBoundingBox()
    else
        ModelSize = args.Model.Size
    end

    local Adornment; do
        if args.Type == "sphere" then
            Adornment = createInstance("SphereHandleAdornment", {
                Radius = ModelSize.X * 1.085,
                CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0)
            });
        elseif args.Type == "cylinder" then
            Adornment = createInstance("CylinderHandleAdornment", {
                Height = ModelSize.Y * 2,
                Radius = ModelSize.X * 1.085,
                CFrame = CFrame.new() * CFrame.Angles(math.rad(90), 0, 0)
            });
        else
            Adornment = createInstance("BoxHandleAdornment", {
                Size = ModelSize
            });
        end
    end;

    Adornment.Color3 = args.Color;
    Adornment.Transparency = args.Transparency;
    Adornment.AlwaysOnTop = true;
    Adornment.ZIndex = 10;
    Adornment.Adornee = args.Model;
    Adornment.Parent = Library.Folders.Adornments;

    local ESPTable = createESP(args, "Adornment", { Adornment }, function(ESPTable, newArgs, updateVariable)
        Adornment.Color3 = newArgs.FillColor;
    end, function(ESPTable, visible)
        Adornment.Adornee = visible and ESPTable.Settings.Model or nil;
    end, true);

    return ESPTable
end

function Library.ESP.Outline(args)
    args = validateArgs(args, Templates.Outline)

    -- // Instances // --
    local Outline = createInstance("SelectionBox", {
        Parent = Library.Folders.Outlines,

        SurfaceColor3 = args.SurfaceColor,
        Color3 = args.BorderColor,
        LineThickness = args.Thickness,
        SurfaceTransparency = args.Transparency,

        Adornee = args.Model
    });

    local ESPTable = createESP(args, "Outline", { Outline }, function(ESPTable, newArgs, updateVariable)
        Outline.SurfaceColor3       = newArgs.SurfaceColor;
        Outline.Color3              = newArgs.BorderColor;
        Outline.LineThickness       = newArgs.Thickness;
        Outline.SurfaceTransparency = newArgs.Transparency;
    end, function(ESPTable, visible)
        Outline.Adornee = visible and ESPTable.Settings.Model or nil;
    end, true);

    return ESPTable
end

--// Rainbow Handler \\--
Library.Connections.Add(RunService.RenderStepped:Connect(function(Delta)
    Library.Rainbow.Step = Library.Rainbow.Step + Delta

    if Library.Rainbow.Step >= (1 / 60) then
        Library.Rainbow.Step = 0

        Library.Rainbow.HueSetup = Library.Rainbow.HueSetup + (1 / 400);
        if Library.Rainbow.HueSetup > 1 then Library.Rainbow.HueSetup = 0; end;

        Library.Rainbow.Hue = Library.Rainbow.HueSetup;
        Library.Rainbow.Color = Color3.fromHSV(Library.Rainbow.Hue, 0.8, 1);
    end
end), "RainbowStepped", true);

--// Update RenderStepped \\--
local function getVisibility(esp, model, skipScreenCheck)
    --// Screen Check \\--
    local screenPosition, onScreen = worldToViewport(model:GetPivot().Position)
    if onScreen == false and skipScreenCheck ~= true then
        if esp.Hidden == true then return screenPosition, onScreen, false; end
        
        esp.Hidden = true
        esp.SetVisible(false, false)

        return screenPosition, onScreen, false
    end

    --// Distance Check \\--
    local distance = distanceFromCharacter(model)
    local maxDistance = tonumber(esp.Settings.MaxDistance) or 5000;

    if distance > maxDistance then
        if esp.Hidden == true then return screenPosition, onScreen, false; end
        
        esp.Hidden = true
        esp.SetVisible(false, false)

        return screenPosition, onScreen, false
    end

    --// Return \\--
    return screenPosition, onScreen, true
end

Library.Connections.Add(RunService.RenderStepped:Connect(function()
    if not (character and rootPart and camera) then return end

    --// Update Tracers \\--
    if Library.Tracers.Enabled == true then
        for idx, tracer in pairs(Library.ESP.Tracers) do
            local screenPosition, onScreen, wasSetToHidden = getVisibility(tracer, tracer.DistancePart, false);
            if wasSetToHidden or not tracer.Settings.Visible then continue end
            
            if tracer.Hidden == true then
                tracer.Hidden = false
                tracer.SetVisible(true, false)
            end

            if tracer.Settings.From == "mouse" then
                local mousePosition = UserInputService:GetMouseLocation();
                tracer.UpdateTracer(Vector2.new(mousePosition.X, mousePosition.Y), Vector2.new(screenPosition.X, screenPosition.Y))

            elseif tracer.Settings.From == "top" then
                tracer.UpdateTracer(Vector2.new(camera.ViewportSize.X / 2, 0), Vector2.new(screenPosition.X, screenPosition.Y))

            elseif tracer.Settings.From == "center" then
                tracer.UpdateTracer(Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2), Vector2.new(screenPosition.X, screenPosition.Y))

            else
                tracer.UpdateTracer(Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y), Vector2.new(screenPosition.X, screenPosition.Y))
            end

            if tracer.IsCreatedByDefault ~= true then
                tracer.Update({ Color = Library.Rainbow.Enabled and Library.Rainbow.Color or arrow.Settings.Color }, false);
            end
        end
    else
        for idx, tracer in pairs(Library.ESP.Tracers) do
            if tracer.Hidden then continue end

            tracer.Hidden = true
            tracer.SetVisible(false, false)
        end
    end

    -- // Update Arrows // --
    if Library.Arrows.Enabled == true then
        for idx, arrow in pairs(Library.ESP.Arrows) do
            local screenPosition, onScreen, wasSetToHidden = getVisibility(arrow, arrow.Settings.Model, true);
            if wasSetToHidden or not arrow.Settings.Visible then continue end
            
            if arrow.Hidden == true then
                arrow.Hidden = false
                arrow.SetVisible(true, false)
            end

            local screenSize = camera.ViewportSize;
            local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y/2);

            -- use aspect to make oval circle (it's more accurate)
            -- local aspectRatioX = screenSize.X / screenSize.Y;
            -- local aspectRatioY = screenSize.Y / screenSize.X;
            -- local arrowPosPixel = Vector2.new(arrow.ArrowInstance.Position.X.Scale, arrow.ArrowInstance.Position.Y.Scale) * 1000;
            local partPos = Vector2.new(screenPosition.X, screenPosition.Y);

            local IsInverted = screenPosition.Z <= 0;
            local invert = (IsInverted and -1 or 1);

            local direction = (partPos - centerPos);
            local arctan = math.atan2(direction.Y, direction.X);
            local angle = math.deg(arctan) + 90;
            local distance = (arrow.Settings.CenterOffset * 0.001) * screenSize.Y;

            arrow.UpdateArrow(
                angle + 180 * (IsInverted and 0 or 1),
                UDim2.new(
                    0, centerPos.X + (distance * math.cos(arctan) * invert),
                    0, centerPos.Y + (distance * math.sin(arctan) * invert)
                )
            );
            arrow.ArrowInstance.Visible = (onScreen == false);

            if arrow.IsCreatedByDefault ~= true then
                arrow.Update({ Color = Library.Rainbow.Enabled and Library.Rainbow.Color or arrow.Settings.Color }, false);
            end
        end
    else
        for idx, arrow in pairs(Library.ESP.Arrows) do
            if arrow.Hidden then continue end

            arrow.Hidden = true
            arrow.SetVisible(false, false)
        end
    end

    --// Update Billboards \\--
    for espType, storage in pairs(Library.ESP) do
        if typeof(storage) ~= "table" or espType == "Arrows" or espType == "Tracers" then continue end

        for idx, esp in pairs(storage) do
            if typeof(Library[espType]) == "table" and Library[espType].Enabled == true or true then
                local screenPosition, onScreen, wasSetToHidden = getVisibility(esp, esp.Settings.Model, false);
                if wasSetToHidden or not esp.Settings.Visible then continue end
                
                if esp.Hidden == true then
                    esp.Hidden = false
                    esp.SetVisible(true, false)
                end

                if espType == "Billboards" then
                    esp.SetDistanceText(esp.GetDistance());
                end

                esp.Update({
                    Color        = Library.Rainbow.Enabled and Library.Rainbow.Color or esp.Settings.Color,
                    TextColor    = Library.Rainbow.Enabled and Library.Rainbow.Color or esp.Settings.TextColor,
     
                    FillColor    = Library.Rainbow.Enabled and Library.Rainbow.Color or esp.Settings.FillColor,
                    SurfaceColor = Library.Rainbow.Enabled and Library.Rainbow.Color or esp.Settings.SurfaceColor
                }, false);
            else
                if esp.Hidden then continue end

                esp.Hidden = true
                esp.SetVisible(false, false)
            end
        end
    end
end), "MainUpdate", true);

--// Variable Updater \\--
updateVariables()
Library.Connections.Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if workspace.CurrentCamera then camera = workspace.CurrentCamera; end;
end), "CameraUpdate", true);

Library.Connections.Add(localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter;
    rootPart = character:WaitForChild("HumanoidRootPart", 5);
end), "CharacterUpdate", true);

--// Return \\--
getgenv().mstudio45 = getgenv().mstudio45 or { };
getgenv().mstudio45.ESPLibrary = Library;
Library.Print("Loaded! [TEST]");
return Library
