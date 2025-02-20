local M = {}

crc = require('CRC32')

local function fields_hs_motorstate(i)
  motorstate = {}
  motorstate.mode = ProtoField.uint8(string.format("unitree.hs_motorstate.%d.mode", i), "Working mode", base.HEX) -- motor working mode. Servo : 0x0A, Damping : 0x00，Overheat ： 0x08.
  motorstate.q = ProtoField.float(string.format("unitree.hs_motorstate.%d.q", i)) -- current angle (unit: radian)
  motorstate.dq = ProtoField.float(string.format("unitree.hs_motorstate.%d.dq", i)) -- current speed (unit: radian/s)
  motorstate.ddq = ProtoField.float(string.format("unitree.hs_motorstate.%d.ddq", i)) -- current acc (unit: radian/s^2)
  motorstate.tauEst = ProtoField.float(string.format("unitree.hs_motorstate.%d.tauEst", i)) -- current estimated output torque (unit: N.m)
  motorstate.q_raw = ProtoField.float(string.format("unitree.hs_motorstate.%d.q_raw", i)) -- current angle (unit: radian)
  motorstate.dq_raw = ProtoField.float(string.format("unitree.hs_motorstate.%d.dq_raw", i)) -- current speed (unit: radian/s)
  motorstate.ddq_raw = ProtoField.float(string.format("unitree.hs_motorstate.%d.ddq_raw", i)) -- current acc (unit: radian/s^2)
  motorstate.temperature = ProtoField.uint8(string.format("unitree.hs_motorstate.%d.temperature", i), "Current temperature", base.DEC) -- current temperature (temperature conduction is slow that leads to lag)
  motorstate.reserved = ProtoField.uint64(string.format("unitree.hs_motorstate.%d.reserved", i), "Reserved", base.HEX) -- current temperature (temperature conduction is slow that leads to lag)
  return motorstate
end

local function fields_hs_cartesian(prefix, prefix_desc)
  cartesian = {}
  cartesian.cartesian = ProtoField.none(string.format("%s", prefix), string.format("%s", prefix_desc))
  cartesian.x = ProtoField.float(string.format("%s.x", prefix), string.format("%s X", prefix_desc))
  cartesian.y = ProtoField.float(string.format("%s.y", prefix), string.format("%s Y", prefix_desc))
  cartesian.z = ProtoField.float(string.format("%s.z", prefix), string.format("%s Z", prefix_desc))
  return cartesian
end

local hs_head = ProtoField.uint16("unitree.hs_head", "head", base.DEC_HEX)
local hs_levelFlag = ProtoField.uint8("unitree.hs_levelFlag", "levelFlag", base.DEC_HEX)
local hs_frameReserve = ProtoField.uint8("unitree.hs_frameReserve", "frameReserve", base.DEC_HEX)
local hs_SN = ProtoField.uint64("unitree.hs_SN", "SN", base.DEC_HEX)
local hs_version = ProtoField.uint64("unitree.hs_version", "version", base.DEC_HEX)
local hs_bandwidth = ProtoField.uint16("unitree.hs_bandwidth", "bandwidth", base.DEC)
local hs_imu = ProtoField.none("unitree.hs_imu", "IMU")
local hs_imu_q = ProtoField.none("unitree.hs_imu.q", "Quaternion")
local hs_imu_q_w = ProtoField.float("unitree.hs_imu.q.w", "W")
local hs_imu_q_x = ProtoField.float("unitree.hs_imu.q.x", "X")
local hs_imu_q_y = ProtoField.float("unitree.hs_imu.q.y", "Y")
local hs_imu_q_z = ProtoField.float("unitree.hs_imu.q.z", "Z")
local hs_imu_gyro = ProtoField.none("unitree.hs_imu.gyro", "Gyroscope")
local hs_imu_gyro_x = ProtoField.float("unitree.hs_imu.gyro.x", "X")
local hs_imu_gyro_y = ProtoField.float("unitree.hs_imu.gyro.y", "Y")
local hs_imu_gyro_z = ProtoField.float("unitree.hs_imu.gyro.z", "Z")
local hs_imu_acc = ProtoField.none("unitree.hs_imu.acc", "Acceleration")
local hs_imu_acc_x = ProtoField.float("unitree.hs_imu.acc.x", "X")
local hs_imu_acc_y = ProtoField.float("unitree.hs_imu.acc.y", "Y")
local hs_imu_acc_z = ProtoField.float("unitree.hs_imu.acc.z", "Z")
local hs_imu_rpy = ProtoField.none("unitree.hs_imu.rpy", "Angular speed")
local hs_imu_rpy_x = ProtoField.float("unitree.hs_imu.rpy.x", "X")
local hs_imu_rpy_y = ProtoField.float("unitree.hs_imu.rpy.y", "Y")
local hs_imu_rpy_z = ProtoField.float("unitree.hs_imu.rpy.z", "Z")
local hs_imu_temperature = ProtoField.uint8("unitree.hs_imu.temperature", "Temperature", base.DEC)

local hs_motorstates_array = {}
local hs_motorstates = ProtoField.none("unitree.hs_motorstates", "Motor states")
for i=1,20 do
  hs_motorstates_array[i] = fields_hs_motorstate(i)
end

local hs_bms = ProtoField.none("unitree.hs_bms", "BMS")
local hs_bms_version_h = ProtoField.uint8("unitree.hs_bms.version_h", "Version h", base.DEC_HEX)
local hs_bms_version_l = ProtoField.uint8("unitree.hs_bms.version_l", "Version l", base.DEC_HEX)
local hs_bms_bms_status = ProtoField.uint8("unitree.hs_bms.bms_status", "Status", base.DEC_HEX)
local hs_bms_soc = ProtoField.uint8("unitree.hs_bms.soc", "Percentage", base.DEC)
local hs_bms_current = ProtoField.uint32("unitree.hs_bms.current", "Current", base.DEC)
local hs_bms_cycle = ProtoField.uint16("unitree.hs_bms.cycle", "Cycles", base.DEC)
local hs_bms_bq_ntc1 = ProtoField.int8("unitree.hs_bms.bq_ntc1", "BQ NTC 1", base.DEC)
local hs_bms_bq_ntc2 = ProtoField.int8("unitree.hs_bms.bq_ntc2", "BQ NTC 2", base.DEC)
local hs_bms_mcu_ntc1 = ProtoField.int8("unitree.hs_bms.mcu_ntc1", "BQ NTC 1", base.DEC)
local hs_bms_mcu_ntc2 = ProtoField.int8("unitree.hs_bms.mcu_ntc2", "BQ NTC 2", base.DEC)
local hs_bms_voltages = ProtoField.none("unitree.hs_bms.voltages")
local hs_bms_voltages_array = {}
for i=1,10 do
  hs_bms_voltages_array[i] = ProtoField.uint16(string.format("unitree.hs_bms.voltages.%d", i), string.format("Voltage of cell %d", i), base.DEC)
end
local hs_footforce = ProtoField.none("unitree.hs_footforce", "Foot force")
local hs_footforce1 = ProtoField.int16("unitree.hs_footforce.1", "Foot force 1", base.DEC)
local hs_footforce2 = ProtoField.int16("unitree.hs_footforce.2", "Foot force 2", base.DEC)
local hs_footforce3 = ProtoField.int16("unitree.hs_footforce.3", "Foot force 3", base.DEC)
local hs_footforce4 = ProtoField.int16("unitree.hs_footforce.4", "Foot force 4", base.DEC)

local hs_footforceest = ProtoField.none("unitree.hs_footforceest", "Foot force (est), reserved")
local hs_footforceest1 = ProtoField.int16("unitree.hs_footforceest.1", "Foot force (est) 1, reserved", base.DEC)
local hs_footforceest2 = ProtoField.int16("unitree.hs_footforceest.2", "Foot force (est) 2, reserved", base.DEC)
local hs_footforceest3 = ProtoField.int16("unitree.hs_footforceest.3", "Foot force (est) 3, reserved", base.DEC)
local hs_footforceest4 = ProtoField.int16("unitree.hs_footforceest.4", "Foot force (est) 4, reserved", base.DEC)

local hs_mode = ProtoField.uint8("unitree.hs_mode", "Mode", base.DEC_HEX)
local hs_progress = ProtoField.float("unitree.hs_mode", "Progress (reserved)")
local hs_gaittype = ProtoField.uint8("unitree.hs_gaittype", "Gait type", base.DEC_HEX)
local hs_footraiseheight = ProtoField.float("unitree.hs_footraiseheight", "footRaiseHeight")
local hs_position = ProtoField.none("unitree.hs_position", "Position")
local hs_position_x = ProtoField.float("unitree.hs_position.x", "Position X")
local hs_position_y = ProtoField.float("unitree.hs_position.y", "Position y")
local hs_position_z = ProtoField.float("unitree.hs_position.z", "Position Z")
local hs_bodyheight = ProtoField.float("unitree.hs_bodyheight", "Body Height")
local hs_forwardspeed = ProtoField.float("unitree.hs_forwardspeed", "Forward speed")
local hs_sidespeed = ProtoField.float("unitree.hs_sidespeed", "Side speed")
local hs_rotationspeed = ProtoField.float("unitree.hs_rotationspeed", "Rotation speed")
local hs_yawSpeed = ProtoField.float("unitree.hs_yawspeed", "Angular body speed")
local hs_rangeobstacle = ProtoField.none("unitree.hs_rangeobstacle", "Range to obstacle")
local hs_rangeobstacle1 = ProtoField.float("unitree.hs_rangeobstacle.1", "Range 1")
local hs_rangeobstacle2 = ProtoField.float("unitree.hs_rangeobstacle.2", "Range 2")
local hs_rangeobstacle3 = ProtoField.float("unitree.hs_rangeobstacle.3", "Range 3")
local hs_rangeobstacle4 = ProtoField.float("unitree.hs_rangeobstacle.4", "Range 4")

local hs_footPosition2body_arr = {}
local hs_footPosition2body = ProtoField.none("unitree.hs_footposition2body", "Foot relative position to body")
for i=1,4 do
  hs_footPosition2body_arr[i] = fields_hs_cartesian(string.format("unitree.hs_footposition2body.leg%d", i),string.format("Leg %d", i))
end

local hs_footspeed2body_arr = {}
local hs_footspeed2body = ProtoField.none("unitree.hs_footspeed2body", "Foot relative speed to body")
for i=1,4 do
  hs_footspeed2body_arr[i] = fields_hs_cartesian(string.format("unitree.hs_footspeed2body.leg%d", i),string.format("Leg %d", i))
end

local hs_wirelessremote = ProtoField.bytes("unitree.hs_wirelessremote", "Wireless remote")
local hs_reserved = ProtoField.none("unitree.hs_reserved", "Reserved")

local hs_crc = ProtoField.uint32("unitree.hs_crc32", "CRC32", base.HEX)



--[[hs_motor_states = {}
for i=1, 20 do
  hs_motor_states[i] = ProtoField.none(string.format("unitree.hs_motorstates.ms_%d", i))
end
]]--

hs_crc_expert = ProtoExpert.new("unitree.hs_crc32_is_not_correct", "CRC32 is not correct", expert.group.CHECKSUM, expert.severity.WARN)
--[[
	std::array<MotorState, 20> motorState;
	BmsState bms;
	std::array<int16_t, 4> footForce;           // Data from foot airbag sensor
	std::array<int16_t, 4> footForceEst;        // reserve，typically zero
	uint8_t mode;                               // The current mode of the robot
	float progress;                             // reserve
	uint8_t gaitType;                           // 0.idle  1.trot  2.trot running  3.climb stair  4.trot obstacle
	float footRaiseHeight;                      // (unit: m, default: 0.08m), foot up height while walking
	std::array<float, 3> position;              // (unit: m), from own odometry in inertial frame, usually drift
	float bodyHeight;                           // (unit: m, default: 0.28m),
	std::array<float, 3> velocity;              // (unit: m/s), forwardSpeed, sideSpeed, rotateSpeed in body frame
	float yawSpeed;                             // (unit: rad/s), rotateSpeed in body frame
	std::array<float, 4> rangeObstacle;         // Distance to nearest obstacle
	std::array<Cartesian, 4> footPosition2Body; // foot position relative to body
	std::array<Cartesian, 4> footSpeed2Body;    // foot speed relative to body
	std::array<uint8_t, 40> wirelessRemote;     // Data from Unitree Joystick.
	uint32_t reserve;

	uint32_t crc;
]]



local function unitree_hs_add_motorstate(buffer, offset, motorstate, pinfo, subtree)
  subtree:add_le(motorstate.mode, buffer(offset, 1))
  offset = offset + 1
  subtree:add_le(motorstate.q, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(motorstate.dq, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(motorstate.ddq, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(motorstate.tauEst, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(motorstate.q_raw, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(motorstate.dq_raw, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(motorstate.ddq_raw, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(motorstate.temperature, buffer(offset, 1))
  offset = offset + 1
  subtree:add_le(motorstate.reserved, buffer(offset, 8))
  offset = offset + 8
  return offset  
end

experts = {hs_crc_expert}

function dissector(buffer, pinfo, subtree)
  subtree:add_le(hs_head, buffer(0,2))
  subtree:add_le(hs_levelFlag, buffer(2,1))
  subtree:add_le(hs_frameReserve, buffer(3,1))
  subtree:add_le(hs_SN, buffer(4,8))
  subtree:add_le(hs_version, buffer(12,8))
  subtree:add_le(hs_bandwidth, buffer(20,2))

  local imu_subtree = subtree:add(hs_imu, buffer(22,74), "IMU")

  local imu_q_subtree = imu_subtree:add(hs_imu_q, buffer(22,16), "Quaternion")
  imu_q_subtree:add_le(hs_imu_q_w, buffer(22,4))
  imu_q_subtree:add_le(hs_imu_q_x, buffer(26,4))
  imu_q_subtree:add_le(hs_imu_q_y, buffer(30,4))
  imu_q_subtree:add_le(hs_imu_q_z, buffer(34,4))

  local imu_g_subtree = imu_subtree:add(hs_imu_gyro, buffer(38,12), "Gyroscope")
  imu_g_subtree:add_le(hs_imu_gyro_x, buffer(38,4))
  imu_g_subtree:add_le(hs_imu_gyro_y, buffer(42,4))
  imu_g_subtree:add_le(hs_imu_gyro_z, buffer(46,4))
  
  local imu_acc_subtree = imu_subtree:add(hs_imu_acc, buffer(50,12), "Accelerometer")
  imu_acc_subtree:add_le(hs_imu_acc_x, buffer(50,4))
  imu_acc_subtree:add_le(hs_imu_acc_y, buffer(54,4))
  imu_acc_subtree:add_le(hs_imu_acc_z, buffer(58,4))

  local imu_rpy_subtree = imu_subtree:add(hs_imu_rpy, buffer(62, 12), "Euler angle")
  imu_rpy_subtree:add_le(hs_imu_rpy_x, buffer(62,4))
  imu_rpy_subtree:add_le(hs_imu_rpy_y, buffer(66,4))
  imu_rpy_subtree:add_le(hs_imu_rpy_z, buffer(70,4))

  imu_subtree:add_le(hs_imu_temperature, buffer(74,1))

  local offset = 75
  local motorstates_subtree = subtree:add(hs_motorstates, buffer(offset, 0), "Motor states")
  for i = 1, 20 do
    motorstate_subtree = motorstates_subtree:add(hs_motorstates, buffer(offset, 0), string.format("Motor state %d", i))
    offset = unitree_hs_add_motorstate(buffer, offset, hs_motorstates_array[i], pinfo, motorstate_subtree)
  end


  local bms_subtree = subtree:add(hs_bms, buffer(offset, 34), "BMS")
  bms_subtree:add_le(hs_bms_version_h, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hs_bms_version_l, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hs_bms_bms_status, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hs_bms_soc, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hs_bms_current, buffer(offset, 4))
  offset = offset + 4
  bms_subtree:add_le(hs_bms_cycle, buffer(offset, 2))
  offset = offset + 2
  bms_subtree:add_le(hs_bms_bq_ntc1, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hs_bms_bq_ntc2, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hs_bms_mcu_ntc1, buffer(offset, 1))
  offset = offset + 1
  bms_subtree:add_le(hs_bms_mcu_ntc2, buffer(offset, 1))
  offset = offset + 1
  local bms_voltage_subtree = bms_subtree:add(hs_bms_voltages, buffer(offset, 0), "Cell voltages")
  for i=1,10 do
    bms_voltage_subtree:add_le(hs_bms_voltages_array[i], buffer(offset, 2))
    offset = offset + 2
  end


  local footforce_subtree = subtree:add(hs_footforce, buffer(offset, 8), "Foot airbag sensor")
  footforce_subtree:add_le(hs_footforce1, buffer(offset, 2))
  offset = offset + 2
  footforce_subtree:add_le(hs_footforce2, buffer(offset, 2))
  offset = offset + 2
  footforce_subtree:add_le(hs_footforce3, buffer(offset, 2))
  offset = offset + 2
  footforce_subtree:add_le(hs_footforce4, buffer(offset, 2))
  offset = offset + 2


  local footforceest_subtree = subtree:add(hs_footforceest, buffer(offset, 8), "Reserved")
  footforceest_subtree:add_le(hs_footforceest1, buffer(offset, 2))
  offset = offset + 2
  footforceest_subtree:add_le(hs_footforceest2, buffer(offset, 2))
  offset = offset + 2
  footforceest_subtree:add_le(hs_footforceest3, buffer(offset, 2))
  offset = offset + 2
  footforceest_subtree:add_le(hs_footforceest4, buffer(offset, 2))
  offset = offset + 2

  subtree:add_le(hs_mode, buffer(offset, 1))
  offset = offset + 1
  subtree:add_le(hs_progress, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hs_gaittype, buffer(offset, 1))
  offset = offset + 1
  subtree:add_le(hs_footraiseheight, buffer(offset, 4))
  offset = offset + 4

  local position_subtree = subtree:add(hs_position, buffer(offset, 12))
  position_subtree:add_le(hs_position_x, buffer(offset, 4))
  offset = offset + 4
  position_subtree:add_le(hs_position_y, buffer(offset, 4))
  offset = offset + 4
  position_subtree:add_le(hs_position_z, buffer(offset, 4))
  offset = offset + 4

  subtree:add_le(hs_bodyheight, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hs_forwardspeed, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hs_sidespeed, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hs_rotationspeed, buffer(offset, 4))
  offset = offset + 4
  subtree:add_le(hs_yawSpeed, buffer(offset, 4))
  offset = offset + 4

  local rangeobstacle_subtree = subtree:add(hs_rangeobstacle, buffer(offset, 12))
  rangeobstacle_subtree:add_le(hs_rangeobstacle1, buffer(offset, 4))
  offset = offset + 4
  rangeobstacle_subtree:add_le(hs_rangeobstacle2, buffer(offset, 4))
  offset = offset + 4
  rangeobstacle_subtree:add_le(hs_rangeobstacle3, buffer(offset, 4))
  offset = offset + 4
  rangeobstacle_subtree:add_le(hs_rangeobstacle4, buffer(offset, 4))
  offset = offset + 4

  local footPosition2Body_subtree = subtree:add(hs_footPosition2body, buffer(offset, 3*4*4))
  for i=1,4 do
    local footPosition2Body_leg_subtree = footPosition2Body_subtree:add(hs_footPosition2body_arr[i].cartesian, buffer(offset, 12))
    footPosition2Body_leg_subtree:add_le(hs_footPosition2body_arr[i].x, buffer(offset, 4))
    offset = offset + 4
    footPosition2Body_leg_subtree:add_le(hs_footPosition2body_arr[i].y, buffer(offset, 4))
    offset = offset + 4
    footPosition2Body_leg_subtree:add_le(hs_footPosition2body_arr[i].z, buffer(offset, 4))
    offset = offset + 4
  end

  local footspeed2body_subtree = subtree:add(hs_footspeed2body, buffer(offset, 3*4*4))
  for i=1,4 do
    local footspeed2body_leg_subtree = footspeed2body_subtree:add(hs_footspeed2body_arr[i].cartesian, buffer(offset, 12))
    footspeed2body_leg_subtree:add_le(hs_footspeed2body_arr[i].x, buffer(offset, 4))
    offset = offset + 4
    footspeed2body_leg_subtree:add_le(hs_footspeed2body_arr[i].y, buffer(offset, 4))
    offset = offset + 4
    footspeed2body_leg_subtree:add_le(hs_footspeed2body_arr[i].z, buffer(offset, 4))
    offset = offset + 4
  end

  subtree:add(hs_wirelessremote, buffer(offset, 40), "Wireless Joystick")
  offset = offset + 40

  subtree:add_le(hs_reserved, buffer(offset, 4))
  offset = offset + 4

  subtree:add(hs_crc, buffer(offset,4))


  if crc:crc32(buffer:raw()) ~= 0 then 
    --subtree:add_proto_expert_info(hs_crc_expert, string.format("Wrong CRC")) 
  end

end

local fields = {
  hs_head,
  hs_levelFlag,
  hs_frameReserve,
  hs_SN,
  hs_version,
  hs_bandwidth,
  hs_imu_q_w,
  hs_imu_q_x,
  hs_imu_q_y,
  hs_imu_q_z,
  hs_imu_gyro_x,
  hs_imu_gyro_y,
  hs_imu_gyro_z,
  hs_imu_acc_x,
  hs_imu_acc_y,
  hs_imu_acc_z,
  hs_imu_rpy_x,
  hs_imu_rpy_y,
  hs_imu_rpy_z,
  hs_imu_temperature,
  hs_reserved,
  hs_crc,
  hs_bms_version_h,
  hs_bms_version_l,
  hs_bms_bms_status,
  hs_bms_soc,
  hs_bms_current,
  hs_bms_cycle,
  hs_bms_bq_ntc1,
  hs_bms_bq_ntc2,
  hs_bms_mcu_ntc1,
  hs_bms_mcu_ntc2,
  hs_footforce1,
  hs_footforce2,
  hs_footforce3,
  hs_footforce4,
  hs_footforceest1,
  hs_footforceest2,
  hs_footforceest3,
  hs_footforceest4,
  hs_mode,
  hs_progress,
  hs_gaittype,
  hs_footraiseheight,
  hs_position,
  hs_position_x,
  hs_position_y,
  hs_position_z,
  hs_bodyheight,
  hs_forwardspeed,
  hs_sidespeed,
  hs_rotationspeed,
  hs_yawSpeed,
  hs_rangeobstacle,
  hs_rangeobstacle1,
  hs_rangeobstacle2,
  hs_rangeobstacle3,
  hs_rangeobstacle4,
  hs_footPosition2body,
  hs_footspeed2body,
  hs_wirelessremote,
}

for k, v in pairs(hs_motorstates_array) do
  for k, v2 in pairs(v) do
    fields[#fields+1] = v2
  end
end

for k, v in pairs(hs_bms_voltages_array) do
  fields[#fields+1] = v
end

for k, v in pairs(hs_footPosition2body_arr) do
  for k, v2 in pairs(v) do
    fields[#fields+1] = v2
  end
end

for k, v in pairs(hs_footspeed2body_arr) do
  for k, v2 in pairs(v) do
    fields[#fields+1] = v2
  end
end

M.fields = fields
M.experts = experts
M.dissector = dissector

return M