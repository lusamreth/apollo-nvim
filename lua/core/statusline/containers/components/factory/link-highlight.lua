-- use to find
local h = import('containers.helper')
local check_if_coupling, stamp = h.check_if_coupling, h.stamp

local function find_range(each_len, pos)
    -- p : is the component number inside the nested linked
    local function determine_slice(p)
        assert(type(p) == 'number')
        END = each_len * p
        START = END - each_len
        assert(END > START, 'end index must be greater than start!')

        if START == 0 then
            START = 1
        end
        return START, END
    end

    if type(pos) == 'table' then
        assert(#pos == 2)
        local s, _ = determine_slice(pos[1])
        local _, e = determine_slice(pos[2])
        return s, e
    else
        return determine_slice(pos)
    end
end

-- require bg-preserver(padding), main-component,
local function make_c_link_binder(each_len, bindfn)
    each_len = each_len or 3

    -- pos mean which component u want to intercept
    -- pos could be number represent single comp or
    -- array represent a range of comps
    return function(linked, pos, config, dir)
        dir = dir or 'right'
        -- algorithm only work with right dir
        -- need to reverse
        local function rev()
            if dir == 'left' then
                Reverse(linked)
            end
        end

        rev()
        local pad = config['padding']
        local main = config['main']
        local preserver = config['preserve'] or false

        local s, e = find_range(each_len, pos)
        -- for _, rl in pairs(linked) do
        for x = s, e - 1 do
            local rl = linked[x]

            if linked[e] ~= nil then
                if check_if_coupling(rl) and preserver ~= false then
                    local pbullet = linked[e][LINKED][2]
                    bindfn(stamp(pbullet), preserver)
                end
            end
            if check_if_coupling(rl) then
                for i, c in pairs(rl[LINKED]) do
                    local select_main = 2
                    if dir == 'left' then
                        select_main = 1
                    end
                    if i == select_main then
                        -- classified as main-component
                        bindfn(stamp(c), main)
                    else
                        -- classified as padding-bullet
                        bindfn(stamp(c), pad)
                    end
                end
            else
                bindfn(rl, main)
            end
        end
        rev()
        -- turn back to normal
        return linked
    end
end

return make_c_link_binder
