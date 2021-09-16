local State = require(game.ReplicatedStorage.Common.State)

local StateMachine = {}
StateMachine.__index = StateMachine
function StateMachine.new(stateTable, stateFolder)

    local _StateMachine = {}
    setmetatable(_StateMachine, StateMachine)

    _StateMachine.states = {}
    _StateMachine.currentState = nil
    _StateMachine.folder = stateFolder

    if stateTable then
        _StateMachine:loadTable(stateTable)
    end

    return _StateMachine

end

--- Adds a new state to the machine
function StateMachine:addState(name)

    self.states[name] = State.new(name)
    
    if not self.currentState then
        self.currentState = self.states[name]
    end

end

--- Sets the machine's state, overriding connections
function StateMachine:setState(name)

    local state = self.states[name]
    assert(
        state, 
        "State " .. name .. " was nil."
    )
    self.currentState = state

end

--- Creates a new connection between machine states, with
--  a function that runs on the switch
function StateMachine:createConnection(
    orig: string,
    dest: string,
    action: string,
    func
): nil

    local origState: State = self.states[orig]
    local destState: State = self.states[dest]

    assert(
        origState,
        "Cannot create connection " .. action .. " to nonexistent node " .. orig
    )

    assert(
        destState,
        "Cannot create connection " .. action .. " to nonexistent node " .. dest
    )

    origState:createConnection(destState, action, func)

end

--- Sends an action to the machine.
function StateMachine:sendAction(action)

    assert(
        self.currentState,
        "Action " .. action .. " was sent to a StateMachine without a state"
    )

    local nextState = self.currentState:sendAction(action)
    if nextState then
        self.currentState = nextState
    end

end

function StateMachine:loadTable(stateTable, func)

    for nodeName, _ in pairs(stateTable) do
        self:addState(nodeName)
    end

    for nodeName, nodeBody in pairs(stateTable) do
        for action, destName in pairs(nodeBody) do
            self:createConnection(
                nodeName,
                destName,
                action,
                function()
                    self.folder.Previous.Value = nodeName
                    self.folder.Current.Value  = destName
                end
            )
        end
    end

end

return StateMachine