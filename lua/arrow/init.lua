local M = {}

local config = require("arrow.config")
local utils = require("arrow.utils")
local ui = require("arrow.ui")
local persist = require("arrow.persist")
local git = require("arrow.git")
local commands = require("arrow.commands")
local save_keys = require("arrow.save_keys")

M.config = {}

function M.setup(opts)
	vim.cmd("highlight default link ArrowFileIndex CursorLineNr")
	vim.cmd("highlight default link ArrowCurrentFile SpecialChar")
	vim.cmd("highlight default link ArrowAction Character")
	vim.cmd("highlight default link ArrowDeleteMode DiagnosticError")

	opts = opts or {}

	local default_mappings = {
		edit = "e",
		delete_mode = "d",
		clear_all_items = "C",
		toggle = "s",
		open_vertical = "v",
		open_horizontal = "-",
		quit = "q",
		remove = "x",
	}

	local default_window_config = {
		relative = "editor",
		width = "auto",
		height = "auto",
		row = "auto",
		col = "auto",
		style = "minimal",
		border = "single",
	}

	config.setState("window", utils.join_two_keys_tables(default_window_config, opts.window or {}))

	local leader_key = opts.leader_key or ";"

	local actions = opts.custom_actions or {}

	config.setState("open_action", actions.open or function(filename, _)
		vim.cmd(string.format(":edit %s", filename))
	end)

	config.setState("vertical_action", actions.split_vertical or function(filename, _)
		vim.cmd(string.format(":vsplit %s", filename))
	end)

	config.setState("horizontal_action", actions.split_horizontal or function(filename, _)
		vim.cmd(string.format(":split %s", filename))
	end)

	config.setState("save_path", opts.save_path or function()
		return vim.fn.stdpath("cache") .. "/arrow"
	end)
	config.setState("leader_key", leader_key)
	config.setState("always_show_path", opts.always_show_path or false)
	config.setState("show_icons", opts.show_icons)
	config.setState("index_keys", opts.index_keys or "123456789zcbnmZXVBNM,afghjklAFGHJKLwrtyuiopWRTYUIOP")
	config.setState("hide_handbook", opts.hide_handbook or false)
	config.setState("separate_by_branch", opts.separate_by_branch or false)
	config.setState("global_bookmarks", opts.global_bookmarks or false)
	config.setState("separate_save_and_remove", opts.separate_save_and_remove or false)

	config.setState("save_key", save_keys[opts.save_key] or save_keys.cwd)
	config.setState("save_key_cached", config.getState("save_key")())

	if leader_key then
		vim.keymap.set("n", leader_key, ui.openMenu, { noremap = true, silent = true })
	end

	local default_full_path_list = {
		"index",
		"main",
		"create",
		"update",
		"upgrade",
		"edit",
		"new",
		"delete",
		"list",
		"view",
		"show",
		"form",
		"controller",
		"service",
		"util",
		"utils",
		"config",
		"constants",
		"consts",
		"test",
		"spec",
		"handler",
		"route",
		"router",
		"run",
		"execute",
		"start",
		"stop",
		"setup",
		"cleanup",
		"init",
		"launch",
		"load",
		"save",
		"read",
		"write",
		"validate",
		"process",
		"handle",
		"parse",
		"format",
		"generate",
		"render",
		"authenticate",
		"authorize",
		"validate",
		"search",
		"filter",
		"sort",
		"paginate",
		"export",
		"import",
		"download",
		"upload",
		"submit",
		"cancel",
		"approve",
		"reject",
		"send",
		"receive",
		"notify",
		"enable",
		"disable",
		"reset",
	}

	config.setState("mappings", utils.join_two_keys_tables(default_mappings, opts.mappings or {}))
	config.setState("full_path_list", utils.join_two_arrays(default_full_path_list, opts.full_path_list or {}))

	persist.load_cache_file()

	vim.api.nvim_create_augroup("arrow", { clear = true })

	vim.api.nvim_create_autocmd({ "DirChanged", "SessionLoadPost" }, {
		callback = function()
			git.refresh_git_branch()
			persist.load_cache_file()
			config.setState("save_key_cached", config.getState("save_key")())
		end,
		desc = "load cache file on DirChanged",
		group = "arrow",
	})

	commands.setup()
end

return M
