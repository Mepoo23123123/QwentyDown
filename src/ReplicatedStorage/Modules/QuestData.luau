--!strict

local QuestData = {}

export type ObjectiveType = "Kill" | "Collect"

export type QuestObjective = {
	Type: ObjectiveType,
	TargetId: string,
	Required: number,
	Description: string,
}

export type QuestRewardItem = {
	ItemId: string,
	Quantity: number,
}

export type QuestReward = {
	EXP: number?,
	Gold: number?,
	Items: { QuestRewardItem }?,
}

export type QuestDefinition = {
	Id: string,
	Title: string,
	TitleRu: string,
	Description: string,
	NpcId: string,
	Prerequisites: { string }?,
	Objectives: { QuestObjective },
	Rewards: QuestReward,
}

export type QuestNpcDefinition = {
	Id: string,
	Name: string,
	NameRu: string,
	ModelName: string,
	PromptText: string,
	DialogText: string,
	SpawnCFrame: CFrame?,
	Quests: { string },
}

QuestData.NPCs = {
	gojo_quest_master = {
		Id = "gojo_quest_master",
		Name = "Gojo Quest Master",
		NameRu = "Годжо",
		ModelName = "QuestNPC",
		PromptText = "Поговорить",
		DialogText = "Если хочешь стать сильнее, начни с настоящей практики.",
		SpawnCFrame = nil,
		Quests = { "gojo_first_hunt", "gojo_forest_cleanup", "gojo_ruin_trial" },
	},
}

QuestData.Quests = {
	gojo_first_hunt = {
		Id = "gojo_first_hunt",
		Title = "First Hunt",
		TitleRu = "Первая охота",
		Description = "Победи 3 Пустотных клещей у края кладбища.",
		NpcId = "gojo_quest_master",
		Objectives = {
			{ Type = "Kill", TargetId = "HollowMite", Required = 3, Description = "Победить Пустотных клещей" },
		},
		Rewards = {
			EXP = 120,
			Gold = 50,
			Items = {
				{ ItemId = "hollow_mask", Quantity = 2 },
			},
		},
	},
	gojo_forest_cleanup = {
		Id = "gojo_forest_cleanup",
		Title = "Forest Cleanup",
		TitleRu = "Зачистка леса",
		Description = "Победи 2 Лесных грызунов в ране леса.",
		NpcId = "gojo_quest_master",
		Prerequisites = { "gojo_first_hunt" },
		Objectives = {
			{ Type = "Kill", TargetId = "ForestGnawer", Required = 2, Description = "Победить Лесных грызунов" },
		},
		Rewards = {
			EXP = 220,
			Gold = 90,
			Items = {
				{ ItemId = "shinigami_robe", Quantity = 1 },
			},
		},
	},
	gojo_ruin_trial = {
		Id = "gojo_ruin_trial",
		Title = "Ruin Trial",
		TitleRu = "Испытание руин",
		Description = "Победи 1 Стража руин. Это испытание проверит твой урон и выживаемость.",
		NpcId = "gojo_quest_master",
		Prerequisites = { "gojo_forest_cleanup" },
		Objectives = {
			{ Type = "Kill", TargetId = "RuinSentinel", Required = 1, Description = "Победить Стража руин" },
		},
		Rewards = {
			EXP = 420,
			Gold = 180,
			Items = {
				{ ItemId = "reiatsu_shard", Quantity = 2 },
			},
		},
	},
}

function QuestData.GetQuest(questId: string): QuestDefinition?
	return QuestData.Quests[questId]
end

function QuestData.GetNpc(npcId: string): QuestNpcDefinition?
	return QuestData.NPCs[npcId]
end

function QuestData.GetNpcIds(): { string }
	local ids = {}
	for npcId in QuestData.NPCs do
		table.insert(ids, npcId)
	end
	return ids
end

function QuestData.CanAccept(questId: string, completed: { [string]: boolean }): (boolean, string?)
	local quest = QuestData.GetQuest(questId)
	if not quest then
		return false, "Квест не найден."
	end
	if completed[questId] then
		return false, "Квест уже завершён."
	end
	local prerequisites = quest.Prerequisites
	if prerequisites then
		for _, prerequisiteId in prerequisites do
			if not completed[prerequisiteId] then
				return false, "Сначала заверши предыдущий квест."
			end
		end
	end
	return true, nil
end

return QuestData
