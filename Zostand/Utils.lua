local Signal = require(script.Parent.Parent.Signal);

local Utils = {};

function Utils.ShallowEqual(a, b)
	if a == nil then
		return b == nil;
	elseif b == nil then
		return a == nil;
	end;

	for key, value in a do
		if value ~= b[key] then
			return false;
		end;
	end;

	for key, value in b do
		if value ~= a[key] then
			return false;
		end;
	end;

	return true;
end;

-- Extend functionality of Signal.Disconnect
function Utils.AttachToSignalDisconnect(signal: Signal.Signal, callback: () -> ())
    local oldConnect = signal.Connect;

	signal.Connect = function(...) -- First, hooking the Connect method to obtain the connection object.
		local connection = oldConnect(...);

		local oldDisconnect = connection.Disconnect;
		connection.Disconnect = function(...) -- Then, hooking the Disconnect method on the connection object.
			callback();

			return oldDisconnect(...);
		end;

		return connection;
	end;
end;

return Utils;