
import time
import random

# A proportional controller that calculates the angular velocity needed to reach a target angle
def target_angle_to_angular_velocity(target_angle, current_angle, controller_gain = 1.0):
    # Calculate the difference between the target angle and the current angle
    angle_difference = target_angle - current_angle

    # Calculate the angular velocity needed to reach the target angle
    angular_velocity = angle_difference * controller_gain 

    return angular_velocity




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
    current_angles = [0]

    dt = 0.2
    uncertainity_factor = 0.0876
    for i in range(35):
        angular_velocity = target_angle_to_angular_velocity(target_angle, current_angle, controller_gain)
        current_angle = angular_velocity_to_current_angle(angular_velocity, current_angle, dt) + uncertainity_factor * random.random() 
        current_angles.append(current_angle)
        angular_vels.append(angular_velocity)
        print("Target angle: {}, Current angle: {}, Angular velocity: {}".format(target_angle, current_angle, angular_velocity))
        time.sleep(dt)
        if abs(current_angle - target_angle) < 0.001:
            break

    props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
    import matplotlib.pyplot as plt
    fig,ax =   plt.subplots(figsize=[8.3, 5.8])
    ax.text(0.75, 0.25, "uncertainity \n factor = 0.0876", transform=ax.transAxes, fontsize=14,
        verticalalignment='top', bbox=props)
    plt.title("Target angle convergence simulation output - P controller", fontsize=20)
    ax.plot(current_angles, linewidth=4)
    plt.xlabel("Time steps", fontsize=18)
    plt.ylabel("Instant heading angle", fontsize=18)
    plt.yticks(fontsize=14)
    plt.xticks(fontsize=14)
    plt.grid()
    plt.show()

if __name__ == "__main__":
    main()
    #dmösmdçamd