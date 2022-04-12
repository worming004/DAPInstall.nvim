local M = {}

local dbg_path = require("dap-install.config.settings").options["installation_path"] .. "ccppr_vsc/"
local proxy = require("dap-install.config.settings").options["proxy"]

M.details = {
	dependencies = { "wget", "unzip", "make" },
}

M.dap_info = {
	name_adapter = "cppdbg",
	name_configuration = { "c", "cpp", "rust" },
}

M.config = {
	adapters = {
		type = "executable",
		command = dbg_path .. "extension/debugAdapters/bin/OpenDebugAD7",
	},
	configurations = {
		{
			name = "Launch file",
			type = "cppdbg",
			request = "launch",
			miDebuggerPath = "/usr/bin/gdb",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = true,
      setupCommands = {
        {
          description =  'enable pretty printing',
          text = '-enable-pretty-printing',
          ignoreFailures = false
        },
      },
		},
    {
      name = "Attach process",
      type = "cppdbg",
      request = "attach",
      processId = require('dap.utils').pick_process,
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = "${workspaceFolder}",
      setupCommands = {
      {
          description =  'enable pretty printing',
          text = '-enable-pretty-printing',
          ignoreFailures = false
        },
      },
    },
    {
			name = "Attach to gdbserver :1234",
			type = "cppdbg",
			request = "launch",
			MIMode = "gdb",
			miDebuggerServerAddress = "localhost:1234",
			miDebuggerPath = "/usr/bin/gdb",
			cwd = "${workspaceFolder}",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
      setupCommands = {
        {
          description =  'enable pretty printing',
          text = '-enable-pretty-printing',
          ignoreFailures = false
        },
      },
		},
	},
}

local install_string
if proxy == nil or proxy == "" then
  -- TODO: check os type and download corrsponding vsix
	install_string = [[
		wget $(curl -s https://api.github.com/repos/microsoft/vscode-cpptools/releases/tags/1.7.1 | grep browser_ | cut -d\" -f 4 | grep linux.vsix)
		mv cpptools-linux.vsix cpptools-linux.zip
		unzip cpptools-linux.zip
		chmod +x extension/debugAdapters/bin/OpenDebugAD7
		cp extension/cppdbg.ad7Engine.json extension/debugAdapters/bin/nvim-dap.ad7Engine.json
	]]
else
	install_string = string.format(
  -- TODO: check os type and download corrsponding vsix
		[[
      wget $(curl -s https://api.github.com/repos/microsoft/vscode-cpptools/releases/tags/1.7.1 | grep browser_ | cut -d\" -f 4 | grep linux.vsix)
      mv cpptools-linux.vsix cpptools-linux.zip
      unzip cpptools-linux.zip
      chmod +x extension/debugAdapters/bin/OpenDebugAD7
      cp extension/cppdbg.ad7Engine.json extension/debugAdapters/bin/nvim-dap.ad7Engine.json
    ]],
		proxy,
		proxy
	)
end

M.installer = {
	before = "",
	install = install_string,
	uninstall = "simple",
}

return M
