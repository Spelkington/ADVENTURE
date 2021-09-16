local State = {}
State.__index = State

function State.new(name): State

    local _State = {}
    setmetatable(_State, State)

    _State.name = name
    _State.connections = {}
    _State.functions = {}

    return _State

end

function State:createConnection(
    dest: State,
    action: string,
    func
): nil

    self.connections[action] = dest
    self.functions  [action] = func
    
    return nil

end

function State:sendAction(action): State

    if self.connections[action] then
        -- Execute transition function
        self.functions[action]()
        return self.connections[action]
    end

    return nil

end

return State