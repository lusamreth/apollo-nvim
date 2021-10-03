I = {}

function I.initstash()
    local stash, m = {}, {}
    function m.init(addrs)
        return function()
            return stash[addrs]
        end
    end

    function m.setbg(addrs, val)
        stash[addrs] = val
    end
    return m
end

StatusLine = {}
-- kind mean active or inactive, or shortlist_bar
function StatusLine:init(pres, pos, o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    StatlusLineTree = {}
    -- now accept left right array
    for _, p in pairs(pos) do
        StatlusLineTree[p] = {}
        self[p] = function(comp_arr)
            for _, comp in pairs(comp_arr) do
                table.insert(StatlusLineTree[p], comp)
            end
        end
    end

    self.tree = StatlusLineTree
    self.presenter = pres
    return self
end

function StatusLine:endhook(f)
    self.endhook = f or nil
    return self
end

function StatusLine:run()
    for pos, sec in pairs(self.tree) do
        local view = self.presenter.make_view_binder(pos)
        for _, comp in pairs(sec) do
            view(comp)
        end
    end
    if self.endhook then
        self.endhook()
    end
end

I.StatusLine = StatusLine

return I
