-- =====================================================
-- lang.lua - 语言管理器
-- =====================================================

-- ===== 语言包导入区域 =====
local zh = import "lang/zh"
local en = import "lang/en"
local all = { zh = zh, en = en }
local current = "zh"

-- ===== 语言管理接口区域 =====
return {
    -- --- 设置当前语言 ---
    set = function(l) 
        if all[l] then 
            current = l 
        end 
    end,
    
    -- --- 获取当前语言包 ---
    get = function() 
        return all[current] 
    end
}