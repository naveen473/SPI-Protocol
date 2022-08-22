module FullTB();

reg clk; // Clock which is sent from the testbench to the master.
reg reset; // Reset which is sent from the testbench to all the modules.
reg start; // This signals the master to start the transmission (also the master will read "masterDataToSend" in order to send it to the slave).
reg [1:0] slaveSelect; // This tells the master which slave to transmit to. It should be read by the master when "start" becomes high.
reg [7:0] masterDataToSend; // What data should the master send to the slave during the transmission
wire [7:0] masterDataReceived; // What data did the master receive from the slave during the past transmission
reg [7:0] slaveDataToSend [0:2]; // What data should the slave send to the master during the transmission
wire [7:0] slaveDataReceived [0:2]; // What data did the slave receive from the master during the past transmission
wire SCLK; // The clock generated by the master for the transmission. The master uses the "clk" to generate this signal. Both the master and the slave can only use this signal for synchronizing the transmission. 
wire [0:2] CS; // The chip select signal used by the master to select a slave. If a slave is selected, the master should set its corresponding CS to 0 (active low).
wire MOSI; // The data signal going from the master to the slave.
wire MISO; // The data signal going from the slave to the master.

// Here we create an instance of the master
Master UUT_M(
	clk, reset,
	start, slaveSelect, masterDataToSend, masterDataReceived,
	SCLK, CS, MOSI, MISO
);
// Here we create 3 instances of the slave
Slave UUT_S0(
	reset,
	slaveDataToSend[0], slaveDataReceived[0],
	SCLK, CS[0], MOSI, MISO
);
Slave UUT_S1(
	reset,
	slaveDataToSend[1], slaveDataReceived[1],
	SCLK, CS[1], MOSI, MISO
);
Slave UUT_S2(
	reset,
	slaveDataToSend[2], slaveDataReceived[2],
	SCLK, CS[2], MOSI, MISO
);

// The period of 1 clock cycle of the "clk"
localparam PERIOD = 20;
// How many test cases we have
localparam TESTCASECOUNT = 2;

// These wires will hold the test case data that will be transmitted by the master and slaves
wire [7:0] testcase_masterData [1:TESTCASECOUNT];
wire [7:0] testcase_slaveData  [1:TESTCASECOUNT][0:2];

assign testcase_masterData[1] = 8'b01010011;
assign testcase_slaveData[1][0] = 8'b00001001;
assign testcase_slaveData[1][1] = 8'b00100010;
assign testcase_slaveData[1][2] = 8'b10000011;

assign testcase_masterData[2] = 8'b00111100;
assign testcase_slaveData[2][0] = 8'b10011000;
assign testcase_slaveData[2][1] = 8'b00100101;
assign testcase_slaveData[2][2] = 8'b11000010;

// index will be used for looping over test cases
// failures will store the number of failed test cases
integer index, failures;

initial begin
	// Initialinzing the variables
	index = 0;
	failures = 0;
	// Initializing the inputs and reseting the units under test
	clk = 0; // Initialize the clock signal
    reset = 1; // Set reset to 1 in order to reset all the modules
	start = 0;
	masterDataToSend = 0;
	for(slaveSelect = 0; slaveSelect < 3; slaveSelect=slaveSelect+1) slaveDataToSend[slaveSelect] = 0;
	// Reset Done is done so set reset back to 0 after 1 clock cycle
	#PERIOD reset = 0;
	// Loop over all test cases
	for(index = 1; index <= TESTCASECOUNT; index=index+1) begin
		$display("Running test set %d", index);
		// Loop over slaves and give them the data they should send to the master
		for(slaveSelect = 0; slaveSelect < 3; slaveSelect=slaveSelect+1) 
			slaveDataToSend[slaveSelect] = testcase_slaveData[index][slaveSelect];
		// Set the data that the master should send
		masterDataToSend = testcase_masterData[index];
		// Loop over slaves and initiate transmission with each one of them
		for(slaveSelect = 0; slaveSelect < 3; slaveSelect=slaveSelect+1) begin
			start = 1; // Set start to 1 to initiate transmission
			#PERIOD start = 0; // Wait for 1 period then set start back to 0
			// Wait for 20 periods to make sure that the transmission is done
			// NOTE: 8 periods should be enough but I am leaving room for other design choices (such as making the SCLK slower than the clk).
			#(PERIOD*20);
			// Check that the master correctly received the data that should have been sent by the slave
			if(masterDataReceived == slaveDataToSend[slaveSelect]) $display("From Slave %d to Master: Success", slaveSelect);
			else begin
				$display("From Slave %d to Master: Failure (Expected: %b, Received: %b)", slaveSelect, slaveDataToSend[slaveSelect], masterDataReceived);
				failures = failures + 1;
			end
			// Check that the slave correctly received the data that should have been sent by the master
			if(slaveDataReceived[slaveSelect] == masterDataToSend) $display("From Master to Slave %d: Success", slaveSelect);
			else begin
				$display("From Master to Slave %d: Failure (Expected: %b, Received: %b)", slaveSelect, masterDataToSend, slaveDataReceived[slaveSelect]);
				failures = failures + 1;
			end
		end
	end
	// Display a SUCCESS or a FAILURE message based on the test outcome
	if(failures) $display("FAILURE: %d out of %d testcases have failed", failures, 3*2*TESTCASECOUNT);
	else $display("SUCCESS: All %d testcases have been successful", 3*2*TESTCASECOUNT);
end

// Toggle the clock every half period
always #(PERIOD/2) clk = ~clk;

endmodule
