--if true then  -- Missing 'end' (uncomment to test)
--print("Hello")

local a, b = 1  -- Error: unbalanced-assignments

---@type number
   local myNumber = "This will cause [assign-type-mismatch]."

myGlobal = "This will cause [lowercase-global]."

---@deprecated Please use a more modern function.
local function outdated_function()
    return "This function is deprecated."
end

-- Call the deprecated function to use it.
outdated_function()

-- Hint: Using an unused local variable
-- The language server will hint that `unused_variable` is never used.
local unused_variable = "This variable is not used."
