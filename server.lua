local _JOB = "Tobacco"
local _joiners = {}
local _tobacco = {}


AddEventHandler("Labor:Server:Startup", function()
    Reputation:Create("Tobacco", "Tobacco", {
        { label = "Rank 1", value = 1000 },
        { label = "Rank 2", value = 2000 },
        { label = "Rank 3", value = 4000 },
        { label = "Rank 4", value = 10000 },
        { label = "Rank 5", value = 16000 },
        { label = "Rank 6", value = 25000 },
        { label = "Rank 7", value = 35000 },
        { label = "Rank 8", value = 50000 },
        { label = "Rank 9", value = 75000 },
        { label = "Rank 10", value = 100000 },
    }, false)

    -- Start Job Callback
    Callbacks:RegisterServerCallback("Tobacco:StartJob", function(source, data, cb)
        if _tobacco[data] and _tobacco[data].state == 0 then
            _tobacco[data].state = 1
            _tobacco[data].tasks = 0
            _tobacco[data].job = deepcopy(availableTobJobs[1])
            _tobacco[data].nodes = deepcopy(availableTobJobs[1].locationSets[1])

            for _, joiner in ipairs(_tobacco[data].joiners) do
                Labor.Offers:Start(joiner, _JOB, _tobacco[data].job.objective, #_tobacco[data].nodes)
                Labor.Workgroups:SendEvent(
                    joiner,
                    string.format("Tobacco:Client:%s:Startup", joiner),
                    _tobacco[data].nodes,
                    _tobacco[data].job.action,
                    _tobacco[data].job.durationBase,
                    _tobacco[data].job.animation
                )
            end

            cb(true)
        else
            cb(false)
        end
    end)

    -- Complete Node Callback
    Callbacks:RegisterServerCallback("Tobacco:CompleteNode", function(source, data, cb)
        local char = Fetch:CharacterSource(source)
        if _tobacco[_joiners[source]] and char:GetData("TempJob") == _JOB then
            for k, v in ipairs(_tobacco[_joiners[source]].nodes) do
                if v.id == data then
                    if _tobacco[_joiners[source]].tasks == 0 then
                        -- Picking tobacco
                        Inventory:AddItem(char:GetData("SID"), "wet_tobacco", 5, {}, 1)
                    elseif _tobacco[_joiners[source]].tasks == 1 then
                        -- Drying tobacco
                        local wetTobaccoCount = Inventory.Items:GetCount(char:GetData("SID"), 1, "wet_tobacco") or 0
                        if wetTobaccoCount >= 5 then
                            Inventory.Items:Remove(char:GetData("SID"), 1, "wet_tobacco", 5)
                            Inventory:AddItem(char:GetData("SID"), "dry_tobacco", 5, {}, 1)
                        end
                    elseif _tobacco[_joiners[source]].tasks == 2 then
                        -- Processing tobacco
                        local driedTobaccoCount = Inventory.Items:GetCount(char:GetData("SID"), 1, "dry_tobacco") or 0
                        if driedTobaccoCount >= 5 then
                            Inventory.Items:Remove(char:GetData("SID"), 1, "dry_tobacco", 5)
                            Inventory:AddItem(char:GetData("SID"), "tobacco", math.random(3, 6), {}, 1)
                        end
                    end

                    for _, joiner in ipairs(_tobacco[_joiners[source]].joiners) do
                        Labor.Workgroups:SendEvent(
                            joiner,
                            string.format("Tobacco:Client:%s:Action", joiner),
                            data
                        )
                    end

                    table.remove(_tobacco[_joiners[source]].nodes, k)

                    if Labor.Offers:Update(_joiners[source], _JOB, 1, true) then
                        _tobacco[_joiners[source]].tasks = _tobacco[_joiners[source]].tasks + 1

                        if _tobacco[_joiners[source]].tasks == 1 then
                            StartNextPhase("Dry the Tobacco", "Drying", _joiners[source], 2)
                        elseif _tobacco[_joiners[source]].tasks == 2 then
                            StartNextPhase("Process the Tobacco", "Processing", _joiners[source], 3)
                        else
                            EndTobaccoJob(_joiners[source])
                        end
                    end
                    return
                end
            end
        end
    end)

    -- Turn in Callback
    Callbacks:RegisterServerCallback("Tobacco:TurnIn", function(source, data, cb)
        if _joiners[source] ~= nil and _tobacco[_joiners[source]].tasks == 3 then
            _tobacco[_joiners[source]].state = 3
    
            for _, joiner in ipairs(_tobacco[_joiners[source]].joiners) do
                local joinerChar = Fetch:CharacterSource(joiner)
                Inventory:AddItem(joinerChar:GetData("SID"), "tobacco", math.random(15,25), {}, 1)
                Labor.Offers:ManualFinish(joiner, _JOB)
                Execute:Client(joiner, "Notification", "Success", "Job Completed!")
            end
    
            cb(true)
        else
            Execute:Client(source, "Notification", "Error", "Unable To Complete Job")
            cb(false)
        end
    end)    
end)

------------
-- Functions
------------

-- Job phase transition function
function StartNextPhase(objective, action, joiner, phase)
    _tobacco[joiner].job = deepcopy(availableTobJobs[phase])
    _tobacco[joiner].nodes = deepcopy(availableTobJobs[phase].locationSets[1])

    for _, member in ipairs(_tobacco[joiner].joiners) do
        Labor.Offers:Start(member, _JOB, objective, #_tobacco[joiner].nodes)
        Labor.Workgroups:SendEvent(
            member,
            string.format("Tobacco:Client:%s:NewTask", member),
            _tobacco[joiner].nodes,
            action,
            _tobacco[joiner].job.durationBase,
            _tobacco[joiner].job.animation
        )
    end
end

-- Job completion function
function EndTobaccoJob(joiner)
    for _, member in ipairs(_tobacco[joiner].joiners) do
        Labor.Workgroups:SendEvent(member, string.format("Tobacco:Client:%s:EndTobacco", member))
    end
    _tobacco[joiner].state = 2
    Labor.Offers:Task(joiner, _JOB, "Return to the Tobacco Supervisor")
end

----------------------
-- Net Events/Handlers
----------------------

-- On Duty Event
AddEventHandler("Tobacco:Server:OnDuty", function(joiner, members)
    _joiners[joiner] = joiner
    _tobacco[joiner] = { joiner = joiner, joiners = { joiner }, state = 0 }

    if members and #members > 0 then
        for _, member in ipairs(members) do
            table.insert(_tobacco[joiner].joiners, member.ID)
            _joiners[member.ID] = joiner
        end
    end

    local char = Fetch:CharacterSource(joiner)
    char:SetData("TempJob", _JOB)
    Phone.Notification:Add(joiner, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
    TriggerClientEvent("Tobacco:Client:OnDuty", joiner, joiner, os.time())

    Labor.Offers:Task(joiner, _JOB, "Speak With The Tobacco Supervisor")

    for _, member in ipairs(_tobacco[joiner].joiners) do
        local memberChar = Fetch:CharacterSource(member)
        memberChar:SetData("TempJob", _JOB)
        Phone.Notification:Add(member, "Job Activity", "You started a job", os.time(), 6000, "labor", {})
        TriggerClientEvent("Tobacco:Client:OnDuty", member, joiner, os.time())
    end
end)

AddEventHandler("Tobacco:Server:OffDuty", function(source, joiner)
	_joiners[source] = nil
	TriggerClientEvent("Tobacco:Client:OffDuty", source)
end)

AddEventHandler("Tobacco:Server:FinishJob", function(joiner)
    _tobacco[joiner] = nil
end)


-- Tobacco exchange for cash
RegisterNetEvent("Tobacco:Server:Exchange")
AddEventHandler("Tobacco:Server:Exchange", function()
    local source = source
    local char = Fetch:CharacterSource(source)
    
    if not char then
        Execute:Client(source, "Notification", "Error", "Character data could not be retrieved.")
        return
    end

    local tobaccoCount = Inventory.Items:GetCount(char:GetData("SID"), 1, "tobacco") or 0

    if tobaccoCount > 0 then
        Inventory.Items:Remove(char:GetData("SID"), 1, "tobacco", tobaccoCount)
        Wallet:Modify(source, tobaccoCount * 5) 
    else
        Execute:Client(source, "Notification", "Error", "You don't have any tobacco to exchange.")
    end
end)