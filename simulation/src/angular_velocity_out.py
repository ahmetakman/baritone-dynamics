

def target_angle_to_angular_velocity(target_angle, current_angle, max_angular_velocity):
    # Calculate the difference between the target angle and the current angle
    angle_difference = target_angle - current_angle

    # If the difference is greater than 180 degrees, we should turn the other way
    if angle_difference > 180:
        angle_difference -= 360
    elif angle_difference < -180:
        angle_difference += 360

    # Calculate the angular velocity
    angular_velocity = angle_difference * max_angular_velocity / 180

    return angular_velocity