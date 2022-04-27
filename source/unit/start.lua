system.print("-----------------------------------")
system.print("DU-Mining-Units-Monitoring version 1.0.0")
system.print("-----------------------------------")

local renderScript = [[
local json = require('dkjson')
logMessage(getInput())
local data = json.decode(getInput()) or {}
images = {}
for index,mu in ipairs(data) do
    images[index] = loadImage(mu[3][2])
end

local rx,ry = getResolution()

local back=createLayer()
local front=createLayer()

font_size = 25

local mini=loadFont('Play',12)
local small=loadFont('Play',14)
local smallBold=loadFont('Play-Bold',18)
local itemName=loadFont('Play-Bold',font_size)
local medV=loadFont('Play-Bold', 25)
local bigV=loadFont('Play-Bold', 30)
local big=loadFont('Play',38)

setBackgroundColor( 15/255,24/255,29/255)

setDefaultStrokeColor( back,Shape_Line,0,0,0,0.5)
setDefaultShadow( back,Shape_Line,6,0,0,0,0.5)

setDefaultFillColor( front,Shape_BoxRounded,249/255,212/255,123/255,1)
setDefaultFillColor( front,Shape_Text,0,0,0,1)
setDefaultFillColor( front,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor( front,Shape_Text,0.710,0.878,0.941,1)

function format_number(value)
    local formatted = value
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
        if (k==0) then
            break
        end
    end
    return formatted
end

function SecondsToClockString(seconds)
    local seconds = tonumber(seconds)

    if seconds == nil or seconds <= 0 then
        return "-";
    else
        days = string.format("%2.f", math.floor(seconds/(3600*24)));
        hours = string.format("%2.f", math.floor(seconds/3600 - (days*24)));
        mins = string.format("%2.f", math.floor(seconds/60 - (hours*60) - (days*24*60)));
        secs = string.format("%2.f", math.floor(seconds - hours*3600  - (days*24*60*60) - mins *60));
        str = ""
        if tonumber(days) > 0 then str = str .. days.."d " end
        if tonumber(hours) > 0 then str = str .. hours.."h " end
        if tonumber(mins) > 0 then str = str .. mins.."m " end
        if tonumber(secs) > 0 then str = str .. secs .."s" end
        return str
    end
end

function round(value, precision)
    if precision then return utils.round(value / precision) * precision end
    return value >= 0 and math.floor(value+0.5) or math.ceil(value-0.5)
end

function renderHeader(title)
    local h_factor = 12
    local h = 35
    if subtitle ~= nil and subtitle ~= "" then
        h = 50
    end
    addLine( back,0,h+12,rx,h+12)
    addBox(front,0,12,rx,h)
    addText(front,smallBold,title,44,35)
end

local storageBar = createLayer()
setDefaultFillColor(storageBar,Shape_Text,110/255,166/255,181/255,1)
setDefaultFillColor(storageBar,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor(storageBar,Shape_Line,1,1,1,1)

local storageYellow = createLayer()
setDefaultFillColor(storageYellow,Shape_Text,249/255,212/255,123/255,1)
setDefaultFillColor(storageYellow,Shape_Box,249/255,212/255,123/255,1)

local storageDark = createLayer()
setDefaultFillColor(storageDark,Shape_Text,63/255,92/255,102/255,1)
setDefaultFillColor(storageDark,Shape_Box,13/255,24/255,28/255,1)

local storageRed = createLayer()
setDefaultFillColor(storageRed,Shape_Text,177/255,42/255,42/255,1)
setDefaultFillColor(storageRed,Shape_Box,177/255,42/255,42/255,1)

local storageGreen = createLayer()
setDefaultFillColor(storageGreen,Shape_Text,34/255,177/255,76/255,1)
setDefaultFillColor(storageGreen,Shape_Box,34/255,177/255,76/255,1)

local imagesLayer = createLayer()

function renderResistanceBar(title, index, status, time, prod_rate, calibration, efficiency, x, y, w, h, withTitle)
    local quantity_x_pos = font_size * 6.7
    local percent_x_pos = font_size * 2

    local colorLayer = storageGreen
    if status == "STALLED" then colorLayer = storageYellow end
    if status == "STOPPED" then colorLayer = storageRed end

    addBox(storageBar,x,y,w,h)


    if withTitle then
        addText(storageBar, small, "ORE", x, y-5)
        addText(storageBar, small, "STATUS", x+w-60, y-5)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "TIME", x+w-200-quantity_x_pos-(font_size*3)-(font_size*8.2), y-3)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "RATE", x+w-50-quantity_x_pos-(font_size*3)-(font_size*8.2), y-3)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "CALIBRATION", x+w+100-quantity_x_pos-(font_size*3)-(font_size*8.2), y-3)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "EFFICIENCY", x+w+250-quantity_x_pos-(font_size*3)-(font_size*8.2), y-3)
    end

    addText(storageBar, itemName, title, x+15+font_size, y+h-font_size/2)
    addBox(colorLayer,x,y+h-3,w,3)

    if isImageLoaded(images[index]) then
        addImage(imagesLayer, images[index], x+10, y+5, font_size, font_size)
    end
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    addText(storageBar, smallBold, SecondsToClockString(time), x+w-200-quantity_x_pos-(font_size*3)-(font_size*8.2), y+(h/2)-3)
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    addText(storageBar, smallBold, format_number(prod_rate) .. 'L', x+w-50-quantity_x_pos-(font_size*3)-(font_size*8.2), y+(h/2)-3)
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    addText(storageBar, smallBold, format_number(calibration) .. '%', x+w+100-quantity_x_pos-(font_size*3)-(font_size*8.2), y+(h/2)-3)
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    addText(storageBar, smallBold, format_number(efficiency) .. '%', x+w+250-quantity_x_pos-(font_size*3)-(font_size*8.2), y+(h/2)-3)

    setNextTextAlign(colorLayer, AlignH_Right, AlignV_Middle)
    addText(colorLayer, itemName, status, x+w-10, y+(h/2)-3)

    --addBox(storageDark,x+w-400,y+5,390,20)
end

renderHeader('MINING UNITS MONITORING')

start_h = 75

local h = font_size + font_size / 2
for i,mu in ipairs(data) do
    renderResistanceBar(mu[3][1], i, mu[1], mu[2], mu[4], mu[5], mu[6], 44, start_h, rx-88, h, i==1)
    start_h = start_h+h+10
end
requestAnimationFrame(10)
]]

screens = {}
mining_units = {}
for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
        and type(slot.export) == "table"
        and slot.getElementClass
    then
        slot.slotname = slot_name
        if slot.getElementClass():lower() == 'screenunit' then
            table.insert(screens,slot)
            slot.setRenderScript(renderScript)
        elseif slot.getElementClass():lower() == 'miningunit' then
            table.insert(mining_units,slot)
        end
    end
end
if #screens == 0 then
    system.print("No screen detected")
else
    table.sort(screens, function(a,b) return a.slotname < b.slotname end)
    local plural = ""
    if #screens > 1 then plural = "s" end
    system.print(#screens .. " screen" .. plural .. " connected")
end
if #mining_units == 0 then
    system.print("No mining unit detected")
else
    table.sort(mining_units, function(a,b) return a.slotname < b.slotname end)
    local plural = ""
    if #mining_units > 1 then plural = "s" end
    system.print(#mining_units .. " mining unit" .. plural .. " connected")
end

function round(value, precision)
    if precision then return utils.round(value / precision) * precision end
    return value >= 0 and math.floor(value+0.5) or math.ceil(value-0.5)
end

ores = {}

--Nested Coroutines by Jericho
coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        screen_data = {}
        for index, mu in pairs(mining_units) do
            local ore_id = mu.getActiveOre()
            if ores[ore_id] == nil then
                local item_data = system.getItem(ore_id)
                ores[ore_id] = {
                    item_data.displayName,
                    item_data.iconPath
                }
            end
            local mu_data = {
                mu.getStatus(),
                round(mu.getRemainingTime()),
                ores[ore_id],
                mu.getProductionRate(),
                round(mu.getCalibrationRate()*100),
                round(mu.getEfficiency()*100),
            }
            table.insert(screen_data, mu_data)
            coroutine.yield(coroutinesTable[1])
        end
        for index, screen in pairs(screens) do
            screen.setScriptInput(json.encode(screen_data))
        end
    end
}

function initCoroutines()
    for _,f in pairs(MyCoroutines) do
        local co = coroutine.create(f)
        table.insert(coroutinesTable, co)
    end
end

initCoroutines()

runCoroutines = function()
    for i,co in ipairs(coroutinesTable) do
        if coroutine.status(co) == "dead" then
            coroutinesTable[i] = coroutine.create(MyCoroutines[i])
        end
        if coroutine.status(co) == "suspended" then
            assert(coroutine.resume(co))
        end
    end
end

MainCoroutine = coroutine.create(runCoroutines)
