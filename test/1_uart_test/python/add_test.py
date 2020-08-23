import serial
import time
import struct
'''
mySer = serial.Serial(port="COM4",
                      baudrate=9600,
                      bytesize=serial.EIGHTBITS,
                      parity=serial.PARITY_NONE,
                      stopbits=serial.STOPBITS_ONE,
                      timeout=5)
'''

def fumpy_mul(a, b):
    mySer.close()
    mySer.open()
    a = float(a)
    b = float(b)
    mySer.write(struct.pack(">f", a))
    mySer.write(struct.pack(">f", b))
    time.sleep(0.1)
    result = struct.unpack(">f", mySer.read_all())[0]
    mySer.close()
    print(" %f times %f is %f" % (a, b, result))
    return result


#fumpy_mul(6.0, 7.0)
print(struct.pack(">f", float(1.0)))
