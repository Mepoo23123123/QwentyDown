--!strict
-- Shared.Util — Общие утилиты (DRY: eliminiate duplication across modules)
-- luau-best-practices: Small functions, explicit > implicit

local Players = game:GetService("Players")

local Util = {}

-- ═══════════════════════════════════════════
-- HUMANOID ROOT PART HELPERS
-- ═══════════════════════════════════════════

function Util.GetHRP(character: Model?): BasePart?
	return character and character:FindFirstChild("HumanoidRootPart")
end

function Util.GetPlayerHRP(player: Player): BasePart?
	return Util.GetHRP(player.Character)
end

-- ═══════════════════════════════════════════
-- STATS HELPERS
-- ═══════════════════════════════════════════

function Util.GetStatsFolder(player: Player): Folder?
	return player:FindFirstChild("Stats")
end

function Util.GetModelStats(model: Model): Folder?
	return model:FindFirstChild("Stats")
end

function Util.GetTargetStats(target: Model | Player): Folder?
	if not target then return nil end
	if target:IsA("Player") then
		return Util.GetStatsFolder(target :: Player)
	end
	return Util.GetModelStats(target :: Model)
end

-- ═══════════════════════════════════════════
-- DISTANCE & POSITION
-- ═══════════════════════════════════════════

function Util.Distance(a: Vector3, b: Vector3): number
	return (a - b).Magnitude
end

function Util.IsInRange(a: Vector3, b: Vector3, range: number): boolean
	return Util.Distance(a, b) <= range
end

function Util.Direction(from: Vector3, to: Vector3): Vector3
	return (to - from).Unit
end

-- Dot product for facing check
function Util.IsFacing(lookDir: Vector3, targetDir: Vector3, minDot: number?): boolean
	return lookDir:Dot(targetDir) >= (minDot or -0.3)
end

-- ═══════════════════════════════════════════
-- VALIDATION HELPERS
-- ═══════════════════════════════════════════

function Util.IsNumber(val: any): boolean
	return typeof(val) == "number" and not math.isnan(val)
end

function Util.ClampNumber(val: number, min: number, max: number): number
	return math.clamp(val, min, max)
end

function Util.ValidateString(val: any): string?
	if typeof(val) == "string" and #val > 0 then
		return val
	end
	return nil
end

-- ═══════════════════════════════════════════
-- TABLE UTILITIES
-- ═══════════════════════════════════════════

-- Deep copy a table
function Util.DeepCopy(t: { any }): { any }
	local copy: { any } = {}
	for k, v in t do
		if typeof(v) == "table" then
			copy[k] = Util.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Merge two tables (shallow)
function Util.Merge<T>(default: { T }, override: { T }): { T }
	local result: { T } = table.clone(default)
	for k, v in override do
		result[k] = v
	end
	return result
end

-- Create array from table values
function Util.Values<T>(t: { [any]: T }): { T }
	local result: { T } = table.create(#t)
	for _, v in t do
		table.insert(result, v)
	end
	return result
end

-- Check if table is empty
function Util.IsEmpty(t: { any }): boolean
	return next(t) == nil
end

-- Count table entries
function Util.Count(t: { any }): number
	local count = 0
	for _ in t do count += 1 end
	return count
end

-- ═══════════════════════════════════════════
-- MAID / JANITOR (Lightweight)
-- ═══════════════════════════════════════════

export type Maid = {
	GiveTask: (self: Maid, task: Types.MaidTask) -> (),
	Cleanup: (self: Maid) -> (),
	Destroy: (self: Maid) -> (),
}

local Maid = {}
Maid.__index = Maid

function Maid.new(): Maid
	return setmetatable({ _tasks = {} }, Maid) :: Maid
end

function Maid:GiveTask(task: Types.MaidTask)
	if not task then return end
	table.insert(self._tasks, task)
end

function Maid:Cleanup()
	for _, task in self._tasks do
		if typeof(task) == "RBXScriptConnection" then
			(task :: RBXScriptConnection):Disconnect()
		elseif typeof(task) == "Instance" then
			(task :: Instance):Destroy()
		elseif typeof(task) == "function" then
			(task :: () -> ())()
		elseif typeof(task) == "table" and task.destroy then
			(task :: any):destroy()
		end
	end
	table.clear(self._tasks)
end

Maid.Destroy = Maid.Cleanup

Util.Maid = Maid

-- ═══════════════════════════════════════════
-- RESULT HELPERS
-- ═══════════════════════════════════════════

function Util.Ok<T>(value: T): Types.ResultSuccess<T>
	return { ok = true, value = value }
end

function Util.Err<E>(error: E): Types.ResultError
	return { ok = false, error = tostring(error) }
end

function Util.Try<T>(fn: () -> T): Types.Result<T>
	local success, result = pcall(fn)
	if success then
		return Util.Ok(result)
	end
	return Util.Err(result)
end

-- ═══════════════════════════════════════════
-- LOGGING
-- ═══════════════════════════════════════════

function Util.Log(tag: string, msg: string)
	print(string.format("[%s] %s", tag, msg))
end

function Util.Warn(tag: string, msg: string)
	warn(string.format("[%s] %s", tag, msg))
end

function Util.Assert(condition: boolean, msg: string)
	assert(condition, string.format("[ASSERT] %s", msg))
end

-- Localize builtins for performance (luau-type-expert)
Util.max = math.max
Util.min = math.min
Util.clamp = math.clamp
Util.floor = math.floor
Util.ceil = math.ceil
Util.abs = math.abs

return Util
