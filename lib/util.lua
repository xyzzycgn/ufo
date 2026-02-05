-- partially copied from lualib/util

util =
{
  table = {}
}

function util.distance(position1, position2)
  local x1 = position1[1] or position1.x
  local y1 = position1[2] or position1.y
  local x2 = position2[1] or position2.x
  local y2 = position2[2] or position2.y
  return ((x1 - x2) ^ 2 + (y1 - y2) ^ 2) ^ 0.5
end

function util.positiontostr(pos)
  return string.format("[%g, %g]", pos[1] or pos.x, pos[2] or pos.y)
end

function util.format_number(amount, append_suffix)
  local suffix = ""
  if append_suffix then
    local suffix_list =
      {
        ["T"] = 1000000000000,
        ["B"] = 1000000000,
        ["M"] = 1000000,
        ["k"] = 1000
      }
    for letter, limit in pairs (suffix_list) do
      if math.abs(amount) >= limit then
        amount = math.floor(amount/(limit/10))/10
        suffix = letter
        break
      end
    end
  end
  local formatted, k = amount, nil
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted..suffix
end

local energy_chars =
{
  k = 10^3,
  M = 10^6,
  G = 10^9,
  T = 10^12,
  P = 10^15,
  E = 10^18,
  Z = 10^21,
  Y = 10^24,
  R = 10^27,
  Q = 10^30,
}

function util.parse_energy(energy)

  local ending = energy:sub(energy:len())
  if not (ending == "J" or ending == "W") then
    error(ending.. " is not a valid unit of energy")
  end

  local multiplier = (ending == "W" and  1 / 60) or 1
  local magnitude = energy:sub(energy:len() - 1, energy:len() - 1)

  if tonumber(magnitude) then
    return tonumber(energy:sub(1, energy:len()-1)) * multiplier
  end

  multiplier = multiplier * (energy_chars[magnitude] or error(magnitude.. " is not valid magnitude"))
  return tonumber(energy:sub(1, energy:len()-2)) * multiplier

end


gram = 1
grams = gram
kg = 1000*grams
tons = 1000*kg
second = 60
minute = 60 * second
hour = 60 * minute
meter = 1
kilometer = 1000

return util
