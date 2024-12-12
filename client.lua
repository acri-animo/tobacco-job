local _joiner = nil
local _working = false
local _actionLabel = nil
local _actionBaseDur = nil
local _actionAnim = nil
local _finished = false
local _tasks = 0
local _blips = {}
local _blip = nil
local eventHandlers = {}

local _nodes = nil

-- Startup event
AddEventHandler("Labor:Client:Setup", function()
    -- Ped to start job
    PedInteraction:Add("TobaccoJob", `s_m_m_gardener_01`, vector3(-44.946, 2893.854, 59.099), 235.567, 25.0, {
        {
            icon = "seedling",
            text = "Start Job",
            event = "Tobacco:Client:StartJob",
            tempjob = "Tobacco",
            isEnabled = function()
                return not _working
            end,
        },
        {
            icon = "handshake",
            text = "Finish Job",
            event = "Tobacco:Client:TurnIn",
            tempjob = "Tobacco",
            isEnabled = function()
                return _working
            end,
        },
        {
            icon = "hand-holding-circle-dollar",
            text = "Tobacco Exchange ($5 per)",
            event = "Tobacco:Client:Exchange",
        },
    }, 'helmet-safety', 'WORLD_HUMAN_CLIPBOARD') -- icon, animation scenario
end)

-- Dynamic progress bar for tobacco actions
local _doing = false
function DoTobAction(id)
    Progress:ProgressWithTickEvent({
        name = 'tobacco_action',
        duration = (math.random(10) + _actionBaseDur) * 250,
        label = _actionLabel,
        tickrate = 1000,
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
        animation = _actionAnim,
    }, function()
        if not _doing then return end
        if _nodes ~= nil then
            for k, v in ipairs(_nodes) do
                if v.id == id then
                    return
                end
            end
        end
        Progress:Cancel()
    end, function(cancelled)
        _doing = false
        if not cancelled then
            Callbacks:ServerCallback("Tobacco:CompleteNode", id)
        end
    end)
end

------------------
-- Events/Handlers
------------------

RegisterNetEvent("Tobacco:Client:OnDuty", function(joiner, time)
    _joiner = joiner
    DeleteWaypoint()
    SetNewWaypoint(-44.946, 2893.854)
    _blip = Blips:Add("TobaccoStart", "Tobacco Supervisor", { x = -44.946, y = 2893.854, z = 0 }, 480, 2, 1.4)

    eventHandlers["keypress"] = AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
        if _doing then return end
        if _working and not _finished then
            local closest = nil
            for k, v in ipairs(_nodes) do
                local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(v.coords.x, v.coords.y, v.coords.z))
                if dist <= 2.0 then
                    if closest == nil or dist < closest.dist then
                        closest = {
                            dist = dist,
                            point = v,
                        }
                    end
                end
            end

            if closest ~= nil then
                _doing = true
                TaskTurnPedToFaceCoord(LocalPlayer.state.ped, closest.point.coords.x, closest.point.coords.y, closest.point.coords.z, 1.0)
                Citizen.Wait(1000)
                DoTobAction(closest.point.id)
            else
                _doing = false
            end
        end
    end)

    eventHandlers["startup"] = RegisterNetEvent(string.format("Tobacco:Client:%s:Startup", joiner), function(nodes, actionLabel, baseDur, anim)
        Blips:Remove("TobaccoStart")

        if _nodes ~= nil then return end
        _actionLabel = actionLabel
        _actionBaseDur = baseDur
        _actionAnim = anim
        _working = true
        _tasks = 0
        _nodes = nodes

        for k, v in ipairs(_nodes) do
            Blips:Add(string.format("TobaccoNode-%s", v.id), "Tobacco Action", v.coords, 594, 0, 0.8)
        end

        Citizen.CreateThread(function()
            while _working do
                local closest = nil
                for k, v in ipairs(_nodes) do
                    local dist = #(vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z) - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if dist <= 20 then
                        DrawMarker(1, v.coords.x, v.coords.y, v.coords.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 112, 209, 244, 250, false, false, 2, false, false, false, false)
                    end
                end

                Citizen.Wait(5)
            end
        end)
    end)

    eventHandlers["actions"] = RegisterNetEvent(string.format("Tobacco:Client:%s:Action", joiner), function(data)
        for k, v in ipairs(_nodes) do
            if v.id == data then
                Blips:Remove(string.format("TobaccoNode-%s", v.id))
                table.remove(_nodes, k)
                break
            end
        end
    end)

    eventHandlers["return"] = RegisterNetEvent(string.format("Tobacco:Client:%s:EndTobacco", joiner), function()
        _tasks = _tasks + 1
        _nodes = {}
        DeleteWaypoint()
        SetNewWaypoint(-44.946, 2893.854)
        _blip = Blips:Add("TobaccoStart", "Tobacco Supervisor", { x = -44.946, y = 2893.854, z = 0 }, 480, 2, 1.4)
    end)

    eventHandlers["new-task"] = RegisterNetEvent(string.format("Tobacco:Client:%s:NewTask", joiner), function(nodes, actionLabel, baseDur, anim)
        Blips:Remove("TobaccoStart")

        if #_nodes ~= 0 then
            for k, v in ipairs(_nodes) do
                Blips:Remove(string.format("TobaccoNode-%s", v.id))
            end
        end

        _actionLabel = actionLabel
        _actionBaseDur = baseDur
        _actionAnim = anim
        _nodes = nodes
        _tasks = _tasks + 1

        for k, v in ipairs(_nodes) do
            Blips:Add(string.format("TobaccoNode-%s", v.id), "Tobacco Action", v.coords, 594, 0, 0.8)
        end
    end)
end)

-- Turn In/Complete
AddEventHandler("Tobacco:Client:TurnIn", function()
    Callbacks:ServerCallback('Tobacco:TurnIn', _joiner, function(animo)
        if not animo then
            Notification:Error("Unable To Turn In Job")
        end
    end)
end)

-- Start Job
AddEventHandler("Tobacco:Client:StartJob", function()
    Callbacks:ServerCallback('Tobacco:StartJob', _joiner, function(animo)
        if not animo then
            Notification:Error("Unable To Start Job")
        end
    end)
end)

-- Off Duty
RegisterNetEvent("Tobacco:Client:OffDuty", function(time)
    for k, v in pairs(eventHandlers) do
        RemoveEventHandler(v)
    end

    if _nodes ~= nil then
        for k, v in ipairs(_nodes) do
            Blips:Remove(string.format("TobaccoNode-%s", v.id))
        end
    end

    if _blip ~= nil then
        Blips:Remove("TobaccoStart")
    end

    _joiner = nil
    _working = false
    _finished = false
    _blips = {}
    eventHandlers = {}
    _nodes = nil
end)

-- Client side tobacco exchange event
RegisterNetEvent("Tobacco:Client:Exchange")
AddEventHandler("Tobacco:Client:Exchange", function()
    TriggerServerEvent("Tobacco:Server:Exchange")
end)