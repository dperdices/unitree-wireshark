local M = {}

crc = require('CRC32')

local function fields_hc_led(prefix, prefix_desc)
    led = {}
    led.led = ProtoField.none(string.format("%s", prefix), string.format("%s", prefix_desc), base.DEC)
    led.r = ProtoField.uint8(string.format("%s.r", prefix), string.format("%s Red", prefix_desc), base.DEC)
    led.g = ProtoField.uint8(string.format("%s.g", prefix), string.format("%s Green", prefix_desc), base.DEC)
    led.b = ProtoField.uint8(string.format("%s.b", prefix), string.format("%s Blue", prefix_desc), base.DEC)
    return led
end

local hc_head = ProtoField.uint16("unitree.hc_head", "Head", base.DEC_HEX)
local hc_levelFlag = ProtoField.uint8("unitree.hc_levelFlag", "Level Flag", base.DEC_HEX)
local hc_frameReserve = ProtoField.uint8("unitree.hc_frameReserve", "frameReserve", base.DEC_HEX)
local hc_SN = ProtoField.uint64("unitree.hc_SN", "SN", base.DEC_HEX)
local hc_version = ProtoField.uint64("unitree.hc_version", "version", base.DEC_HEX)
local hc_bandwidth = ProtoField.uint16("unitree.hc_bandwidth", "bandwidth", base.DEC)

local hc_modes_desc1 = {}
hc_modes_desc1[0] = "Idle"
hc_modes_desc1[1] = "Force stand"
hc_modes_desc1[2] = "Target velocity walking"
hc_modes_desc1[3] = "Target position walking"
hc_modes_desc1[4] = "Path mode walking"
hc_modes_desc1[5] = "Position stand down"
hc_modes_desc1[6] = "Position stand up"
hc_modes_desc1[7] = "Damping mode"
hc_modes_desc1[8] = "Recovery stand"
hc_modes_desc1[9] = "Backflip, reserved"
hc_modes_desc1[10] = "Jump mode"
hc_modes_desc1[11] = "Straight hand"
local hc_modes_desc = {}
for i =1,#hc_modes_desc1 do
  hc_modes_desc[#hc_modes_desc+1] = {i, i, hc_modes_desc1[i]}
end

local hc_mode = ProtoField.uint8("unitree.hc_mode", "Mode", base.RANGE_STRING, hc_modes_desc)
local hc_gaittype = ProtoField.uint8("unitree.hc_gaittype", "Gait type", base.DEC_HEX)
local hc_speedlevel = ProtoField.uint8("unitree.hc_speedlevel", "Speedlevel", base.DEC)
local hc_footraiseheight = ProtoField.float("unitree.hc_footraiseheight", "footRaiseHeight")
local hc_bodyheight = ProtoField.float("unitree.hc_bodyheight", "Body Height")
local hc_position = ProtoField.none("unitree.hc_position", "Position")
local hc_position_x = ProtoField.float("unitree.hc_position.x", "Position X")
local hc_position_y = ProtoField.float("unitree.hc_position.y", "Position Y")
local hc_euler = ProtoField.none("unitree.hc_euler", "Euler")
local hc_euler1 = ProtoField.float("unitree.hc_euler.1", "Roll pitch yaw in stand mode 1")
local hc_euler2 = ProtoField.float("unitree.hc_euler.2", "Roll pitch yaw in stand mode 2")
local hc_euler3 = ProtoField.float("unitree.hc_euler.3", "Roll pitch yaw in stand mode 2")
local hc_forwardspeed = ProtoField.float("unitree.hc_forwardspeed", "Forward speed")
local hc_sidespeed = ProtoField.float("unitree.hc_sidespeed", "Side speed")
local hc_yawSpeed = ProtoField.float("unitree.hc_yawspeed", "Angular body speed")
local hc_bms = ProtoField.none("unitree.hc_bms", "BMS")
local hc_bms_off = ProtoField.uint8("unitree.hc_bms.off", "Off if 0x0A", base.RANGE_STRING, {{0x0A, 0x0A, "Off"}, {0, 0xFF, "On"}})
local hc_bms_reserved = ProtoField.uint24("unitree.hc_bms.reserved", "Reserved")

local hc_led = ProtoField.none("unitree.hc_led", "LEDs")
local hc_led_array = {}
for i=1,4 do
    hc_led_array[i] = fields_hc_led(string.format("unitree.hc_led.%d", i), string.format("LED %d", i))
end

local hc_wirelessremote = ProtoField.bytes("unitree.hc_wirelessremote", "Wireless remote")
local hc_reserved = ProtoField.none("unitree.hc_reserved", "Reserve")

local hc_crc = ProtoField.uint32("unitree.hc_crc32", "CRC32", base.HEX)



hc_crc_expert = ProtoExpert.new("unitree.hc_crc32_is_not_correct", "CRC32 is not correct", expert.group.CHECKSUM, expert.severity.WARN)


experts = {hc_crc_expert}

function dissector(buffer, pinfo, subtree)
  offset = 0
  subtree:add_le(hc_head, buffer(offset,2))
  offset = offset + 2
  subtree:add_le(hc_levelFlag, buffer(offset,1))
  offset = offset + 1
  subtree:add_le(hc_frameReserve, buffer(3,1))
  offset = offset + 1
  subtree:add_le(hc_SN, buffer(offset,8))
  offset = offset + 8
  subtree:add_le(hc_version, buffer(offset,8))
  offset = offset + 8
  subtree:add_le(hc_bandwidth, buffer(offset,2))
  offset = offset + 2
  subtree:add_le(hc_mode, buffer(offset, 1))
  offset = offset + 1
  subtree:add_le(hc_gaittype, buffer(offset, 1))
  offset = offset + 1
  subtree:add_le(hc_speedlevel, buffer(offset, 1))
  offset = offset + 1
  subtree:add_le(hc_footraiseheight, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hc_bodyheight, buffer(offset, 4))
  offset = offset + 4
  local position_subtree = subtree:add(hc_position, buffer(offset, 8))
  position_subtree:add_le(hc_position_x, buffer(offset, 4))
  offset = offset + 4
  position_subtree:add_le(hc_position_y, buffer(offset, 4))
  offset = offset + 4
  local euler_subtree = subtree:add(hc_euler, buffer(offset, 12))
  euler_subtree:add_le(hc_euler1, buffer(offset, 4))
  offset = offset + 4
  euler_subtree:add_le(hc_euler2, buffer(offset, 4))
  offset = offset + 4
  euler_subtree:add_le(hc_euler3, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hc_forwardspeed, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hc_sidespeed, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hc_yawSpeed, buffer(offset, 4))
  offset = offset + 4


  local bms_subtree = subtree:add(hc_bms, buffer(offset, 4), "BMS")
  bms_subtree:add_le(hc_bms_off, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hc_bms_reserved, buffer(offset, 3))
  offset = offset + 3

  local led_subtree = subtree:add(hc_led, buffer(offset, 12))
  for i=1,4 do
    local thisledsubtree = led_subtree:add(hc_led_array[i].led, buffer(offset, 3))
    thisledsubtree:add_le(hc_led_array[i].r, buffer(offset, 1))
    offset = offset + 1
    thisledsubtree:add_le(hc_led_array[i].g, buffer(offset, 1))
    offset = offset + 1
    thisledsubtree:add_le(hc_led_array[i].b, buffer(offset, 1))
    offset = offset + 1
  end

  local wirelessremote_subtree = subtree:add(hc_wirelessremote, buffer(offset, 40), "Wireless Joystick")
  offset = offset + 40

  subtree:add_le(hc_reserved, buffer(offset, 4))
  offset = offset + 4

  subtree:add(hc_crc, buffer(offset,4))


  if crc:crc32(buffer:raw()) ~= 0 then 
    --subtree:add_proto_expert_info(hc_crc_expert, string.format("Wrong CRC")) 
  end

end

local fields = {
    hc_head,
    hc_levelFlag,
    hc_frameReserve,
    hc_SN,
    hc_version,
    hc_bandwidth,
    hc_mode,
    hc_gaittype,
    hc_speedlevel,
    hc_footraiseheight,
    hc_bodyheight,
    hc_position,
    hc_position_x,
    hc_position_y,
    hc_euler,
    hc_euler1,
    hc_euler2,
    hc_euler3,
    hc_forwardspeed,
    hc_sidespeed,
    hc_yawSpeed,
    hc_bms_off,
    hc_bms_reserved,
    hc_led,
    hc_wirelessremote,
    hc_reserved,
    hc_crc,
}

for k, v in pairs(hc_led_array) do
  for k, v2 in pairs(v) do
    fields[#fields+1] = v2
  end
end

M.fields = fields
M.experts = experts
M.dissector = dissector

return M