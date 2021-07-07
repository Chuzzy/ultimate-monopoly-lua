---@type table<string, any>
InGameObjects = {}

---Populates the InGameObjects table.
---@param guids table<string, string> Table of GUIDs.
---@param directory string Name of the directory.
function populateInGameObjects(guids, directory)
    for object_name, object_guid in pairs(guids) do
        if type(object_guid) == "table" then
            populateInGameObjects(guids[object_name], object_name)
        elseif directory then
            InGameObjects[directory] = InGameObjects[directory] or {}
            InGameObjects[directory][object_name] = getObjectFromGUID(object_guid)
        else
            InGameObjects[object_name] = getObjectFromGUID(object_guid)
        end
    end
end
