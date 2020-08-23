import serial
import time
import struct
mySer = serial.Serial(port="COM4",
                      baudrate=2000000,
                      bytesize=serial.EIGHTBITS,
                      parity=serial.PARITY_NONE,
                      stopbits=serial.STOPBITS_ONE,
                      timeout=5)


mySer.close()
mySer.open()

packet = bytearray()
packet.append(0x39)
packet.append(0x06)
packet.append(0x01)
packet.append(0x03)
packet.append(0x01)
packet.append(0x03)
packet.append(0x01)
packet.append(0x03)
mySer.write(packet)

time.sleep(0.1)

result = mySer.read_all()
mySer.close()
print(result)
