import serial
import time
import struct
import numpy as np

mySer = serial.Serial(port="COM4",
                      baudrate=115200,
                      bytesize=serial.EIGHTBITS,
                      parity=serial.PARITY_NONE,
                      stopbits=serial.STOPBITS_ONE,
                      timeout=5)

MATRIX_MULT = hex(0x11)
START = hex(0x31)

def fumpy_dot (a, b):
    a = np.array(a, np.single)
    b = np.array(b, np.single)

    a_height_expand = False
    a_width_expand= False
    b_height_expand = False
    b_width_expand = False

    # reshape a if odd size
    if (a.shape[0] % 2) != 0:
        a_height_expand = True
        print("matrix a have odd height, padding row...")
        a = np.vstack([a, np.zeros(a.shape[1], dtype = np.single)])

    if (a.shape[1] % 2) != 0 :
        a_width_expand = True
        print("matrix a have odd weidth, padding colomn...")
        a = np.hstack((a, (np.zeros(shape=(a.shape[0], 1), dtype = np.single))))

    if (b.shape[0] % 2) != 0:
        b_height_expand = True
        print("matrix b have odd height, padding row...")
        b = np.vstack([b, np.zeros(b.shape[1], dtype=np.single)])

    if (b.shape[1] % 2) != 0:
        b_width_expand = True
        print("matrix a have odd weidth, padding colomn...")
        b = np.hstack((b, (np.zeros(shape=(b.shape[0], 1), dtype=np.single))))

    try:
        mySer.open()
    except serial.serialutil.SerialException:
        pass

    packet = bytearray()
    packet.append(0x11)  # start byte
    a_height = a.shape[0]
    a_width = a.shape[1]
    h_height = b.shape[0]
    b_width = b.shape[1]
    packet.append(a_height)
    packet.append(a_width)
    packet.append(h_height)
    packet.append(b_width)
    mySer.write(packet)
    time.sleep(0.1)
    mySer.write(a.tobytes())
    time.sleep(0.1)
    mySer.write(b.tobytes())
    time.sleep(0.5)
    comm = mySer.read_all()[3:]
    length = int(len(comm) / 4)
    result = np.zeros((a_height,a_width), dtype=np.single)
    ptr = 0
    for i in range (int(a_height/2)):
        for j in range (int(b_width/2)):
            result[2 * i][2 * j] = struct.unpack('>f', comm[4 * ptr: 4 * ptr + 4])[0]
            ptr += 1
            result[2 * i][2 * j + 1] = struct.unpack('>f', comm[4 * ptr: 4 * ptr + 4])[0]
            ptr += 1
            result[2 * i + 1][2 * j] = struct.unpack('>f', comm[4 * ptr: 4 * ptr + 4])[0]
            ptr += 1
            result[2 * i + 1][2 * j + 1] = struct.unpack('>f', comm[4 * ptr: 4 * ptr + 4])[0]
            ptr += 1
            pass
    if a_width_expand and b_height_expand:
        pass # should be safe case
    if a_height_expand:
        pass
        #result = result[0:-1, :]
    if b_width_expand:
        pass
        #result = result[:, 0:-1]
    return result


n = 22
a = np.array(np.random.rand(n,n), dtype=np.single)
b = np.array(np.random.rand(n,n), dtype=np.single)

standard = np.dot(a,b)
print("numpy result: ")
print(standard)
fumpy_result = fumpy_dot(a,b)
print("fumpy result: ")
print(fumpy_result)

error = np.std(standard - fumpy_result)
print("error = ", error)
