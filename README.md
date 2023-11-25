# Zostand
A mix of [Zustand](https://github.com/pmndrs/zustand) and personal preferences for state management in Roblox

## Install
Install with [wally](https://wally.run/):\
`Zostand = "shouxtech/zostand@0.1.3"`

## Usage
```lua
local bearStore = Zostand.create(
    {
        bears = 0,
    },
    function(set)
        return {
            increasePopulation = function()
                set(function(state)
                    return { bears = state.bears + 1 };
                end);
            end,
            removeAllBears = function()
                set({ bears = 0 });
            end,
        };
    end
);

bearStore.getState() --> { bears = 0 }
bearStore.actions.increasePopulation();
bearStore.getState() --> { bears = 1 }

bearStore.setState({ bears = 200 });
bearStore.getState() --> { bears = 200 }

bearStore.setState({}); -- By default, setting will merge the passed state. Therefore, this line does nothing.
bearStore.getState() --> { bears = 200 }
bearStore.setState({}, true); -- To bypass the merge and just overwrite instead, pass true to the second parameter.
bearStore.getState() --> {}

-- React:
local function Test(props)
    local bears = bearStore.use(function(state) return state.bears; end);

    return React.createElement('TextButton', {
        Text = 'Bears: ' .. tostring(bears),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(200, 50),
        BackgroundColor3 = Color3.new(1, 1, 1),

        [React.Event.MouseButton1Click] = function()
            bearStore.actions.increasePopulation();
        end
    });
end;
```