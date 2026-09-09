make_vhdl_prom sound2.716 SND_ROM.vhd

copy /b v_ic7.532 + v_ic5.532 + v_ic6.532 spch_rom.bin
make_vhdl_prom spch_rom.bin SPCH_ROM.vhd

pause