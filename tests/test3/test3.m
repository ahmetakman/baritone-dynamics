clear all;
clc;
%%%%%%%%%%%%% ARGUMENT SETTINGS %%%%%%%%%%%%
plot_while_scanning = false; % if true the scans will be plotted one by one. Note that this would slow down the process considerably.

sample_frequency = 1e+7; % baseband sample rate range = (min--> 6.52e+4,  max--> 6.133e+7)
interval = [2.8 3.8] % in GHz

interval = interval * 1e9; % conversion to the Hz.
overlap_coefficient = 1; % in case an overlap needed.

center_frequency = interval(1); %for initialization

max_angle = 360; % in degrees.
angle_interval = 10; % e.g. change per measurement.


%%%%%%% BASIC CALCULATIONS AND INITIALIZATIONS %%%%%%%

%set the center frequency set to be swept.
num_iter = int32(overlap_coefficient*(interval(2)-interval(1))/(sample_frequency));
frequencies = linspace(interval(1),interval(2),num_iter);

% set the angle point group. e.g. = [0 10 20 30 40 ... 355]
num_angle = int32((max_angle-angle_interval)/angle_interval)+1;

angle_array = linspace(0,(max_angle-angle_interval),num_angle);

% initialization of the pluto rx object.
rxPluto = sdrrx('Pluto',...
           'RadioID','usb:0',...
           'CenterFrequency',center_frequency,...
           'BasebandSampleRate',sample_frequency,...
           'OutputDataType','double'); 

rxLogNoOverflow = dsp.SignalSink;
rxLogDataValid = dsp.SignalSink;
rxPluto.ShowAdvancedProperties = true;
rxPluto.EnableBasebandDCCorrection = true;
rxPluto.EnableRFDCCorrection = true;
%rxPluto.GainSource = "AGC Slow Attack";
rxPluto.GainSource = "Manual";
rxPluto.Gain = 10; % To be tuned further.

%%%%%%%%%5 ACTIVE RUN %%%%%%%%%%

[Av, detected_freq] = search(rxPluto,frequencies,sample_frequency,num_iter,plot_while_scanning);

if(Av>-65)
disp(Av);
disp(detected_freq);
else
disp("Not yet detected")
end
pause(1)

freq_scan = linspace(int32(detected_freq-20*sample_frequency),int32(detected_freq+20*sample_frequency),40);

gains_per_angle = [];

for j = 1:num_angle
disp(["Set the angle to",num2str(angle_array(j)),"and press a key to measure."])
pause;
[Av,FREQ] = search(rxPluto,freq_scan,sample_frequency,length(freq_scan),plot_while_scanning);

if(Av>-65)
    gains_per_angle = [gains_per_angle Av];
else
    angle_array(j) = 1;
end
end
angle_array = angle_array(angle_array>1);
%%%%%%%% Estimate the angle %%%%%%
mean_gain = mean(gains_per_angle);
filtered_logical = gains_per_angle > mean_gain;
estimated_angle = mean(nonzeros(filtered_logical .* angle_array));
%%%%%%%% Plot the profile %%%%%%%%
figure;
plot(angle_array, gains_per_angle);
xlabel("Angle in degrees");
ylabel("Gain per angle");
grid on;
title(["Estimated Angle = ",num2str(estimated_angle)]);
%%%%%%%%%%%%%%%% FUNCTION DEFINITION %%%%%%%%%%%%%%%%%%
% Search function:
% It sweep through the frequencies specified and returns the detected frequency for that search with its gain.

function [gain,detected_f] = search(rxPluto,frequencies,sample_frequency,num_iter,plot_while_scanning)

peaks = [];
indices = [];
tic;

for i = 1:num_iter
center_frequency = frequencies(i);


rxPluto.CenterFrequency = center_frequency;

data = rxPluto();
%release(rxPluto);

[p, f] = pspectrum(data, sample_frequency);


% If the plot option is utilized.
if (plot_while_scanning)
xdata = f+center_frequency;
ydata = pow2db(p);
cent_x_label = num2str(center_frequency/1e+9);

if (i==1)
figure;
plt = plot(xdata,ydata);
xlabel(["center frequency (GHz) = ",cent_x_label])
ylabel("power (in db)")
grid on;
plt.XDataSource = 'xdata';
plt.YDataSource = 'ydata';

else
    refreshdata;
    xlabel(["center frequency (GHz) = ",cent_x_label])
    drawnow;
end
pause(1);
end

[maxim, index] = max(p);

peaks = [peaks maxim];
indices = [indices index];

end
toc

[M, I] = max(peaks);
df = frequencies(I);

gain = pow2db(M);

j = indices(I);

detected_f = df;%(f-sample_frequency/2)+j;

end


function [gain,detected_f] = scan(rxPluto,freq_,sample_frequency)

    rxPluto.CenterFrequency = freq_;
    
    data = rxPluto();
    %release(rxPluto);    
    [p, f] = pspectrum(data, sample_frequency);
    
    [M, j] = max(p);
    
    gain = pow2db(M);
         
    detected_f = (freq_ - sample_frequency/2)+j;
    
end