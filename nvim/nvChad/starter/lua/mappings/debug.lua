local current_file_dir = require("functions.mappings").current_file_dir
local explore_current_file_dir = require("functions.mappings").explore_current_file_dir
local return_to_dashboard = require("functions.mappings").return_to_dashboard
local flick_command = require("functions.scroll-flick").flick_command

local M = {}

M.general = {
    [{"n"}] = {
        ["<leader>ww"] = {function()
            local node = vim.treesitter.get_node()
            if not node then
                return
            end
            local start_row, start_col = node:start()
            local end_row, end_col = node:end_()
            local node_info = {
                type = node:type(),
                start_row = start_row,
                start_col = start_col,
                end_row = end_row,
                end_col = end_col
            }
            print(vim.inspect(node_info))

            if node:type() == "function_declaration" or node:type() == "function" then
                -- Different languages have different structure
                -- Lua: function_declaration has a name as first child
                local name_node = node:named_child(0)
                local func_name = vim.treesitter.get_node_text(name_node, bufnr)
                print("Function name: " .. func_name)
            end

        end, "Print current treesitter node"}
        -- Print out current mode on a delay
        -- ["<leader>m"] = { function()
        --   local timer = vim.loop.new_timer()
        --   local print_timer = vim.loop.new_timer()
        --   local curr_mode  = "n"
        --   timer:start(1000, 0, function ()
        --     curr_mode = vim.api.nvim_get_mode().mode
        --     print("Got mode!!!")
        --     print_timer:start(1000,0, function()
        --       print("Mode is: "..curr_mode)
        --       print_timer:stop()
        --       print_timer:close()
        --     end)
        --     timer:stop()
        --     timer:close()
        --   end)
        -- end
        -- ,
    },
}

return M
