# Synchronous-FIFO

A **FIFO buffer** is an elastic storage component used between two subsystems operating at different speeds. It temporarily stores data so that information can be transferred smoothly even when the producer generates data faster than the consumer can process it.

```
Fast Producer  ─────► [ FIFO BUFFER ] ─────► Slow Consumer
```

The fundamental principle of FIFO is:

> **First data written is the first data read.**

This preserves ordering, making FIFO ideal for buffering sequential data streams.

# Features of this implementation

- **Parameterized** FIFO depth and width
- Circular queue implementation
- Full and Empty flag generation
- Concurrent read/write support
- Pointer wraparound handling

# Internal structure of FIFO

Internally, FIFO memory is treated as a **circular queue** rather than a linear array. This means that after the final memory location is reached, the next location wraps around to the first entry.

```
        +-------+
   [0]  |       |  [15]
 [1]    | FIFO  |    [14]
 [2]    | MEM   |    [13]
   [3]  |       |  [...]
        +-------+
```

This circular organization simplifies hardware implementation because pointers can continuously increment and wrap around instead of requiring data shifting.

## Circular queue

It is implement through a counter that generates addresses, the circular queue is implemented through the counter 'overflowing' and reverting back to 0. 

The RTL design is **Parameterized**, But for the current implementation the ram is configured to be 16x8, meaning, it has 8 bit wide memory elements 16 in number. Addresses ranging from 0000 to 1111. The counter is a bit wider, since the MSBs are used to record the phase of the write pointer and read pointer, which are used to determine full and empty flags. 

# Organization

### Internal
![[intrnl_org.png]]

### Top level Datapath
![[datpth_org.png]]

# Full Flag

The FULL flag indicates that the FIFO has reached **maximum capacity**, and no further writes can be safely performed without overwriting unread data.
### Implementation

```verilog
assign full_flag = (w_ptr == r_ptr) && (w_phase != r_phase);
```

# Empty Flag

The EMPTY flag indicates that the FIFO has reached **minimum capacity**, and no further read will take place. 
### Implementation

```verilog
assign empty_flag = (w_cnt == r_cnt);
```


# Simulation Log

| Time   | wr  | rd  | data_in | data_out | w_ptr | r_ptr | full | empty |
| ------ | --- | --- | ------- | -------- | ----- | ----- | ---- | ----- |
| 0      | 0   | 0   | 00      | 00       | 0     | 0     | 0    | 1     |
| 25000  | 1   | 0   | 24      | 00       | 0     | 0     | 0    | 1     |
| 30000  | 1   | 0   | 24      | 00       | 1     | 0     | 0    | 0     |
| 35000  | 1   | 0   | 81      | 00       | 1     | 0     | 0    | 0     |
| 40000  | 1   | 0   | 81      | 00       | 2     | 0     | 0    | 0     |
| 45000  | 1   | 0   | 09      | 00       | 2     | 0     | 0    | 0     |
| 50000  | 1   | 0   | 09      | 00       | 3     | 0     | 0    | 0     |
| 55000  | 1   | 0   | 63      | 00       | 3     | 0     | 0    | 0     |
| 60000  | 1   | 0   | 63      | 00       | 4     | 0     | 0    | 0     |
| 65000  | 0   | 0   | 63      | 00       | 4     | 0     | 0    | 0     |
| 75000  | 0   | 1   | 63      | 00       | 4     | 0     | 0    | 0     |
| 80000  | 0   | 1   | 63      | 24       | 4     | 1     | 0    | 0     |
| 90000  | 0   | 1   | 63      | 81       | 4     | 2     | 0    | 0     |
| 100000 | 0   | 1   | 63      | 09       | 4     | 3     | 0    | 0     |
| 110000 | 0   | 1   | 63      | 63       | 4     | 4     | 0    | 1     |
| 115000 | 0   | 0   | 63      | 63       | 4     | 4     | 0    | 1     |
| 125000 | 1   | 0   | 0d      | 63       | 4     | 4     | 0    | 1     |
| 130000 | 1   | 0   | 0d      | 63       | 5     | 4     | 0    | 0     |
| 135000 | 1   | 0   | 8d      | 63       | 5     | 4     | 0    | 0     |
| 140000 | 1   | 0   | 8d      | 63       | 6     | 4     | 0    | 0     |
| 145000 | 1   | 0   | 65      | 63       | 6     | 4     | 0    | 0     |
| 150000 | 1   | 0   | 65      | 63       | 7     | 4     | 0    | 0     |
| 155000 | 1   | 0   | 12      | 63       | 7     | 4     | 0    | 0     |
| 160000 | 1   | 0   | 12      | 63       | 8     | 4     | 0    | 0     |
| 165000 | 1   | 0   | 01      | 63       | 8     | 4     | 0    | 0     |
| 170000 | 1   | 0   | 01      | 63       | 9     | 4     | 0    | 0     |
| 175000 | 1   | 0   | 0d      | 63       | 9     | 4     | 0    | 0     |
| 180000 | 1   | 0   | 0d      | 63       | 10    | 4     | 0    | 0     |
| 185000 | 1   | 0   | 76      | 63       | 10    | 4     | 0    | 0     |
| 190000 | 1   | 0   | 76      | 63       | 11    | 4     | 0    | 0     |
| 195000 | 1   | 0   | 3d      | 63       | 11    | 4     | 0    | 0     |
| 200000 | 1   | 0   | 3d      | 63       | 12    | 4     | 0    | 0     |
| 205000 | 1   | 0   | ed      | 63       | 12    | 4     | 0    | 0     |
| 210000 | 1   | 0   | ed      | 63       | 13    | 4     | 0    | 0     |
| 215000 | 1   | 0   | 8c      | 63       | 13    | 4     | 0    | 0     |
| 220000 | 1   | 0   | 8c      | 63       | 14    | 4     | 0    | 0     |
| 225000 | 1   | 0   | f9      | 63       | 14    | 4     | 0    | 0     |
| 230000 | 1   | 0   | f9      | 63       | 15    | 4     | 0    | 0     |
| 235000 | 1   | 0   | c6      | 63       | 15    | 4     | 0    | 0     |
| 240000 | 1   | 0   | c6      | 63       | 0     | 4     | 0    | 0     |
| 245000 | 1   | 0   | c5      | 63       | 0     | 4     | 0    | 0     |
| 250000 | 1   | 0   | c5      | 63       | 1     | 4     | 0    | 0     |
| 255000 | 1   | 0   | aa      | 63       | 1     | 4     | 0    | 0     |
| 260000 | 1   | 0   | aa      | 63       | 2     | 4     | 0    | 0     |
| 265000 | 1   | 0   | e5      | 63       | 2     | 4     | 0    | 0     |
| 270000 | 1   | 0   | e5      | 63       | 3     | 4     | 0    | 0     |
| 275000 | 1   | 0   | 77      | 63       | 3     | 4     | 0    | 0     |
| 280000 | 1   | 0   | 77      | 63       | 4     | 4     | 1    | 0     |
| 285000 | 1   | 1   | 12      | 63       | 4     | 4     | 1    | 0     |
| 290000 | 1   | 1   | 12      | 0d       | 5     | 5     | 1    | 0     |

