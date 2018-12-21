local StringUtils = {}

--- Asserts whether the target is in range of low and high bytes, inclusive.
-- @tparam string target A single letter string to compute against
-- @tparam string low A single letter string to compute for lower bound
-- @tparam string high A single letter string to compute for higher bound
-- @treturn bool true if target in range of low and high, inclusive, otherwise false
function StringUtils.is_in_range(target, low, high)
  -- return false, if nil, because these throws an error if we index on it
  if target == nil or low == nil or high == nil then
    return false
  end

  -- return false, if empty, because comparing a nil with a number value is an error from (""):byte() returning nil
  if target == "" or low == "" or high == "" then
    return false
  end

  return (low:byte() <= target:byte()) and (high:byte() >= target:byte())
end

function StringUtils.is_lowercase(t)
  return StringUtils.is_in_range(t, "a", "z")
end

function StringUtils.is_uppercase(t)
  return StringUtils.is_in_range(t, "A", "Z")
end

function StringUtils.is_digit(t)
  return StringUtils.is_in_range(t, "0", "9")
end

return StringUtils
