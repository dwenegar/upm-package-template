local function write_lines(filename, lines)
  local file <close>, err = io.open(filename, 'w+b')
  if err then error(err) end
  for _, line in ipairs(lines) do
    file:write(line, '\010')
  end
end

--[[
  - trims trailing space
  - add empty line after headers
  - capitalize list items in changelog
  - remove consecutive empty lines
]]
local function tidy_markdown(filename, lines)
  local is_changelog = filename:match('CHANGELOG')

  local after_empty_line = true
  local function process_line(line)
    if #line == 0 and after_empty_line then
      return
    end

    if is_changelog then
      local is_list = not not line:match('^%-')
      if is_list then
        local first, tail = line:match('^%-%s+(.)(.-)%.*$')
        line = ('- %s%s.'):format(first:upper(), tail)
      end
    end

    local is_header = not not line:match('^#')
    if is_header and not after_empty_line then
      lines[#lines + 1] = ''
    end

    lines[#lines + 1] = line
    if is_header then
      lines[#lines + 1] = ''
    end

    after_empty_line = #line == 0 or is_header or not not line:match('<a')
  end

  for line in io.lines(filename) do
    process_line(line:match('^%s*(.-)%s*$'))
  end
end

--- trims trailing space
local function tidy_text_file(filename, lines)
  for line in io.lines(filename) do
    line = line:match('^(.-)%s*$')
    if #line > 0 then
      lines[#lines + 1] = line
    end
  end
end

local function run(...)
  local filenames = table.pack(...)
  for _, filename in ipairs(filenames) do
    local lines = {}
    if filename:match('%.md$') then
      tidy_markdown(filename, lines)
    else
      tidy_text_file(filename, lines)
    end

    -- remove all trailing empty lines...
    while #lines[#lines] == 0 do
      lines[#lines] = nil
    end

    write_lines(filename, lines)
  end
end

run(...)
