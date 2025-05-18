-- lang.lua
local zh = import "lang/zh"
local en = import "lang/en"
local all = { zh = zh, en = en }
local current = "zh"
return {
    set = function(l) if all[l] then current = l end end,
    get = function() return all[current] end
}