# SPI-Protocol
The Serial Peripheral Interface (SPI) is a synchronous serial communication interface specification used for short-distance communication, primarily in embedded systems. The interface was developed by Motorola in the mid-1980s and has become a de facto standard. Typical applications include Secure Digital cards and liquid crystal displays.  SPI devices communicate in full duplex mode using a master-slave architecture usually with a single master (though some Atmel devices support changing roles on the fly depending on an external (SS) pin). The master (controller) device originates the frame for reading and writing. Multiple slave-devices may be supported through selection with individual chip select (CS), sometimes called slave select (SS) lines.
One unique benefit of SPI is the fact that data can be transferred without interruption. Any number of bits can be sent or received in a continuous stream. With I2C and UART, data is sent in packets, limited to a specific number of bits. Start and stop conditions define the beginning and end of each packet, so the data is interrupted during transmission.

Devices communicating via SPI are in a master-slave relationship. The master is the controlling device (usually a microcontroller), while the slave (usually a sensor, display, or memory chip) takes instruction from the master. The simplest configuration of SPI is a single master, single slave system, but one master can control more than one slave (more on this below).

[![](RackMultipart20221004-1-uc1opb_html_55a8bff21e86825a.png)](https://www.circuitbasics.com/wp-content/uploads/2016/01/Introduction-to-SPI-Master-and-Slave.png)

**MOSI (Master Output/Slave Input)** – Line for the master to send data to the slave.

**MISO (Master Input/Slave Output)** – Line for the slave to send data to the master.

**SCLK (Clock)** – Line for the clock signal.

**SS/CS (Slave Select/Chip Select)** – Line for the master to select which slave to send data to.

# HOW SPI WORKS THE CLOCK

The clock signal synchronizes the output of data bits from the master to the sampling of bits by the slave. One bit of data is transferred in each clock cycle, so the speed of data transfer is determined by the frequency of the clock signal. SPI communication is always initiated by the master since the master configures and generates the clock signal.

Any communication protocol where devices share a clock signal is known as _synchronous._ SPI is a synchronous communication protocol. There are also _asynchronous_ methods that don't use a clock signal. For example, in UART communication, both sides are set to a pre-configured baud rate that dictates the speed and timing of data transmission.

The clock signal in SPI can be modified using the properties of _clock polarity_ and _clock phase_. These two properties work together to define when the bits are output and when they are sampled. Clock polarity can be set by the master to allow for bits to be output and sampled on either the rising or falling edge of the clock cycle. Clock phase can be set for output and sampling to occur on either the first edge or second edge of the clock cycle, regardless of whether it is rising or falling.

# SLAVE SELECT

The master can choose which slave it wants to talk to by setting the slave's CS/SS line to a low voltage level. In the idle, non-transmitting state, the slave select line is kept at a high voltage level. Multiple CS/SS pins may be available on the master, which allows for multiple slaves to be wired in parallel. If only one CS/SS pin is present, multiple slaves can be wired to the master by daisy-chaining.

# MULTIPLE SLAVES

SPI can be set up to operate with a single master and a single slave, and it can be set up with multiple slaves controlled by a single master. There are two ways to connect multiple slaves to the master. If the master has multiple slave select pins, the slaves can be wired in parallel like this:

[![](RackMultipart20221004-1-uc1opb_html_6e423439cf696bae.png)](https://www.circuitbasics.com/wp-content/uploads/2016/01/Introduction-to-SPI-Multiple-Slave-Configuration-Separate-Slave-Select.png)

If only one slave select pin is available, the slaves can be daisy-chained like this:

[![](RackMultipart20221004-1-uc1opb_html_503f913ee3139c8a.png)](https://www.circuitbasics.com/wp-content/uploads/2016/01/Introduction-to-SPI-Multiple-Slave-Configuration-Daisy-Chained.png)

# MOSI AND MISO

The master sends data to the slave bit by bit, in serial through the MOSI line. The slave receives the data sent from the master at the MOSI pin. Data sent from the master to the slave is usually sent with the most significant bit first.

The slave can also send data back to the master through the MISO line in serial. The data sent from the slave back to the master is usually sent with the least significant bit first.

# STEPS OF SPI DATA TRANSMISSION

1. The master outputs the clock signal:

[![](RackMultipart20221004-1-uc1opb_html_69068176af344b72.png)](https://www.circuitbasics.com/wp-content/uploads/2016/01/Introduction-to-SPI-Data-Transmission-Diagram-Clock-Signal.png)

2. The master switches the SS/CS pin to a low voltage state, which activates the slave:

[![](RackMultipart20221004-1-uc1opb_html_82ef07cf3f806f30.png)](https://www.circuitbasics.com/wp-content/uploads/2016/01/Introduction-to-SPI-Data-Transmission-Diagram-Slave-Select-Activation.png)

3. The master sends the data one bit at a time to the slave along the MOSI line. The slave reads the bits as they are received:

[![](RackMultipart20221004-1-uc1opb_html_1785c0625b91a5ae.png)](https://www.circuitbasics.com/wp-content/uploads/2016/01/Introduction-to-SPI-Data-Transmission-Diagram-Master-to-Slave-Data-Transfer.png)

4. If a response is needed, the slave returns data one bit at a time to the master along the MISO line. The master reads the bits as they are received:

[![](RackMultipart20221004-1-uc1opb_html_d96c4efeb27015d1.png)](https://www.circuitbasics.com/wp-content/uploads/2016/01/Introduction-to-SPI-Data-Transmission-Diagram-Slave-to-Master-Data-Transfer.png)

# ADVANTAGES AND DISADVANTAGES OF SPI

There are some advantages and disadvantages to using SPI, and if given the choice between different communication protocols, you should know when to use SPI according to the requirements of your project:

# ADVANTAGES

- No start and stop bits, so the data can be streamed continuously without interruption
- No complicated slave addressing system like I2C
- Higher data transfer rate than I2C (almost twice as fast)
- Separate MISO and MOSI lines, so data can be sent and received at the same time

# DISADVANTAGES

- Uses four wires (I2C and UARTs use two)
- No acknowledgement that the data has been successfully received (I2C has this)
- No form of error checking like the parity bit in UART
- Only allows for a single master
