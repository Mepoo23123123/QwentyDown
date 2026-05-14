--!strict
-- Shared.Constants — Все константы проекта (single source of truth)
-- luau-best-practices: SCREAMING_SNAKE_CASE, no magic numbers

local Types = require(script.Parent.Types)

local Constants = {}

-- ═══════════════════════════════════════════
-- COMBAT CONSTANTS
-- ═══════════════════════════════════════════
Constants.COMBO_MAX = 4
Constants.COMBO_TIMEOUT = 1.5
Constants.COMBO_COOLDOWN = 0.6
Constants.DAMAGE_PER_HIT = { 25, 35, 50, 100 }  -- % от base damage
Constants.BACKSTAB_MULT = 1.5
Constants.AIR_DAMAGE_MULT = 1.3

-- Knockback
Constants.BASE_KB = 30
Constants.CRITICAL_KB = 50
Constants.HIT_STUN = 0.2
Constants.CRITICAL_STUN = 0.4
Constants.KNOCKDOWN_STUN = 0.6

-- Dash
Constants.DASH_COOLDOWN = 3.0
Constants.DASH_SPEED = 80
Constants.DASH_STUN = 0.15

-- Regen
Constants.HP_REGEN_INTERVAL = 2
Constants.HP_REGEN_AMOUNT = 5
Constants.MP_REGEN_BASE = 2
Constants.MP_REGEN_INT_MULT = 0.5


Constants.OUTCOMES = {
	hit = { knockback = false, stun = false },
	crit = { knockback = true, stun = true },
	blocked = { knockback = false, stun = false },
	knockdown = { knockback = true, stun = true },
	skill = { knockback = false, stun = false },
}

-- ═══════════════════════════════════════════
-- LOOT CONSTANTS
-- ═══════════════════════════════════════════
Constants.LOOT_COLLECT_RADIUS = 5
Constants.LOOT_SERVER_BUFFER = 3
Constants.LOOT_COLLECT_INTERVAL = 0.5
Constants.LOOT_LIFETIME = 120
Constants.LOOT_FLOAT_HEIGHT = 3

-- ═══════════════════════════════════════════
-- INVENTORY CONSTANTS
-- ═══════════════════════════════════════════
Constants.MAX_INVENTORY_SLOTS = 30
Constants.MAX_STACK_SIZE = 99
Constants.EQUIPMENT_SLOTS = { "Weapon", "Armor", "Accessory" }

-- ═══════════════════════════════════════════
-- CRAFTING CONSTANTS
-- ═══════════════════════════════════════════
Constants.CRAFT_COOLDOWN = 0.5

-- ═══════════════════════════════════════════
-- QUEST CONSTANTS
-- ═══════════════════════════════════════════
Constants.MAX_ACTIVE_QUESTS = 5
Constants.QUEST_ACCEPT_COOLDOWN = 1.0
Constants.QUEST_MIN_DISTANCE = 15  -- studs для accept quest

-- ═══════════════════════════════════════════
-- SPAWN CONSTANTS
-- ═══════════════════════════════════════════
Constants.SPAWN_FOLDER_NAME = "SpawnedEnemies"
Constants.SPAWN_INIT_DELAY = 5
Constants.SPAWN_LOOP_INTERVAL = 3
Constants.EXP_SHARE_RANGE = 30  -- studs для получения EXP

-- ═══════════════════════════════════════════
-- RATE LIMITING
-- ═══════════════════════════════════════════
Constants.RATE_LIMIT_COMBAT = 0.1    -- 10 requests/sec
Constants.RATE_LIMIT_SKILL = 0.2     -- 5 requests/sec
Constants.RATE_LIMIT_LOOT = 0.1      -- 10 requests/sec
Constants.RATE_LIMIT_QUEST = 0.5     -- 2 requests/sec

-- ═══════════════════════════════════════════
-- DATASTORE CONSTANTS
-- ═══════════════════════════════════════════
Constants.DATASTORE_PLAYER_KEY = "PlayerData_v2"
Constants.DATASTORE_INVENTORY_KEY = "_inventory"
Constants.DATASTORE_AUTOSAVE_INTERVAL = 120  -- seconds
Constants.DATASTORE_MAX_RETRIES = 3
Constants.DATASTORE_RETRY_DELAY = 1

-- ═══════════════════════════════════════════
-- GUI CONSTANTS
-- ═══════════════════════════════════════════
Constants.GUI_DISPLAY_ORDER_HUD = 100
Constants.GUI_DISPLAY_ORDER_MENU = 200
Constants.GUI_DISPLAY_ORDER_NOTIF = 300
Constants.GUI_ZINDEX_SIBLING = Enum.ZIndexBehavior.Sibling

-- Animation timings
Constants.ANIM_UI_OPEN = 0.3
Constants.ANIM_UI_CLOSE = 0.25
Constants.ANIM_TWEEN_DEFAULT = 0.2

-- ═══════════════════════════════════════════
-- DEBUG
-- ═══════════════════════════════════════════
Constants.DEBUG_MODE = game:GetService("RunService"):IsStudio()

return Constants
