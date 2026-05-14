--!strict
-- Remotes.RemoteManager — Единый менеджер всех RemoteEvent/Function
-- luau-best-practices: Server Authority, Rate Limiting, Validate All Input

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = {}

-- ═══════════════════════════════════════════
-- REMOTE REGISTRY
-- ═══════════════════════════════════════════

-- Server-side handler registry
local _serverHandlers: { [string]: (Player, ...any) -> () } = {}
local _serverInvokeHandlers: { [string]: (Player, ...any) -> ...any } = {}

-- Client-side event references
local _events: { [string]: RemoteEvent } = {}
local _functions: { [string]: RemoteFunction } = {}

-- Rate limiting state: { [player]: { [action]: lastTime } }
local _rateLimits: { [Player]: { [string]: number } } = {}

-- ═══════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════

-- Ensure Remotes folder exists
local function EnsureRemotesFolder(): Folder
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "Remotes"
		remotes.Parent = ReplicatedStorage
	end
	return remotes
end

-- Create a RemoteEvent if it doesn't exist
function RemoteManager.CreateEvent(name: string): RemoteEvent
	local remotes = EnsureRemotesFolder()
	local existing = remotes:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		_events[name] = existing
		return existing
	end

	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
	_events[name] = event
	return event
end

-- Create a RemoteFunction if it doesn't exist
function RemoteManager.CreateFunction(name: string): RemoteFunction
	local remotes = EnsureRemotesFolder()
	local existing = remotes:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		_functions[name] = existing
		return existing
	end

	local func = Instance.new("RemoteFunction")
	func.Name = name
	func.Parent = remotes
	_functions[name] = func
	return func
end

-- ═══════════════════════════════════════════
-- SERVER-SIDE REGISTRATION
-- ═══════════════════════════════════════════

function RemoteManager.OnServerEvent(name: string, handler: (Player, ...any) -> ())
	local event = _events[name]
	if not event then
		event = RemoteManager.CreateEvent(name)
	end
	_serverHandlers[name] = handler
	event.OnServerEvent:Connect(function(player: Player, ...)
		handler(player, ...)
	end)
end

function RemoteManager.OnServerInvoke(name: string, handler: (Player, ...any) -> ...any)
	local func = _functions[name]
	if not func then
		func = RemoteManager.CreateFunction(name)
	end
	_serverInvokeHandlers[name] = handler
	func.OnServerInvoke = function(player: Player, ...)
		return handler(player, ...)
	end
end

-- ═══════════════════════════════════════════
-- RATE LIMITING
-- ═══════════════════════════════════════════

function RemoteManager.CheckRateLimit(player: Player, action: string, cooldown: number): boolean
	if not _rateLimits[player] then
		_rateLimits[player] = {}
	end

	local now = os.clock()
	local last = _rateLimits[player][action] or 0

	if now - last < cooldown then
		return false  -- Rate limited
	end

	_rateLimits[player][action] = now
	return true
end

function RemoteManager.CleanupPlayer(player: Player)
	_rateLimits[player] = nil
end

-- ═══════════════════════════════════════════
-- CLIENT-SIDE API
-- ═══════════════════════════════════════════

local function FindRemote(name: string): RemoteEvent?
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return nil end
	local obj = remotes:FindFirstChild(name)
	if obj and obj:IsA("RemoteEvent") then
		_events[name] = obj
		return obj
	end
	return nil
end

local function FindFunction(name: string): RemoteFunction?
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return nil end
	local obj = remotes:FindFirstChild(name)
	if obj and obj:IsA("RemoteFunction") then
		_functions[name] = obj
		return obj
	end
	return nil
end

-- Client → Server
function RemoteManager.FireServer(name: string, ...: any)
	local event = _events[name] or FindRemote(name)
	if event then
		event:FireServer(...)
	end
end

-- Server → Client (НЕ FireServer!)
function RemoteManager.FireClient(player: Player, name: string, ...: any)
	local event = _events[name] or FindRemote(name)
	if event then
		event:FireClient(player, ...)
	end
end

-- Server → All Clients
function RemoteManager.FireAllClients(name: string, ...: any)
	local event = _events[name] or FindRemote(name)
	if event then
		event:FireAllClients(...)
	end
end

-- Client → Server invoke
function RemoteManager.InvokeServer(name: string, ...: any): ...any
	local func = _functions[name] or FindFunction(name)
	if func then
		return func:InvokeServer(...)
	end
	return nil
end

-- Client event listener
function RemoteManager.OnClientEvent(name: string, callback: (...any) -> ())
	local event = _events[name] or FindRemote(name)
	if event then
		event.OnClientEvent:Connect(callback)
	end
end

-- ═══════════════════════════════════════════
-- GETTERS
-- ═══════════════════════════════════════════

function RemoteManager.GetEvent(name: string): RemoteEvent?
	return _events[name]
end

function RemoteManager.GetFunction(name: string): RemoteFunction?
	return _functions[name]
end

-- ═══════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════

local Players = game:GetService("Players")
Players.PlayerRemoving:Connect(function(player: Player)
	RemoteManager.CleanupPlayer(player)
end)

return RemoteManager
