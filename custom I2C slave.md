#writing #draft #implementation

[[previous chapter]]

![[pladitor_diagram (1) 1.svg]]
This finite state machine (FSM) illustrates the operation of an I2C slave peripheral. The FSM begins in the “idle” state, waiting for the start of a communication cycle. Upon receiving a “START” signal, it transitions to the “get_address_and_cmd” state, where it acquires the address and command for the impending transaction. If the address does not match the predefined slave address of the custom IP, the FSM reverts to “idle”. Additionally, if the IP is instructed to perform a read operation without being assigned a target register address, the FSM also returns to “idle”.

After successfully matching the address, the FSM can transition to either “read” or “write” states based on the provided command. In the “write” state, the slave samples SDA on the rising edges of SCL and stores the data in the specified register. Once all bits are processed and the next SCL falling edge is detected, the system moves to the “after_write_ack” state. Here, the slave pulls SDA low until the subsequent SCL falling edge to acknowledge the completed write to the master. The FSM then returns to “write” to process more data or wait for a STOP signal to terminate the transfer.

In parallel, in the “read” state, the slave drives SDA low or release it based on the specified register data during SCL falling edges, ensuring SDA only changes when SCL is low. After processing all bits, the FSM transfers to “read_ack_start”. It then samples SDA on the SCL rising edge and transitions to “read_ack_got_rising”. Based on the acknowledgment received from the master (ACK or NACK), the system can either finish the read in “read_stop” or return to “read” on the next SCL falling edge.

Importantly, a START signal at any time moves the FSM to “get_address_and_cmd”, while a STOP signal transitions it to “idle”, beyond the explicit state transfer diagrammed.

