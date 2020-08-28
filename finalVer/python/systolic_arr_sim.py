MATRIX_MULT = hex(0x11)
START = hex(0x31)

import serial
import numpy as np
import time
import struct

mySer = serial.Serial(port="COM4",
                      baudrate=115200,
                      bytesize=serial.EIGHTBITS,
                      parity=serial.PARITY_NONE,
                      stopbits=serial.STOPBITS_ONE,
                      timeout=5)
#mySer.close()
#mySer.open()
a = [[1,2],[3,4]]
b = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]
c = [[16,15,14,13],[12,11,10,9],[8,7,6,5],[4,3,2,1]]
# a = [[1,2],[3,4]]
# w = [[1,2],[3,4]]
A = np.array(a, np.single)
W = np.array(a, np.single)
print("A shape: ", A.shape)
print("W shape: ", W.shape)

packet = bytearray()
packet.append(0x11) # start byte
a_height = A.shape[0]
a_width = A.shape[1]
h_height = W.shape[0]
h_width = W.shape[1]
packet.append(a_height)
packet.append(a_width)
packet.append(h_height)
packet.append(h_width)
mySer.write(packet)
time.sleep(0.01)
mySer.write(A.tobytes())
time.sleep(0.01)
mySer.write(W.tobytes())
time.sleep(0.1)
comm = mySer.read_all()[3:]
length = int(len(comm)/4)
print(length)
for i in range(length):
    print(struct.unpack('>f', comm[4*i:4*i+4]))

#time.sleep(0.1)
#mySer.close()
