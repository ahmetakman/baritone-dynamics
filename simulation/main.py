# This file will contain all tha main part of the simulation
# insert argument set

import sys
import os
import argparse
import time

#define arguments as velocity, time, and distance
parser = argparse.ArgumentParser(description='Simulate a car moving at a constant velocity')
parser.add_argument('velocity', type=float, help='Velocity of the car in m/s')
parser.add_argument('time', type=float, help='Time in seconds')


args = parser.parse_args()
