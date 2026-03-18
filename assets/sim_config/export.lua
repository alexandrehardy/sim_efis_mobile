-- Place this in Config/export/export.lua

-- Insert the correct IP number here,
-- or use 0.0.0.0 if security is not
-- a concern.
LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 45000

-- The instrument_host and port will be populated
-- later
-- instrument_host = ""
-- instrument_port = 0
instrument_host = ""
instrument_port = 15000

function loadSocketLibrary()
    socket = require("lfs")
    package.path  = package.path..";"..lfs.currentdir().."/LuaSocket/?.lua"
    package.cpath = package.cpath..";"..lfs.currentdir().."/LuaSocket/?.dll"
    socket = require("socket")
end

function setupUDP()
    loadSocketLibrary()
    -- socket is now defined
    udp = assert(socket.udp())
    assert(udp:setsockname(LISTEN_HOST, LISTEN_PORT))
    udp:settimeout(0)
end

setupUDP()

function LuaExportStart()
end

function LuaExportBeforeNextFrame()
end

function LuaExportAfterNextFrame()
end

function LuaExportActivityNextEvent(t)
    local tNext = t
    local dgram, ip, port = udp:receivefrom()
    if dgram then
        instrument_host = ip
        instrument_port = port
    end

    if instrument_host ~= "" then
        local simtime = math.floor(LoGetModelTime() + LoGetMissionStartTime())
        local ias = LoGetIndicatedAirSpeed()
        local amsl = LoGetAltitudeAboveSeaLevel()
        local agl = LoGetAltitudeAboveGroundLevel()
        local vs = LoGetVerticalVelocity()
        local pitch, bank, yaw = LoGetADIPitchBankYaw()  -- radians
        local slip = LoGetSlipBallPosition() -- [-1, 1]
        local hsi = LoGetControlPanel_HSI()
        local engine = LoGetEngineInfo()
        local rpm0 = engine.RPM.left
        local rpm1 = engine.RPM.right
        local egt0 = engine.Temperature.left
        local egt1 = engine.Temperature.right
        local fuel = engine.fuel_internal + engine.fuel_external -- kg
        -- local heading = hsi.Heading_raw -- radians, already in yaw
        local myData = LoGetSelfData()
        local heading = myData.Heading
        local longitude = myData.LatLongAlt.Long
        local latitude = myData.LatLongAlt.Lat
        local aircraft = myData.Name

        local mech = LoGetMechInfo() -- for flaps and gear
        local packet = "TIME:" .. simtime
        packet = packet .. ";" .. "NENG:" .. 2
        packet = packet .. ";" .. "KIAS:" .. (ias * 1.94384)
        packet = packet .. ";" .. "ALTF:" .. (amsl * 3.28084)
        packet = packet .. ";" .. "AGLF:" .. (agl * 3.28084)
        packet = packet .. ";" .. "VSIF:" .. (vs * 60.0 * 3.28084)
        packet = packet .. ";" .. "PITC:" .. (pitch * 180.0 / math.pi)
        packet = packet .. ";" .. "ROLL:" .. (bank * 180.0 / math.pi)
        packet = packet .. ";" .. "HEAD:" .. (yaw * 180.0 / math.pi)
        if slip ~= nul then
            packet = packet .. ";" .. "SLIP:" .. (-slip)
        end
        packet = packet .. ";" .. "RPMS:0:" .. rpm0
        packet = packet .. ";" .. "RPMS:1:" .. rpm1
        packet = packet .. ";" .. "EGTF:0:" .. egt0
        packet = packet .. ";" .. "EGTF:1:" .. egt1
        packet = packet .. ";" .. "FUEL:" .. fuel
        packet = packet .. ";" .. "LONG:" .. longitude
        packet = packet .. ";" .. "LATD:" .. latitude
        packet = packet .. ";" .. "ACFT:" .. aircraft
        if mech ~= nul then
            packet = packet .. ";" .. "LGLT:" .. mech.gear.value
            packet = packet .. ";" .. "LGRT:" .. mech.gear.value
            packet = packet .. ";" .. "LGCT:" .. mech.gear.value
            packet = packet .. ";" .. "FLAP:" .. mech.flaps.value
        end
        udp:sendto(packet, instrument_host, instrument_port)
    end
    tNext = tNext + 0.1
    return tNext
end

function LuaExportStop()
end
