require("event").shouldInterrupt = function () return false end
os.sleep(4)
require("shell").execute("/home/1")