
clear all;
clc;
%%%%%%%%%%%%% ARGUMENT SETTINGS %%%%%%%%%%%%
plot_while_scanning = false; % if true the scans will be plotted one by one. Note that this would slow down the process considerably.

flag_narrow = false;

sample_frequency = 1e+7; % baseband sample rate range = (min--> 6.52e+4,  max--> 6.133e+7)
interval = [2.8 3.8] % in GHz

interval = interval * 1e9; % conversion to the Hz.
overlap_coefficient = 1; % in case an overlap needed.

center_frequency = interval(1); %for initialization

num_search = 75 ; % number of search attempts

%%%%%%% BASIC CALCULATIONS AND INITIALIZATIONS %%%%%%%

%set the center frequency set to be swept.
num_iter = int32(overlap_coefficient*(interval(2)-interval(1))/(sample_frequency));
frequencies = linspace(interval(1),interval(2),num_iter);

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


%%% HOPPING SEARCH %%%
for i = 1:num_search
if (flag_narrow == false)
    [Av, FREQ] = search(rxPluto,frequencies,sample_frequency,num_iter,plot_while_scanning);

else
    freq_scan = linspace(round(FREQ-(20*sample_frequency)),round(FREQ+(20*sample_frequency)),40);
    [Av, FREQ] = search(rxPluto,freq_scan,sample_frequency,length(freq_scan),plot_while_scanning);
end


if(Av>-65)
disp(Av);
disp(FREQ);
flag_narrow = true;
else
disp("Not yet detected or hopped")
flag_narrow = false;
end
pause(0.00001)
disp("waited")
end


%%%%%%%%%%%%%%%% FUNCTION DEFINITION %%%%%%%%%%%%%%%%%%
% Search function:
% It sweep through the frequencies specified and returns the detected frequency for that search with its gain.

function [gain,detected_f] = search(rxPluto,frequencies,sample_frequency,num_iter,plot_while_scanning)

peaks = zeros(num_iter,1);
indices = zeros(num_iter,1);
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

peaks(i) = maxim;
indices(i) = index;

end
toc

[M, I] = max(peaks);
f = frequencies(I);

gain = pow2db(M);

j = indices(I);

detected_f = (f-sample_frequency/2)+j;

end