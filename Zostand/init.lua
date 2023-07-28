local Signal = require(script.Parent.Parent.Signal);
local Sift = require(script.Parent.Parent.Sift);
local React = require(script.Parent.Parent.React);

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
            set(typeof(selector) == 'function' and selector(state) or state);
        end;

        stateChangedSignal:Fire(state, oldState);
	end;

	local actions = createActions(set, get);

	local store = {actions = actions};

    function store.use(selector)
        local hookState, setHookState = React.useState(selector and selector(state) or state);

        React.useEffect(function()
            hookStateSetters[setHookState] = selector or true;

            return function()
                hookStateSetters[setHookState] = nil;
            end;
        end, {});

        return hookState;
    end;

    store.getState = get;

    store.setState = set;

    store.changed = stateChangedSignal;

	return store;
end;

return Zostand;