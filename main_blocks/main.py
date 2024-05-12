""""
This file will be the main file that will run the program.
Phases,
1. Turn the robot around.
2. Collect data (angles from encoder, antenna data from UDP.) while turning around.
3. Calculate the angle of the emitter device.
4. Move the robot to the calculated angle.
5. Move forward.
5. Collect data (angles from encoder, antenna data from UDP.) while moving.
6. Compare the collected antenna data. (continuously)
7. If the data is the same, continue the robot. (move until the robot loses the emitter)
8. If the data is different, stop the robot and calculate the angle of the emitter device. (smalller angle search algorithm)
"""
import time
import numpy as np
import socket
import subprocess

def motor_controller():
    print("Robot function is running.")
    time.sleep(5)
    print("Robot function is done.")

def read_robot_angle():
    print("Read robot angle function is running.")
    time.sleep(5)
    print("Read robot angle function is done.")

def initialize_receiver():

    # enter the absolute path of the src/initial_code.py
    process = subprocess.Popen(["python", "akman/METU EEE UNDERGRADUATE EDUCATION/8thTermSpring2024/EE494/codes/python-pluto/BaritoneDynamics-SDR-client/src/initial_code.py"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)#
    return True

def read_antenna_data(sock):
    gain, address = sock.recvfrom(24) # check whether our buffer size is enough
    # b'3269000000.0,80.3457\n'
    # decode it if necessary
    gain = gain.decode('utf-8')
    gain = gain.split(',')[1].split('\n')[0]
    return gain

def init_socket():
    # Create a UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # Server address and port
    server_address = ('localhost', 10000)

    # Bind the socket to the server address
    sock.bind(server_address)

    print('UDP Server is ready to receive data...')
    return sock

def initialize_robot():
    print("Robot is initializing.")
    time.sleep(5)
    print("Robot is initialized.")

def initial_turn(sock):
    estimation_group_angles = []
    estimation_group_gains = []
    # turn the robot 360 degrees
    motor_controller()
    initial_angle = read_robot_angle()

    # collect data while turning
    while True:
        # read the robot angle
        estimation_group_angles.append(read_robot_angle())
        # read the antenna data
        estimation_group_gains.append(read_antenna_data())
        if estimation_group_angles[-1] == initial_angle:
            break
    
    # calculate the angle of the emitter device
    emitter_angle_gain = np.max(estimation_group_gains)
    emitter_angle = estimation_group_angles[np.argmax(estimation_group_gains)]
    return emitter_angle, emitter_angle_gain

def main():

    print("Main function is running.")

    # initialize the receiver
    initialize_receiver()
    time.sleep(5)
    # initialize the socket
    sock = init_socket()

    for i in range(100):
        gain = read_antenna_data(sock)
        print("Gain: ", gain)
        

    
    # initial turn
    emitter_angle, emitter_angle_gain = initial_turn(sock)
    print("Emitter angle: ", emitter_angle)
    print("Emitter angle gain: ", emitter_angle_gain)


    


if __name__ == "__main__":
    main()