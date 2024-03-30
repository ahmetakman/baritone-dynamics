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
