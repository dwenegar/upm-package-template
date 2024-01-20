local package_json = '@NAME@/package.json'
for line in io.lines(package_json) do
  local version = line:match('"version":%s*"([%d%.]+)"')
  if version then
    print(version)
    break
  end
end
