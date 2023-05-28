local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Signal = require(ReplicatedStorage.Src.Packages.Signal);
local Sift = require(ReplicatedStorage.Src.Packages.Sift);

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
            set(selector(state));
        end;

        stateChangedSignal:Fire(state, oldState);
	end;

	local actions = createActions(set, get);

	local store = {actions = actions};

    function store.use(hooks, selector)
        local hookState, setHookState = hooks.useState(selector(state));

        hooks.useEffect(function()
            hookStateSetters[setHookState] = selector;

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
