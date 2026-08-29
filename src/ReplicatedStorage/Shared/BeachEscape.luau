--!strict
-- Shared Gameplay Core for the GeminX Caribbean Beach Escape Obby.
-- Engine-framework-agnostic so it runs both in Roblox Studio and the headless Node harness.
-- All game RULES and STATE live here. Roblox glue lives in ServerScriptService scripts.

export type Vector3 = { x: number, y: number, z: number }

export type ObbyConfig = {
	StartHealth: number,
	CoinValue: number,
	JumpHeight: number,
	CourseName: string,
}

export type CourseNode = {
	Id: string,
	Kind: "spawn" | "platform" | "gap" | "checkpoint" | "hazard_zone" | "boat",
	Position: Vector3,
	Size: Vector3,
	Name: string,
	Hazards: Array<string>,
}

export type PlayerState = {
	Id: string,
	Name: string,
	Health: number,
	Coins: number,
	CheckpointIdx: number,
	Rescued: boolean,
	LastHazardHit: string | nil,
	VictoryTimeSeconds: number | nil,
}

export type HazardHit = {
	kind: string,
	damage: number,
	message: string,
}

local GameConfig: ObbyConfig = {
	StartHealth = 100,
	CoinValue = 25,
	JumpHeight = 7,
	CourseName = "Caribbean Beach Escape",
}

local COURSE: Array<CourseNode> = {
	{ Id = "spawn", Kind = "spawn", Name = "Shipwreck - Spawn Beach", Position = { x = 0, y = 2, z = 120 }, Size = { x = 20, y = 2, z = 20 }, Hazards = {} },
	{ Id = "p1", Kind = "platform", Name = "Palm Bridge", Position = { x = 4, y = 4, z = 104 }, Size = { x = 8, y = 1, z = 8 }, Hazards = {} },
	{ Id = "gap1", Kind = "gap", Name = "Crab Scurry Gap", Position = { x = 4, y = 5, z = 96 }, Size = { x = 8, y = 1, z = 4 }, Hazards = { "crab" } },
	{ Id = "p2", Kind = "platform", Name = "Coral Steps", Position = { x = 5, y = 7, z = 88 }, Size = { x = 9, y = 1, z = 9 }, Hazards = {} },
	{ Id = "cp1", Kind = "checkpoint", Name = "Checkpoint 1 - Beach Hut", Position = { x = 5, y = 9, z = 78 }, Size = { x = 10, y = 2, z = 2 }, Hazards = {} },
	{ Id = "p3", Kind = "platform", Name = "Swinging Palm Trunks", Position = { x = 7, y = 12, z = 68 }, Size = { x = 7, y = 1, z = 7 }, Hazards = {} },
	{ Id = "gap2", Kind = "gap", Name = "Octopus Cove Gap", Position = { x = 7, y = 13, z = 60 }, Size = { x = 7, y = 1, z = 4 }, Hazards = { "octopus" } },
	{ Id = "p4", Kind = "platform", Name = "Treasure Barge", Position = { x = 8, y = 16, z = 50 }, Size = { x = 10, y = 1, z = 10 }, Hazards = {} },
	{ Id = "cp2", Kind = "checkpoint", Name = "Checkpoint 2 - Treasure Chest", Position = { x = 8, y = 18, z = 42 }, Size = { x = 10, y = 2, z = 2 }, Hazards = {} },
	{ Id = "p5", Kind = "platform", Name = "Teetering Docks", Position = { x = 9, y = 21, z = 32 }, Size = { x = 8, y = 1, z = 8 }, Hazards = {} },
	{ Id = "gap3", Kind = "gap", Name = "Pirate Wreck Gap", Position = { x = 9, y = 22, z = 24 }, Size = { x = 8, y = 1, z = 4 }, Hazards = { "pirate" } },
	{ Id = "p6", Kind = "platform", Name = "Cannon Deck", Position = { x = 10, y = 25, z = 16 }, Size = { x = 11, y = 1, z = 11 }, Hazards = {} },
	{ Id = "cp3", Kind = "checkpoint", Name = "Checkpoint 3 - Lighthouse", Position = { x = 10, y = 27, z = 8 }, Size = { x = 10, y = 2, z = 2 }, Hazards = {} },
	{ Id = "boat", Kind = "boat", Name = "The S.S. Rescue Boat", Position = { x = 10, y = 32, z = -6 }, Size = { x = 14, y = 8, z = 22 }, Hazards = {} },
}

local COURSE_BY_ID: { [string]: CourseNode } = {}

for i = 1, #COURSE do
	COURSE_BY_ID[COURSE[i].Id] = COURSE[i]
end

local HAZARD_DAMAGE: { [string]: number } = {
	crab = 15,
	octopus = 30,
	pirate = 25,
	waterfall = 10,
}

local HAZARD_MESSAGES: { [string]: string } = {
	crab = "A killer crab pinched you!",
	octopus = "The giant octopus slammed you!",
	pirate = "A pirate cornered you!",
	waterfall = "You slipped into the tide!",
}

local BeachEscape = {}

function BeachEscape.GetCourse(): Array<CourseNode>
	local out: Array<CourseNode> = {}
	for i = 1, #COURSE do
		table.insert(out, COURSE[i])
	end
	return out
end

function BeachEscape.GetCourseNode(id: string): CourseNode | nil
	return COURSE_BY_ID[id]
end

function BeachEscape.GetConfig(): ObbyConfig
	return {
		StartHealth = GameConfig.StartHealth,
		CoinValue = GameConfig.CoinValue,
		JumpHeight = GameConfig.JumpHeight,
		CourseName = GameConfig.CourseName,
	}
end

function BeachEscape.GetHazard(kind: string): HazardHit | nil
	local damage = HAZARD_DAMAGE[kind]
	if damage == nil then
		return nil
	end
	return {
		kind = kind,
		damage = damage,
		message = HAZARD_MESSAGES[kind] or ("You were hit by " .. kind .. "!"),
	}
end

function BeachEscape.MakePlayerState(id: string, name: string): PlayerState
	return {
		Id = id,
		Name = name,
		Health = GameConfig.StartHealth,
		Coins = 0,
		CheckpointIdx = 1,
		Rescued = false,
		LastHazardHit = nil,
		VictoryTimeSeconds = nil,
	}
end

--- Returns updated state, whether respawn is required, and a message.
function BeachEscape.ApplyHazardHit(state: PlayerState, kind: string): (PlayerState, boolean, string)
	local hazard = BeachEscape.GetHazard(kind)
	if hazard == nil then
		return state, false, "unknown hazard"
	end
	local newHealth = math.max(0, state.Health - hazard.damage)
	state.Health = newHealth
	state.LastHazardHit = kind
	return state, newHealth <= 0, hazard.message
end

function BeachEscape.CollectCoin(state: PlayerState): PlayerState
	local cfg = BeachEscape.GetConfig()
	state.Coins = state.Coins + cfg.CoinValue
	state.Health = math.min(cfg.StartHealth, state.Health + 2)
	return state
end

function BeachEscape.NodeKind(id: string): string | nil
	local node = COURSE_BY_ID[id]
	if node == nil then
		return nil
	end
	return node.Kind
end

function BeachEscape.OnPlayerTouchNode(state: PlayerState, nodeId: string): { NewCheckpointIdx: number, PickedCoin: boolean, Message: string | nil }
	local node = COURSE_BY_ID[nodeId]
	if node == nil then
		return { NewCheckpointIdx = state.CheckpointIdx, PickedCoin = false, Message = nil }
	end

	local pickedCoin = false
	local newIdx = state.CheckpointIdx

	if node.Kind == "checkpoint" then
		for i = state.CheckpointIdx, #COURSE do
			if COURSE[i].Id == node.Id and i > state.CheckpointIdx then
				newIdx = i
			end
		end
	elseif node.Kind == "boat" then
		state.Rescued = true
		return { NewCheckpointIdx = newIdx, PickedCoin = false, Message = "You boarded the rescue boat! ESCAPE COMPLETE!" }
	elseif node.Kind == "gap" then
		return { NewCheckpointIdx = newIdx, PickedCoin = false, Message = node.Name .. ": watch the hazards!" }
	end

	return { NewCheckpointIdx = newIdx, PickedCoin = pickedCoin, Message = nil }
end

function BeachEscape.SpawnForCheckpoint(checkpointIdx: number): Vector3
	local i = math.max(1, math.min(checkpointIdx, #COURSE))
	return {
		x = COURSE[i].Position.x,
		y = COURSE[i].Position.y + 3,
		z = COURSE[i].Position.z,
	}
end

function BeachEscape.HasRescued(state: PlayerState): boolean
	return state.Rescued
end

function BeachEscape.RecordVictory(state: PlayerState, elapsedSeconds: number): PlayerState
	state.Rescued = true
	state.VictoryTimeSeconds = elapsedSeconds
	return state
end

function BeachEscape.SortByCoins(players: Array<PlayerState>): Array<PlayerState>
	local sorted = {}
	for i = 1, #players do
		table.insert(sorted, players[i])
	end
	table.sort(sorted, function(a, b)
		return a.Coins > b.Coins
	end)
	return sorted
end

return BeachEscape
