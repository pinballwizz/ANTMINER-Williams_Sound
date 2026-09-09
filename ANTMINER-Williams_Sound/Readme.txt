Williams D-8224 Sound Board with C-8226 Speech Board for the ANTMINER S9 ZYNQ-7010 FPGA Board. Pinballwiz 2026
Code from DarFPGA.

Notes:
Setup for keyboard Sound Inputs
Consult the Docs Folder for Information regarding peripheral connections and schematics.

Build:
* Obtain correct roms file for Gorgar or Similar Williams Title (see scripts in tools folder for rom details).
* Unzip rom files to the tools folder.
* Run the make snd proms script in the tools folder.
* Place the generated prom files inside the proms folder.
* Open the ANTMINER-Williams_Sound project file using Vivado (v2022.2 or silimar is recommended)
* Compile the project updating filepaths to source files as necessary.
* If not using Zynq Arcade Platform connect JTAG Programmer and program ANTMINER S9 Board.
* If using Zynq Arcade (see the github repo) copy bitstream file to MicroSD Card and sys reset ANTMINER S9 Adapter board to load.