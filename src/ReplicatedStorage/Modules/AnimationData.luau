--!strict
-- AnimationData — Централизованные анимации для CombatController
-- Все AssetId в одном месте для удобного управления

local AnimationData = {}

-- ═══════════════════════════════════════════
-- COMBO ANIMATIONS (4-stage combo)
-- ═══════════════════════════════════════════
export type ComboAnimId = string

AnimationData.ComboAnims = {
	"rbxassetid://124741142089547", -- Stage 1
	"rbxassetid://76029130501610", -- Stage 2
	"rbxassetid://79638360621010", -- Stage 3
	"rbxassetid://124399048462876", -- Stage 4 (MAX)
} :: { ComboAnimId }

-- ═══════════════════════════════════════════
-- BLOCK ANIMATION
-- ═══════════════════════════════════════════
AnimationData.BlockAnimId = "rbxassetid://83475829304592" :: string

-- ═══════════════════════════════════════════
-- SKILL ANIMATIONS (если понадобятся клиентские фиксы)
-- ═══════════════════════════════════════════
-- AnimationData.SkillAnims: { [string]: string } = {
-- 	some_skill = "rbxassetid://...",
-- }

return AnimationData
