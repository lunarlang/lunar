local StringUtils = {}
function StringUtils.is_in_range(target, low, high)
  if target == nil or low == nil or high == nil then
    return false
  end
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
function StringUtils.is_letter(t)
  return StringUtils.is_uppercase(t) or StringUtils.is_lowercase(t)
end
function StringUtils.is_digit(t)
  return StringUtils.is_in_range(t, "0", "9")
end
function StringUtils.unprefix(str, prefix)
  if str:sub(1, (#prefix)) == prefix then
    return str:sub((#prefix) + 1)
  else
    return str
  end
end
function StringUtils.split(str, sep)
  local parts = {}
  local pattern
  if sep then
    pattern = sep .. "([^" .. sep .. "]*)"
    str = sep .. str
  else
    pattern = "%S+"
  end
  for part in str:gmatch(pattern) do
    table.insert(parts, part)
  end
  return parts
end
return StringUtils
