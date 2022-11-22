-- 数据
local ChromieSorts = {}
-- 配置
local options = {
	BADGES = 739,
	WALLET = 738,
	BUFF_SPD = 742, 
	BUFF_DMG = 748, 
	BUFF_DEF = 741, 
	BUFF_REP = 737, 
	TIME_30 = 746,
	TIME_20 = 745,
	TIME_10 = 743,
	REP_200 = 736,
	REP_100 = 735,
	REP_50 = 734,
	KEEPSAKE = 740,
	DRAKE = 744,
}
local chromiePrioTable = {
	[options.BADGES] = 300,
	[options.WALLET] = 200,
	[options.BUFF_SPD] = 160,
	[options.BUFF_DMG] = 150,
	[options.BUFF_DEF] = 140,
	[options.TIME_10] = 110,
	[options.TIME_20] = 23,
	[options.TIME_30] = 22,
	[options.REP_50] = 21,
	[options.REP_100] = 13,
	[options.REP_200] = 12,
	[options.BUFF_REP] = 11,
	[options.KEEPSAKE] = -10,
	[options.DRAKE] = -100
}

local function GetChoicePriority(choiceID)
	local prio = ChromieSorts and ChromieSorts[choiceID] or chromiePrioTable[choiceID]
	if prio == nil then return 0 end
	return prio
end
local function ChoiceResponse(Choice)
	C_PlayerChoice.SendPlayerChoiceResponse(Choice.buttons[1].id)
	ClosePlayerChoice()
end

--setup slash commands
SLASH_CHROMIE1 = "/chromie"
SlashCmdList["CHROMIE"] = function(msg)
	if msg == '' then
		local cInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo()
		if (cInfo == nil or cInfo.choiceID ~= 306) then return end
		local info1 = cInfo.options[1]
		local info2 = cInfo.options[2]
		if(info2 == nil) then
			if info1.id == options.DRAKE then return end
			return ChoiceResponse(info1)
		end
		local prio1 = GetChoicePriority(info1.id)
		local prio2 = GetChoicePriority(info2.id)
		if ((prio1 == 0) or (prio2 == 0)) then return end
		if prio1 > prio2 then
			ChoiceResponse(info1)
		else
			ChoiceResponse(info2)
		end
	else
		for k, v in string.gmatch(msg, "(%a+)%W*(%d*)" ) do
			if options[k] ~= nil then
				if not ChromieSorts then ChromieSorts = {} end
				local value = tonumber(v) or 10000
				ChromieSorts[k] = value
			end
		end
	end
end