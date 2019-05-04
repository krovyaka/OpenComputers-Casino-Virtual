local component = require("component")
if not component.isAvailable("internet") then
    io.stderr:write("An internet card is required!")
    return
end
local computer = require("computer")
local shell = require("shell")

local args = shell.parse(...)
local BRANCH = args[1] == "dev" and "develop" or "master"

local AUTORUN_CONTENT = [[require("event").shouldInterrupt = function () return false end
os.sleep(4)
require("shell").execute("/home/1")]]

local GAMES = {
    -- {NAME, PASTEBIN}
    { "Terminal (PIM)", "app_Terminal.0" },
    { "Terminal (Chest)", "app_Terminal_2.0" },
    { "Checker", "app_Checker" },
    { "Video Poker", "game_video_poker" },
    { "Minesweeper", "game_Minesweeper" },
    { "Roulette", "game_Roulette" },
    { "Black Jack", "game_Roulette" }
}

local function writeToFile(path, content)
    local file = io.open(path, "w")
    file:write(content)
    file:close()
end

local function safetyStart()
    if computer.users() then
        return
    end
    print("Do you want the application to be safely deployed? (y/other)")
    local safety = io.read() == "y"
    if not safety then
        return
    end
    io.write("PC administrator login = ")
    local administrator = io.read()
    computer.addUser(administrator)
end

local function saveAutorun()
    print("Autorun saving begins...")
    writeToFile("/autorun.lua", AUTORUN_CONTENT)
    print("Autorun is saved")
end

local function saveLauncher()
    print("Launcher saving begins...")
    shell.execute("wget -q https://raw.githubusercontent.com/krovyaka/OpenComputers-Casino/" .. BRANCH .. "/launcher.lua /home/1")
    print("Launcher is saved")
end

local function saveApplication(app)
    print("Application saving begins...")
    shell.execute("wget -q https://raw.githubusercontent.com/krovyaka/OpenComputers-Casino/" .. BRANCH .. "/apps/" .. app[2] .. ".lua /home/app.lua")
    print("Application is saved")
end

local function saveApplicationInfo(app)
    print("Application info saving begins...")
    writeToFile("/home/appInfo.lua", string.format('return {name="%s", label="%s", branch="%s"}', app[2], app[1], BRANCH))
    print("Application info is saved")
end

local function deploy(selected)
    print('The deployment of the "' .. selected[1] .. '" application begins.')
    saveAutorun()
    saveLauncher()
    saveApplication(selected)
    saveApplicationInfo(selected)
    print('Application successfully deployed. Press ENTER to restart...')
    io.read()
    shell.execute("reboot")
end

print("MCSkill Casino Deployer 1.0")
print()
safetyStart()
print("Select an application to deploy...")
for i = 1, #GAMES do
    print(i .. ". " .. GAMES[i][1])
end
io.write("id = ")
local selected = GAMES[tonumber(io.read())]
if selected == nil then
    print("Not found.")
    return
end
deploy(selected)