-- I don't know if this needs to be declared before the call to the
-- BuildTableFromCSV function or if BuildTableFromCSV will create the variable
-- if it does not already exist. I also have no idea if BuildTableFromCSV works
-- if the table name already exists but is not a table. Homework for you :).
ReloadCSV_Table = {}

-- Call with `/script ReloadCSV ()` in chat.
function ReloadCSV ()

  -- Clear existing contents.
  ReloadCSV_Table = {}

  -- BuildTableFromCSV requires a full path from the game EXE which is annoying.
  -- There are ways to work out what folder the add-on is in but that is not
  -- part of this demo. The function loads the table into a global LUA variable
  -- specified by name, so you cannot load it into a local.
  BuildTableFromCSV ("Interface/Addons/ReloadCSV/Test.csv", "ReloadCSV_Table")

  d (ReloadCSV_Table)

end

-- Call with `/script ReloadCSV2 ()` in chat.
function ReloadCSV2 ()

  -- Clear existing contents.
  ReloadCSV_Table = {}

  -- Load in the first table as usual.
  BuildTableFromCSV ("Interface/Addons/ReloadCSV/Test.csv", "ReloadCSV_Table")

  -- As we did not clear the table between calls, the second call will merge the
  -- contents of "Test2.csv" with "Test.csv". New rows (table keys) will be
  -- added if needed, and the values of existing fields will be updated.
  BuildTableFromCSV ("Interface/Addons/ReloadCSV/Test2.csv", "ReloadCSV_Table")

  d (ReloadCSV_Table)

end