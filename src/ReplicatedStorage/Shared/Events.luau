--!strict
-- Shared.Events — Centralized event bus (Signal pattern)
-- luau-best-practices: Minimal Surface Area, Explicit connections

local EventBus = {}

-- Internal storage: { [eventName]: { [id]: connection } }
local _events: { [string]: { [number]: () -> () } } = {}
local _nextId = 0

-- Subscribe to an event
function EventBus.On(eventName: string, callback: (...any) -> ()): () -> ()
	if not _events[eventName] then
		_events[eventName] = {}
	end

	local id = _nextId
	_nextId += 1

	_events[eventName][id] = callback

	-- Return unsubscribe function
	return function()
		if _events[eventName] then
			_events[eventName][id] = nil
		end
	end
end

-- Fire an event to all subscribers
function EventBus.Fire(eventName: string, ...: any)
	local subscribers = _events[eventName]
	if not subscribers then return end

	for _, callback in subscribers do
		task.spawn(callback, ...)
	end
end

-- Clear all subscribers for an event
function EventBus.Clear(eventName: string)
	_events[eventName] = nil
end

-- Clear ALL subscribers
function EventBus.ClearAll()
	table.clear(_events)
	_nextId = 0
end

-- Get subscriber count
function EventBus.Count(eventName: string): number
	local subscribers = _events[eventName]
	if not subscribers then return 0 end

	local count = 0
	for _ in subscribers do count += 1 end
	return count
end

-- ═══════════════════════════════════════════
-- PREDEFINED EVENT NAMES (type-safe)
-- ═══════════════════════════════════════════
EventBus.Events = {
	-- Player lifecycle
	PlayerJoined = "PlayerJoined",
	PlayerLeft = "PlayerLeft",
	CharacterSpawned = "CharacterSpawned",

	-- Combat
	DamageDealt = "DamageDealt",
	EnemyKilled = "EnemyKilled",
	PlayerDied = "PlayerDied",

	-- Skills
	SkillUsed = "SkillUsed",
	BuffApplied = "BuffApplied",
	BuffExpired = "BuffExpired",

	-- Inventory
	ItemAdded = "ItemAdded",
	ItemRemoved = "ItemRemoved",
	ItemEquipped = "ItemEquipped",
	ItemUnequipped = "ItemUnequipped",

	-- Level/Stats
	LevelUp = "LevelUp",
	StatsAllocated = "StatsAllocated",
	StatsUpdated = "StatsUpdated",

	-- Quests
	QuestAccepted = "QuestAccepted",
	QuestProgressed = "QuestProgressed",
	QuestCompleted = "QuestCompleted",
	QuestTurnedIn = "QuestTurnedIn",

	-- Loot
	LootDropped = "LootDropped",
	LootCollected = "LootCollected",

	-- Zone
	ZoneChanged = "ZoneChanged",

	-- Class
	ClassChanged = "ClassChanged",
}

return EventBus
