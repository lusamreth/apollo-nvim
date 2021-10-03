local available_opt = {
	"o", -- general options
	"bo", -- buffer options
	"wo", -- window options
	"g", -- global options
	"auto", -- you don't know the scope
}

local opts_info = vim.api.nvim_get_all_options_info()
local opt = {}
for _, index in pairs(available_opt) do
	opt[index] = {}
	local function map_closure(scope, key, value)
		local fn = vim.api

		if scope == available_opt[1] then
			return fn.nvim_set_option(key, value)
		elseif scope == available_opt[2] then
			return fn.nvim_buf_set_option(0, key, value)
		elseif scope == available_opt[3] then
			return fn.nvim_win_set_option(0, key, value)
		elseif scope == available_opt[4] then
			vim.g[key] = value

			-- automatically adjust option's scope
		elseif scope == available_opt[5] then
			local option_scope = opts_info[key].scope
			local c = string.sub(option_scope, 1, 1) -- first char
			-- g is an exception
			if c == "g" then
				map_closure(c, key, value)
			else
				map_closure(c .. "o", key, value)
			end
		else
			debug.getinfo(1)
			print("Invalid neovim option! Please try again!")
		end
	end

	setmetatable(opt[index], {
		__newindex = function(self, key, value)
			map_closure(index, key, value)
		end,
	})
end

opt.auto.cmdheight = 3
return opt
