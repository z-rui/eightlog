#!/bin/env lua

local write = io.write
local log = math.log
local function log10(n)
  return log(n, 10)
end

local function round(x, digits)
  local s = ("%."..digits.."f"):format(x)
  -- find last 5
  local i = s:len()
  while s:byte(i) == 0x30 do -- '0'
    i = i - 1
  end
  if s:byte(i) == 0x35 and tonumber(s) > x then -- rounded up to '5'
    return s, i
  end
  return s, false
end

local prefix
local function write1(i, n)
    local N = n / 100 + i / 1000
    local lgN, fix = round(log10(N), 9)
    -- 0.aa bb bbbb c
    local a, b, c = lgN:sub(3, 4), lgN:sub(5, 6)..' '..lgN:sub(7, 10), lgN:sub(11, 11)
    if prefix == a then
      if i % 5 == 0 then
        write (' ')
      end
      write('  ')
    else
      if i % 5 == 0 then
        prefix = a
        write(a, ' ')
      else
        write('\\*')
      end
    end
    if fix then
      if fix == 11 then
        write(b, ' \\', c)
      else
        write(b:sub(1, fix-4), '\\', b:sub(fix-3), ' ', c)
      end
    else
      write(b, '  ', c)
    end
end

local function leftline(n)
  write('\\bf ', n)
  for i=0,4 do
    write('&&')
    write1(i, n)
  end
  write('\\cr\n')
end

local function rightline(n)
  for i=5,9 do
    write1(i, n)
    write('&&')
  end
  write('\\bf ', n, '\\cr\n')
end

local function doprefix(j)
  if j%5 == 0 then
    prefix = nil
    if j ~= 100 then
      write "\\blankline\n"
    end
  end
end

local function onesection(i) -- from 100 + 25i to 124 + 25i
  i = i * 25
  local n1, n2 = 100 + i, 124 + i
  local l1 = ('%.10f'):format(log10(n1)):sub(2,6)
  local l2 = ('%.10f'):format(log10(n2+.9)):sub(2,6)
  write("\\N={", n1, "0--", n2, "9", "} \\lgN={", l1, "--", l2, "}\n")

  write "\\lefttab\n"
  for j=100,124 do
    doprefix(j)
    leftline(i+j)
  end
  write "\\endtab\n\n"
  
  write "\\righttab\n"
  for j=100,124 do
    doprefix(j)
    rightline(i+j)
  end
  write "\\endtab\n\n"
end

write [[
\tabtitle={表~2}
]]
for i=0,35 do
  onesection(i)
end

local lprefix, rprefix
local function longlinepart(i)
  if i % 5 == 1 then
    write('1000')
  else
    write('    ')
  end
  write((' %02d&&'):format(i))
  local N = 1 + i / 100000
  local lgN, fix = round(log10(N), 9)
  local a, b, c = lgN:sub(3, 6), lgN:sub(7, 10), lgN:sub(11, 11)
  if i % 5 == 1 or a ~= prefix then
    prefix = a
    write(a)
  else
    write('    ')
  end
  if fix then
    write(' ', b, ' \\', c)
  else
    write(' ', b, '  ', c)
  end
end
local function longline(i)
  prefix = lprefix
  longlinepart(i)
  lprefix = prefix
  write('&&')
  prefix = rprefix
  if i < 75 then
    longlinepart(25+i)
  else
    write("---\\hfil&&---\\hfil")
  end
  rprefix = prefix
  write('\\cr\n')
end

write [[
\tabtitle={表~3}
\N={100001--100099} \lgN={.00000434--.00042973}
]]
write "\\longtab\n"
lprefix, rprefix = nil, nil
for i=1,25 do
  longline(i)
  if i % 5 == 0 and i < 25 then
    write "\\blankline\n"
  end
end
write "\\endtab\n"

write "\\longtab\n"
lprefix, rprefix = nil, nil
for i=51,75 do
  longline(i)
  if i % 5 == 0 and i < 75 then
    write "\\blankline\n"
  end
end
write "\\endtab\n"

-- vim: ts=2:sw=2:et
