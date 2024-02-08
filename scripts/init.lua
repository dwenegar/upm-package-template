--[[
  Utlitities
]]

local DIR_SEP = package.config:sub(1, 1)
local IS_WINDOWS = DIR_SEP == '\\'

local function to_win_path(path)
  return path:gsub('/', '\\')
end

local function printf(text, ...)
  print(text:format(...))
end

local function print_header(text)
  local ruler = ('='):rep(#text)
  io.stdout:write('\n', ruler, '\n', text, '\n', ruler, '\n')
end

local function read_text(filename)
  local f = io.open(filename, 'rb')
  local r = f:read('a')
  f:close()
  return r
end

local function write_text(filename, text)
  local f = io.open(filename, 'wb')
  f:write(text)
  f:close()
end

local function replace_all(text, replacements)
  return (text:gsub('@([%a_]+)@', replacements))
end

local function run_git(args)
  args = IS_WINDOWS and to_win_path(args) or args
  local f = io.popen('git ' .. args)
  local r = f:read('a'):match('^(.-)%s*$')
  f:close()
  return r
end

--[[
  Initialization
]]

print_header "Checking requirements"

local function check_cmd(name)
  local cmd = IS_WINDOWS
    and (name .. '>nul 2>nul')
    or (name .. '>/dev/null 2>/dev/null')
  local ok, _, code = os.execute(cmd)
  return ok or code ~= 127
end

local missing = {}
local requirements = {'git', 'git-lfs', 'git-cliff', 'make', 'doku'}
for _, requirement in ipairs(requirements) do
  local found = check_cmd(requirement);
  if not found then
    missing[#missing+1] = requirement
  end
  printf('%s: %s', requirement, (found and '\27[32m✓' or '\27[31m×') .. '\27[0m')
end

if #missing > 0 then
  printf("\nPlease install the missing commands: %s", table.concat(missing, ', '))
  os.exit(1)
end

print_header "Configuration"

local gh_user, gh_repo = run_git('remote -v'):match('github%.com:([^/]+)/([^/]+)%.git%s+%(fetch')
local author_name = run_git('config user.name')
local author_email = run_git('config user.email')
local name = gh_repo
local display_name = "Another Unity package"
local description = "Another Unity package"
local unity_version = "2023.2.4f1"
local unity_project_name = "UnityProject"
local root_namespace = "Custom.Package"

local config

local function prompt(message, default)
  io.write(message)
  default = (default or ''):match('^%s*(.-)%s*$')
  if #default > 0 then
    io.write(' [', tostring(default), ']')
  end
  io.write(': ')
  local line = io.read('l')
  return #line > 0 and line or default
end

while true do
  name = prompt("Package's name", name)
  display_name = prompt("Package's display name", display_name)
  description = prompt("Package's description", description)
  author_name = prompt("Author's full name", author_name)
  author_email = prompt("Author's email address", author_email)
  unity_project_name = prompt("Unity project name", unity_project_name)
  unity_version = prompt("Unity version", unity_version)
  root_namespace = prompt("Package's root namespace", root_namespace)

  config = {
    NAME = name,
    DISPLAY_NAME = display_name,
    DESCRIPTION = description,
    UNITY_VERSION = unity_version,
    UNITY_VERSION_SHORT = unity_version:match('^%d+%.%d+'),
    UNITY_PROJECT_NAME = unity_project_name,
    ROOT_NAMESPACE = root_namespace,
    AUTHOR_NAME = author_name,
    AUTHOR_EMAIL = author_email,
    GH_USER = gh_user,
    GH_REPO = gh_repo,
    YEAR = os.date('%Y')
  }

  print(replace_all([[

The package will be initialized with:

GitHub:
- User          : @GH_USER@
- Repository    : @GH_REPO@

Package:
- Name                      : @NAME@
- Display name              : @DISPLAY_NAME@
- Description               : @DESCRIPTION@
- Author                    : @AUTHOR_NAME@
- Author's email            : @AUTHOR_EMAIL@
- Unity Version             : @UNITY_VERSION@
- Unity Project Name        : @UNITY_PROJECT_NAME@
- Root Namespace            : @ROOT_NAMESPACE@

]], config))

  local answer = prompt("Is this correct? (Yn)", 'Y')
  if answer == 'Y' or answer == 'y' then
    break
  end
end

print_header "Initialization"

local function sed(replacements, paths)
  for _, path in ipairs(paths) do
    printf("Writing %q", path)
    write_text(path, replace_all(read_text(path), replacements))
  end
end

local function mv(src, dst)
  printf("Moving %q -> %q", src, dst)
  local cmd = IS_WINDOWS and 'cmd /q /c move' or 'mv'
  os.execute(('%s %q %q'):format(cmd, to_win_path(src), to_win_path(dst)))
end

local function md(path)
  printf("Creating %s", path)
  local cmd = IS_WINDOWS and 'cmd /q /c mkdir' or 'md'
  os.execute(('%q %q'):format(cmd, to_win_path(path)))
end

sed(config, {
  'package/Documentation~/index.md',
  'package/Editor/Editor.asmdef',
  'package/LICENSE.txt',
  'package/Makefile',
  'package/package.json',
  'package/README.md',
  'package/Runtime/Runtime.asmdef',
  'package/Tests/Editor/Editor.asmdef',
  'package/Tests/Runtime/Runtime.asmdef',
  'Projects/Project/Packages/manifest.json',
  'Projects/Project/ProjectSettings/ProjectVersion.txt',
  'scripts/ver.lua',
  'Makefile'
})

mv('package/README.md', 'README.md')
mv('package/LICENSE.txt', 'LICENSE.txt')
mv('package/Makefile', 'Makefile')
mv('package/Editor/Editor.asmdef', ('package/Editor/%s.Editor.asmdef'):format(root_namespace))
mv('package/Runtime/Runtime.asmdef', ('package/Runtime/%s.asmdef'):format(root_namespace))
mv('package/Tests/Editor/Editor.asmdef', ('package/Tests/Editor/%s.Editor.Tests.asmdef'):format(root_namespace))
mv('package/Tests/Runtime/Runtime.asmdef', ('package/Tests/Runtime/%s.Tests.asmdef'):format(root_namespace))
mv('package', name)
md('Projects/Project/Assets')
mv('Projects/Project', 'Projects/' .. unity_project_name)

mv('github', '.github')

print [[

Done!

Remember to

- configure `unityyamlmerge`, see  Smart merge at https://docs.unity3d.com/Manual/SmartMerge.html for details.
- delete the script/init.lua file

]]
