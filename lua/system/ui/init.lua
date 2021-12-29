local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local utils = access_system("ui.utils")

ResizerStack = {}
ResizeCmds = {}

-- window become responsive to size changes ! Store resize_func in stack
-- and command reactive to resize in Cmds
-- Only position with percentage value will react to this resize hook!
local function make_resizer(popup_instance, generate_instance, hook)
    Resizer = function()
        local wid_cache = nil
        local function close()
            wid_cache = popup_instance.winid
            local s, _ = pcall(vim.api.nvim_win_close, wid_cache, true)
            assert(s, "cannot identify window id!")
        end

        local success, _ = pcall(close)
        -- print("Closesucc", success, popup_instance.winid)
        if not success then
            return
        end

        popup_instance = generate_instance()
        hook.replace_and_open(popup_instance)
        popup_instance:on(event.VimResized, Resizer)
    end

    local resizer_id = "resize_" .. RandomString(5)
    ResizerStack[resizer_id] = Resizer

    local call = string.format(":lua ResizerStack['%s']()", resizer_id)
    local resize_event = "VimResized * "
    table.insert(ResizeCmds, {resize_event, call})
end

ProtoPopup = {}

local function open_popup(class)
    class.popup:mount()
    local buf = class.popup.bufnr
    local highlighter = MakeHighlighBorder(class.text_obj, class.border_config["color"])
    local text = class.text_obj["lines"]

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
    highlighter(buf)
end

local function create_resize_hook(class)
    M = {}
    M.replace_and_open = function(newpopup)
        class.popup = newpopup
        open_popup(class)
    end
    return M
end

local function close_popup(class)
    class.popup:unmount()
end
local function init_raw_popup(text_obj, config, class)
    local self = setmetatable({}, class or {})
    local popup
    local fit_size = utils.calculate_fit(text_obj)
    local default = {
        enter = false,
        focusable = true,
        size = fit_size,
        relative = "editor",
        position = {
            col = "0",
            row = "0"
        }
    }

    config = config or {}
    for name, val in pairs(default) do
        default[name] = config[name] or val
    end

    popup = Popup(default)

    -- local newbuf = vim.api.nvim_create_buf(false, true)
    -- vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, text_obj["lines"])
    self.text_obj = text_obj
    self.popup = popup
    self.border_config = text_obj["border_config"]

    -- self.buffer = newbuf

    return self
end

function SetOption(options, selection)
    local function set(option, setter)
        for optname, val in pairs(option) do
            setter(optname, val)
        end
    end

    for kind, option in pairs(options) do
        local selected
        selected = selection[kind]

        -- if selected == nil then
        --     error("Cannot set option! Could be either win or buf!", 2)
        -- end
        local setter = function(kindopt, val)
            return vim.api["nvim_" .. kind .. "_set_option"](selected, kindopt, val)
        end
        set(option, setter)
    end
end

function CreatePopup(obj, config)
    local pop = init_raw_popup(obj, config)

    make_resizer(
        pop.popup,
        function()
            local p = init_raw_popup(obj, config)
            return p.popup
        end,
        create_resize_hook(pop)
    )

    State = true
    -- open_popup(Pop)
    M = {
        open = function(time)
            if time then
                local close_timer = vim.loop.new_timer()
                close_timer:start(
                    time,
                    0,
                    vim.schedule_wrap(
                        function()
                            M.close()
                        end
                    )
                )
            end
            open_popup(pop)
        end,
        close = function()
            close_popup(pop)
        end,
        toggle = function()
            if State then
                open_popup(pop)
            else
                close_popup(pop)
            end
            State = not State
        end
    }

    -- Initialize the produced Command!!!
    Create_augroup(ResizeCmds, RandomString(5))
    return M
end

local tobj = access_system("ui.text_obj")
return {
    text = tobj,
    utils = utils,
    win = {
        CreatePopup = CreatePopup
    }
}
