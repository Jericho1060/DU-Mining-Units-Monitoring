system.print("----------------------------------------")
system.print("DU-Mining-Units-Monitoring version 1.5.4")
system.print("----------------------------------------")

fontSize = 25 --export: font size for each line on the screen
calibrationSecondsRedLevel = 259200 --export: The time in seconds from last calibration above the time will be displayed in red. Default to 259200 (3 days / 72h)
calibrationSecondsYellowLevel = 86400 --export: The time in seconds from last calibration above the time will be displayed in yellow. Default to 86400 (1 day / 24h)

local renderScript = [[
local json = require('dkjson')
local fromScript = json.decode(getInput()) or {}
pool = fromScript[1] or {}
data = fromScript[2] or {}
images = {}
for k,p in pairs(pool) do
    if images[k] == nil or not isImageLoaded(images[k]) then
        images[k] = loadImage("resources_generated/env/" .. p[4])
    end
end

local rx,ry = getResolution()

local back=createLayer()
local front=createLayer()

font_size = 25

local mini=loadFont('Play',12)
local small=loadFont('Play',14)
local smallBold=loadFont('Play-Bold',18)
local itemName=loadFont('Play-Bold',font_size)
local itemNameSmall=loadFont('Play-Bold',font_size*0.75)
local itemNameXs=loadFont('Play-Bold',font_size*0.65)

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

function SecondsToClockString(a)local a=tonumber(a)if a==nil or a<=0 then return"-"else days=string.format("%2.f",math.floor(a/(3600*24)))hours=string.format("%2.f",math.floor(a/3600-days*24))mins=string.format("%2.f",math.floor(a/60-hours*60-days*24*60))secs=string.format("%2.f",math.floor(a-hours*3600-days*24*60*60-mins*60))str=""if tonumber(days)>0 then str=str..days.."d "end;if tonumber(hours)>0 then str=str..hours.."h "end;if tonumber(mins)>0 then str=str..mins.."m "end;if tonumber(secs)>0 then str=str..secs.."s"end;return str end end

function round(a,b)if b then return utils.round(a/b)*b end;return a>=0 and math.floor(a+0.5)or math.ceil(a-0.5)end

function getRGBGradient(a,b,c,d,e,f,g)a=-1*math.cos(a*math.pi)/2+0.5;local h=b-a*(b-e)local i=c-a*(c-f)local j=d-a*(d-g)return h,i,j end

function renderHeader(title)
    local h_factor = 12
    local h = 35
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

local gaugeColorLayer = createLayer()

function renderResistanceBar(ore_id, status, time, prod_rate, calibration, optimal, efficiency, cal_time, x, y, w, h, withTitle)
    local quantity_x_pos = font_size * 6.7
    local percent_x_pos = font_size * 2

    local colorLayer = storageGreen
    local status_text = "RUNNING"
    if (status == 1) or (status == 3) or (status == 4) then
        colorLayer = storageRed
        if status == 3 then status_text = 'OUTPUT FULL'
        elseif status == 1 then status_text = 'STOPPED'
        elseif status == 4 then status_text = 'NO CONTAINER'
        end
    end

    local calibrationRequiredTime = ((calibration-optimal)/.625)*3600
    if 259200 - cal_time > 0 then calibrationRequiredTime = calibrationRequiredTime + 259200 - cal_time end
    if calibration < optimal then calibrationRequiredTime = 86400 - cal_time end

    local colorRequiredCalibrationLayer = storageBar
    if calibrationRequiredTime < 86400 then colorRequiredCalibrationLayer = storageYellow end
    if calibrationRequiredTime < 43200 then colorRequiredCalibrationLayer = storageRed end

    if calibrationRequiredTime < 0 then
        calibrationRequiredTime = "REQUIRED"
    else
        calibrationRequiredTime = SecondsToClockString(calibrationRequiredTime)
    end

    pcal = calibration
    if pcal > optimal then pcal = optimal end
    if optimal > 0 then
        pcal = pcal / optimal
    else
        pcal = 1
    end
    local r = 34/255
    local g = 177/255
    local b = 76/255
    if pcal < 1 then
        r,g,b = getRGBGradient(pcal,177/255,42/255,42/255,249/255,212/255,123/255)
    end

    local CalibrationTimeColorLayer = storageGreen
    if cal_time > 86400 then CalibrationTimeColorLayer = storageYellow end
    if cal_time > 259200 then CalibrationTimeColorLayer = storageRed end

    addBox(storageBar,x,y,w,h)


    if withTitle then
        addText(storageBar, small, "ORE", x, y-5)
        addText(storageBar, small, "STATUS", x+w-60, y-5)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "TIME & RATE", x+(w*0.3), y-3)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "Calibration", x+(w*0.45), y-3)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "CALIBRATION REQUIRED IN", x+(w*0.65), y-3)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "EFFICIENCY", x+(w*0.80), y-3)
    end

    addText(storageBar, itemName, pool[ore_id][3], x+15+font_size, y+h-font_size/2)
    setNextFillColor(gaugeColorLayer, r, g, b, 1)
    addBox(gaugeColorLayer,x,y+h-3,w*calibration/100,3)

    if isImageLoaded(images[ore_id]) then
        addImage(imagesLayer, images[ore_id], x+10, y+5, font_size, font_size)
    end
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    addText(storageBar, itemNameXs, SecondsToClockString(time), x+(w*0.3), y+(h/4)-3)
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    if (prod_rate-round(prod_rate)) == 0 then prod_rate = round(prod_rate) end
    addText(storageBar, itemNameXs, format_number(prod_rate) .. 'L', x+(w*0.3), y+(h/4)+(h/4)+(h/4)-3)
    setNextTextAlign(CalibrationTimeColorLayer, AlignH_Center, AlignV_Middle)
    addText(CalibrationTimeColorLayer, itemNameXs, SecondsToClockString(cal_time), x+(w*0.45), y+(h/4)-3)
    setNextFillColor(gaugeColorLayer, r, g, b, 1)
    setNextTextAlign(gaugeColorLayer, AlignH_Center, AlignV_Middle)
    if (calibration-round(calibration)) == 0 then calibration = round(calibration) end
    if (optimal-round(optimal)) == 0 then optimal = round(optimal) end
    addText(gaugeColorLayer, itemNameXs, format_number(calibration) .. '% / ' ..format_number(optimal) .. '%', x+(w*0.45), y+(h/4)+(h/4)+(h/4)-3)
    setNextTextAlign(colorRequiredCalibrationLayer, AlignH_Center, AlignV_Middle)
    addText(colorRequiredCalibrationLayer, itemNameSmall, calibrationRequiredTime, x+(w*0.65), y+(h/2)-3)
    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    if (efficiency-round(efficiency)) == 0 then efficiency = round(efficiency) end
    addText(storageBar, itemNameSmall, format_number(efficiency) .. '%', x+(w*0.80), y+(h/2)-3)

    setNextTextAlign(colorLayer, AlignH_Right, AlignV_Middle)
    addText(colorLayer, itemName, status_text, x+w-10, y+(h/2)-3)
end

function renderPool(pool)
    local h_factor = 12
    local h = 35
    addLine( back,0,ry-h+h_factor,rx,ry-h+h_factor)
    addBox(front,0,ry-h-h_factor,rx,h)
    local nb_col = 1
    for k,v in pairs(pool) do nb_col = nb_col + 1 end
    local n = 1
    for k,v in pairs(pool) do
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, v[3], (rx/nb_col)*n, ry-h-h_factor)
        if isImageLoaded(images[k]) then
            addImage(storageBar, images[k], (rx/nb_col)*n-h-h, ry-(h/2)-h_factor-(h/2)+2, h-4, h-4)
        end
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
        addText(storageBar, itemNameSmall, format_number(round(v[1])) .. " / " .. format_number(round(v[2])), (rx/nb_col)*n, ry-(h/2)-h_factor)
        n = n + 1
    end
end

renderHeader('MINING UNITS MONITORING')

start_h = 75

local h = font_size + font_size / 2
for i,mu in ipairs(data) do
    renderResistanceBar(tostring(mu[3]), mu[1], mu[2], mu[4], mu[5], mu[6], mu[7], mu[8], 44, start_h, rx-88, h, i==1)
    start_h = start_h+h+15
end
renderPool(pool)
requestAnimationFrame(10)
]]

screens = {}
mining_units = {}
for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
        and type(slot.export) == "table"
        and slot.getClass
    then
        slot.slotname = slot_name
        if slot.getClass():lower() == 'screenunit' then
            table.insert(screens,slot)
            slot.setRenderScript(renderScript)
        elseif slot.getClass():lower() == 'miningunit' then
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

function round(a,b)if b then return utils.round(a/b)*b end;return a>=0 and math.floor(a+0.5)or math.ceil(a-0.5)end

ores = {}

--Nested Coroutines by Jericho
coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        screen_data = {}
        pool = {}
        for index, mu in ipairs(mining_units) do
            local mup = mu.getOrePools()
            for _,p in ipairs(mup) do
                if ores[p.id] == nil then
                    local item_data = system.getItem(p.id)
                    ores[p.id] = {
                        item_data.locDisplayName,
                        item_data.iconPath:gsub("resources_generated/env/","")
                    }
                end
                pool[p.id] = {p.available, p.maximum, ores[p.id][1], ores[p.id][2]}
            end
            local mu_data = {
                mu.getState(),
                round(mu.getRemainingTime()),
                mu.getActiveOre(),
                round(mu.getProductionRate()*100)/100,
                round(mu.getCalibrationRate()*10000)/100,
                round(mu.getOptimalRate()*10000)/100,
                round(mu.getEfficiency()*10000)/100,
                round(mu.getLastExtractionTime()),
            }
            table.insert(screen_data, mu_data)
            coroutine.yield(coroutinesTable[1])
        end
        for index, screen in pairs(screens) do
            local toSend = {
                pool,
                screen_data
            }
            screen.setScriptInput(json.encode(toSend))
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
