--------------------------------------------------------------------------------
-- sanity checks go here
--------------------------------------------------------------------------------

-- WARNING: this doesn't check if they are set **correctly**, only that
--          they are _set_
-- check all "standard" directories are set
local dirs_to_check = { "cache", "config", "config_dirs", "data", "data_dirs", "log", "run", "state" }
for _, dir in ipairs (dirs_to_check) do
  if vim.fn.stdpath (dir) == nil then
    print ("ERROR: Could not get stdpath for '" .. dir .. "'.")
    os.exit (1)
  end
end
