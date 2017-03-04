--------------------------------------------------------------------------------------------
--- AUTHOR: Keithen
--- GITHUB REPO: https://github.com/Nostrademous/Dota2-FullOverwrite
--------------------------------------------------------------------------------------------

_G._savedEnv = getfenv()
module( "debugging", package.seeall )

local utils = require(GetScriptDirectory() .. "/utility")
local gHeroVar = require( GetScriptDirectory().."/global_hero_data" )

local retreatMode = dofile( GetScriptDirectory().."/modes/retreat" )

local last_draw_time = -500

local bot_states = {}
local team_states = {}

local LINE_HEIGHT = 10
local TITLE_VALUE_DELTA_X = 10

local BOT_STATES_MAX_LINES = 2
local BOT_STATES_X = 1600
local BOT_STATES_Y = 100

local TEAM_STATES_MAX_LINES = 6
local TEAM_STATES_X = 1550
local TEAM_STATES_Y = 400

local function updateBotStates()
    local listAllies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
    for _, ally in pairs(listAllies) do
        if ally:IsBot() and not ally:IsIllusion() and gHeroVar.HasID(ally:GetPlayerID()) then
            local hMyBot = gHeroVar.GetVar(ally:GetPlayerID(), "Self")
            local mode = hMyBot:getCurrentMode()
            local state = mode:GetName()
            if state == "retreat" then 
                state = state .. " " .. mode:PrintReason()
            elseif state == "fight" then
                local target = hMyBot:getHeroVar("Target")
                if utils.ValidTarget(target) then
                    state = state .. " " .. utils.GetHeroName(target)
                end
            elseif state == "roam" then
                local target = hMyBot:getHeroVar("RoamTarget")
                if utils.ValidTarget(target) then
                    state = state .. " " .. utils.GetHeroName(target)
                end
            end
            SetBotState(hMyBot.Name, 1, state)
        end
    end
end

function draw()
    if last_draw_time > GameTime() - 0.010 then return end -- TODO: check actual frame time
    last_draw_time = GameTime()

    updateBotStates()
    
    local y = BOT_STATES_Y
    for name, v in utils.Spairs(bot_states) do
        DebugDrawText( BOT_STATES_X, y, name, 255, 0, 0 )
        for line,text in pairs(v) do
            DebugDrawText( BOT_STATES_X + TITLE_VALUE_DELTA_X, y + line * LINE_HEIGHT, text, 255, 0, 0 )
        end
        y = y + (BOT_STATES_MAX_LINES + 1) * LINE_HEIGHT
    end

    y = TEAM_STATES_Y
    for name, v in utils.Spairs(team_states) do
        DebugDrawText( TEAM_STATES_X, y, name, 255, 0, 0 )
        for line,text in pairs(v) do
            DebugDrawText( TEAM_STATES_X + TITLE_VALUE_DELTA_X, y + line * LINE_HEIGHT, text, 255, 0, 0 )
        end
        y = y + (TEAM_STATES_MAX_LINES + 1) * LINE_HEIGHT
    end
end

function SetBotState(name, line, state)
    if line < 1 or BOT_STATES_MAX_LINES > 2 then return end
    if bot_states[name] == nil then
        bot_states[name] = {}
    end
    bot_states[name][line] = state
end

function SetTeamState(category, line, state)
    if line < 1 or line > TEAM_STATES_MAX_LINES then return end
    if team_states[category] == nil then
        team_states[category] = {}
    end
    team_states[category][line] = state
end

for k,v in pairs( debugging ) do _G._savedEnv[k] = v end
