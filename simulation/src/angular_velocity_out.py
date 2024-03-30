
import time
import random

# A proportional controller that calculates the angular velocity needed to reach a target angle
def target_angle_to_angular_velocity(target_angle, current_angle, controller_gain = 1.0):
    # Calculate the difference between the target angle and the current angle
    angle_difference = target_angle - current_angle

    # Calculate the angular velocity needed to reach the target angle
    angular_velocity = angle_difference * controller_gain 

    return angular_velocity


def real_angle_to_receiver_gain(real_angle, receiver_gain = 1.0, uncertainity_factor = 0.2):
    # Calculate the receiver gain
    moderate_gain_angle = 10 # this will be plus or minus
    
    moderate_gain = 0.5
    high_gain = 1.0

    if real_angle < moderate_gain_angle and real_angle > -moderate_gain_angle:
        receiver_gain = moderate_gain + uncertainity_factor * random.random()
    else:
        receiver_gain = high_gain + uncertainity_factor * random.random()
    return receiver_gain


def angular_velocity_to_current_angle(angular_velocity, current_angle, dt):
    # Calculate the new angle based on the angular velocity
    t_plus_one_angle = current_angle + angular_velocity * dt
    return t_plus_one_angle

def main():
    # Test the function
    target_angle = 5
    current_angle = 0
    controller_gain = 3
    angular_vels = []
    dt = 0.2
    uncertainity_factor = 0.1
    for i in range(100):
        angular_velocity = target_angle_to_angular_velocity(target_angle, current_angle, controller_gain)
        current_angle = angular_velocity_to_current_angle(angular_velocity, current_angle, dt) + uncertainity_factor * random.random() 
        
        angular_vels.append(angular_velocity)
        print("Target angle: {}, Current angle: {}, Angular velocity: {}".format(target_angle, current_angle, angular_velocity))
        time.sleep(dt)
    import matplotlib.pyplot as plt
    plt.plot(angular_vels)
    plt.show()

if __name__ == "__main__":
    main()