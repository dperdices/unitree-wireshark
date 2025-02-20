crc = require('CRC32')
hs = require('unitree_hs')
hc = require('unitree_hc')
local function tableConcat(t1,t2)
  for i=1,#t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

unitree_protocol = Proto("unitree",  "Unitree High level protocol")


unitree_hs = ProtoField.bool("unitree.hs", "Unitree High State Data")
unitree_hc = ProtoField.bool("unitree.hc", "Unitree High Command Data")

unitree_protocol.fields = {
  unitree_hs, unitree_hc
}

unitree_protocol.fields = tableConcat(hs.fields, hc.fields)

unitree_protocol.experts = hs.experts

function unitree_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = unitree_protocol.name

  if length == 1087 then
    local subtree = tree:add(unitree_protocol, buffer(), "Unitree High State Data")
    
    hs.dissector(buffer, pinfo, subtree)
  elseif length == 129 then
    local subtree = tree:add(unitree_protocol, buffer(), "Unitree High Command Data")

    hc.dissector(buffer, pinfo, subtree)
  else
    local subtree = tree:add(unitree_protocol, buffer(), "Unitree ??? Data")
  end

end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(8090, unitree_protocol)