local component = require("component")
if not component.isAvailable("internet") then
    io.stderr:write("An internet card is required!")
    return
end
local computer = require("computer")
local shell = require("shell")

local AUTORUN_CONTENT = [[require("event").shouldInterrupt = function () return false end
os.sleep(4)
require("shell").execute("/home/1")]]

local GAMES = {
    { "Terminal (PIM)", "app_Terminal.0" },
    { "Terminal (Chest)", "app_Terminal_2.0" },
    { "Checker", "app_Checker" },
    { "Video Poker", "game_video_poker" },
    { "Minesweeper", "game_Minesweeper" },
    { "Roulette", "game_Roulette" },
    { "Black Jack", "game_Black_jack" }
}

local MODES = {
    { "DEV", "develop" },
    { "PROD", "master" }
}

local SETTINGS = {
    applicationLabel = nil, -- ex: Checker
    application = nil, -- ex: app_Checker
    mode = nil, -- ex: DEV
    branch = nil, -- ex: develop
}

local function writeToFile(path, content)
    local file = io.open(path, "w")
    file:write(content)
    file:close()
end

local function selectFromList(list, labelKey)
    for i = 1, #list do
        print(i .. ". " .. list[i][labelKey])
    end
    io.write("id = ")
    return list[tonumber(io.read())]
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

local function selectApplication()
    print("Select an application to deploy...")
    local application = selectFromList(GAMES, 1)
    if not application then
        error("Application is not defined!")
    end
    SETTINGS.application = application[2]
    SETTINGS.applicationLabel = application[1]
end

local function selectMode()
    print("Select deploy mode...")
    local mode = selectFromList(MODES, 1)
    if not mode then
        error("Mode is not defined!")
    end
    SETTINGS.mode = mode[1]
    SETTINGS.branch = mode[2]
end

local function saveAutorun()
    print("Autorun saving begins...")
    if SETTINGS.mode == "DEV" then
        print("The application is deployed in DEV mode. Autorun file is not needed.")
    else
        writeToFile("/autorun.lua", AUTORUN_CONTENT)
        print("Autorun is saved")
    end
end

local function saveLauncher()
    print("Launcher saving begins...")
    shell.execute("wget -fq https://raw.githubusercontent.com/krovyaka/OpenComputers-Casino/" .. SETTINGS.branch .. "/launcher.lua /home/1")
    print("Launcher is saved")
end

local function saveApplication()
    print("Application saving begins...")
    shell.execute(string.format(
            "wget -fq https://raw.githubusercontent.com/krovyaka/OpenComputers-Casino/%s/apps/%s.lua /home/app.lua",
            SETTINGS.branch,
            SETTINGS.application
    ))
    print("Application is saved")
end

local function saveApplicationInfo()
    print("Application info saving begins...")
    writeToFile("/home/appInfo.lua", string.format(
            'return {name="%s", label="%s", branch="%s"}',
            SETTINGS.application,
            SETTINGS.applicationLabel,
            SETTINGS.branch
    ))
    print("Application info is saved")
end

local function setupSettings()
    safetyStart()
    selectApplication()
    selectMode()
end

local function deploy()
    print('The deployment of the "' .. SETTINGS.application .. '" application begins.')
    saveAutorun()
    saveLauncher()
    saveApplication()
    saveApplicationInfo()
    print('Application successfully deployed.')
end

print("MCSkill Casino Deployer 1.1\n")
setupSettings()
deploy()
print("Press ENTER to restart...")
io.read()
shell.execute("reboot")