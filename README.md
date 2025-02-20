# unitree-wireshark
Wireshark dissector to decode Unitree HighState and HighCmd protocols


## How to install

```bash
export WIRESHARK_PLUGINDIR=~/.config/wireshark/plugins/
mkdir -p $WIRESHARK_PLUGINDIR
curl https://raw.githubusercontent.com/dperdices/unitree-wireshark/refs/heads/master/CRC32.lua > $WIRESHARK_PLUGINDIR/CRC32.lua
curl https://raw.githubusercontent.com/dperdices/unitree-wireshark/refs/heads/master/unitree.lua > $WIRESHARK_PLUGINDIR/unitree.lua
curl https://raw.githubusercontent.com/dperdices/unitree-wireshark/refs/heads/master/unitree_hs.lua > $WIRESHARK_PLUGINDIR/unitree_hs.lua
curl https://raw.githubusercontent.com/dperdices/unitree-wireshark/refs/heads/master/unitree_hc.lua > $WIRESHARK_PLUGINDIR/unitree_hc.lua
```

