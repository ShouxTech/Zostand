local Signal = require(script.Parent.Signal);
local Sift = require(script.Parent.Sift);
local React = require(script.Parent.React);
local Utils = require(script.Utils);

local Zostand = {};

function Zostand.create(initialState, createActions)
	local state = initialState;

    local stateChangedSignal = Signal.new();
    local hookStateSetters = {};

    local function get()
        return state;
    end;

	local function set(newState, overwrite: boolean)
        local oldState = state;

		if typeof(newState) == 'function' then
            newState = newState(state);
        end;

        if (typeof(state) == 'table') and (not overwrite) then
            state = Sift.Dictionary.merge(state, newState);
        else
            state = newState;
        end;

        for set, selector in next, hookStateSetters do
            set(if typeof(selector) == 'function' then selector(state) else state);
        end;

        stateChangedSignal:Fire(state, oldState);
	end;

	local actions = createActions(set, get);

	local store = {actions = actions};

    function store.use(selector: ((state: any) -> any)?)
        local hookState, setHookState = React.useState(if selector then selector(state) else state);

        React.useEffect(function()
            hookStateSetters[setHookState] = selector or true;

            return function()
                hookStateSetters[setHookState] = nil;
            end;
        end, {});

        return hookState;
    end;

    -- Returns a Signal for when the selected state changes.
    function store.selectionChanged(selector: (state: any) -> any)
        local signal = Signal.new();

        local stateChangedConnection = stateChangedSignal:Connect(function(newState, oldState)
            newState = selector(newState);
            oldState = selector(oldState);

            if typeof(newState) ~= typeof(oldState) then
                warn(`newState and oldState type mismatch ({typeof(newState)} and {typeof(oldState)})`, debug.traceback());
            end;

            if typeof(newState) == 'table' then
                if (not Utils.ShallowEqual(newState, oldState)) or (newState ~= oldState) then
                    signal:Fire(newState, oldState)
                end;
            else
                if newState ~= oldState then
                    signal:Fire(newState, oldState);
                end;
            end
        end);

        Utils.AttachToSignalDisconnect(signal, function()
            stateChangedConnection:Disconnect();
        end);

        return signal;
    end;

    store.getState = get;

    store.setState = set;

    store.changed = stateChangedSignal;

	return store;
end;

return Zostand;