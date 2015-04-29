This guide assumes your root folder for the project is 'project/'.

Download all files to 'project/downloads'.


Download the Leon 3 source code:
http://www.gaisler.com/products/grlib/grlib-gpl-1.1.0-b4113.zip

Download the Leon 3 netlists for Xilinx/Altera boards:
http://www.gaisler.com/products/grlib/grlib-netlists-1.1.0.tar.gz

Leon 3 user manual:
http://www.gaisler.com/products/grlib/grlib.pdf

Leon 3 Debug monitor tool:
ftp://gaisler.com/gaisler.com/grmon/grmon-eval-1.1.52.tar.gz

Buildroot tool for configuring and crosscompiling linux:
http://www.strijar.ru/ztex/leon3-buildroot-2011.02.tar.gz


Extract the Leon 3 source code (grlib-gpl-1.1.0-b4113.zip) to the root of your
project folder (project/). Next, extract the netlists (grlib-netlists-1.1.0.tar.gz) to
the root of the source code folder (project/grlib-gpl-1.1.0-b4113/). Lastly,
extract the debug tool (grmon-eval-1.1.52.tar.gz) to the root of your project
folder (project/).

cd project/grlib-gpl-1.1.0-b4113/designs/leon3-xilinx-ml509


You can now make changes to the default Leon 3 design by running:

sudo make xconfig

A GUI should pop up and let you make configuration changes to the board.
Navigate to Processor->Integer unit
	Enable MUL/DIV instructions
	Enable branch prediction
Navigate to Processor->Floating-point unit
	Enable FPU
Lastly, 'Save and Exit'



*Note: this following command assumes you have the 'ise' binary in your path, by sourcing /opt/Xilinx/<version>/ISE_DS/settings<32|64>.sh.
This following command will create an ISE project in the /leon3-xilinx-ml509
directory. This only needs to be run once to create the project. 

make ise-launch

NOTE: any time you make changes to the VHDL design via 'sudo make
xconfig', ISE will automatically reload the changes. Therefore, if you ever
want to change the processor configuration, just modify the config with 'sudo
make xconfig' and then reimplement the design in ISE.


Xilinx ISE should launch with the project loaded.
In the process pane on the left, click 'Implement Top Module'.

If the following errors occur during synthesizing:
ERROR:Xst:1249 - Missing part name parameter (-p)
ERROR:Xst:425 - Undefined command: -uc

Modify project/grlib-gpl-1.1.0-b4113/designs/leon3-xilinx-ml509/leon3mp.xst:

Replace the lines 5-9 causing the errors (shown:)
 -uc leon3mp.xcf
-ifmt mixed
-ofn leon3mp
-ofmt NGC
-p xc5vlx110t-1-ff1136

with the correct lines that will parse correctly (shown:)
-ifmt mixed
-ofn leon3mp
-ofmt NGC
-p xc5vlx110t-1-ff1136
-uc leon3mp.xcf

IMPORTANT NOTE: THIS FILE NEEDS TO BE MADE IMMUTABLE
ISE will attempt to change or delete/recreate leon3mp.xst every time XST runs.
To keep the file correctly patched, apply the following commands:
chmod 555 leon3mp.xst
sudo chattr +i leon3mp.xst

XST should produce a warning in its console saying that it could not access
leon3mp.xst, but the process will then continue without errors.

Once the design is synthesized and implemented, double click on 'Generate
Programming File' to create the final bitfile.

Once the programming file has been generated, program the FPGA with the
configuration file via Xilinx iMPACT:

*NOTE: The FPGA board should be on and connected via usb jtag to the host
machine.

To do so, launch impact. Perform a boundary scan, initialize the jtag chain, assign the newly created bitfile in the leon3-xilinx-ml509 directory as the configuration file, and then program the file.


To test your completed setup, navigate to project/grmon-eval/linux. Here, run:

./grmon-eval -xilusb

This launches the leon3 debug program that communicates to the board via j-tag.

In another terminal, start a serial communications program (minicom is used in this guide). Serial settings:
baud: 38400
bits: 8
Parity: odd, 1 bit

In the debugger, run:

> load ../samples/dhry.exe 
> run

You should see minicom report that the board has run a Dhrystone benchmark.





The Leon 3 processor is now properly configured. The next step is to generate a linux image.
Unpack project/downloads/leon3-buildroot-2011.02.tar.gz to project/ . Navigate to the extracted folder. Run:

sudo make xconfig (if you have qt installed)
sudo make menuconfig (if you don't)

This is the configuration page for buildroot, which is an automated tool that takes care of crosscompilation as well as packaging the result into a bootable image for our board. This particular distrobution of buildroot is specially configured for our Leon 3 processor (and also contains necessary patches needed for the processor). The only thing here we need to change is, under 'system configuration', select 'Generic serial port config'. Make sure to select baud=38400. Later on, feel free to explore the other options to include debugging tools and other libraries. Save the changes and exit.


Navigate to project/leon3-buildroot-2011.02/. Run 'sudo make'.

Buildroot will now use its included x86_64 to SPARC crosscompiler to build the linux image. This process may fail when downloading and extracting packages if it cannot download them -- if this happens, it should be apparent which one by the terminal output. Just google the name of the missing package and place it in project/leon3-buildroot-2011.02/dl folder. Then, rerun 'sudo make'.

Once the image is built, we need to use a utility included in buildroot that makes the linux image loadable and bootable via the Leon 3 debug tool. To do so: navigate to project/leon3-buildroot-2011.02/board/leon3. Run 'sudo ./make_dsu'. This will create a file 'image.dsu' in project/leon3-buildroot-2011.02/output/images. Copy this file to the project/grmon-eval/linux directory. Now to load and run the image:

Navigate to project/grmon-eval/linux.
IMPORTANT: Running './grmon-eval -xilusb' as before will FAIL to run, as it will halt on software traps. Make sure to include the '-nb' argument:
'./grmon-eval -xilusb -nb'
> load image.dsu
In another terminal, open minicom with the same settings as mentioned before.
In the debugger:
> run


In minicom, you should be able to interact with the linux environment. Login with username 'root', no password.






Crosscompiling code and loading files to the image:

Read project/leon3-buildroot-2011.02/docs/buildroot.html for information on how to use the crosscompiler to generate your own c programs for the Leon 3. Once you have compiled your code successfully, place the executable in project/leon3-buildroot-2011.02/output/target/root (or anywhere in the target filesystem). Then, remake the linux image and rerun make_dsu. Booting from this new image will include your files.


