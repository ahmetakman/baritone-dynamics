
sample_frequency = 6e+7; % baseband sample rate
interval = [2.8 3.8] % in GHz
interval = interval * 1e9;

center_frequency = interval(1);



num_iter = int32(4*(interval(2)-interval(1))/(sample_frequency));
frequencies = linspace(interval(1),interval(2),num_iter);


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
rxPluto.Gain = 10;
for i = 1:60

[Av, FREQ] = search(rxPluto,frequencies,sample_frequency,num_iter);
if(Av>-40)
disp(Av);
disp(FREQ);
else
disp("Not yet detected")
end
pause(0.01)
disp("waited")
end


function [gain,detected_f] = search(rxPluto,frequencies,sample_frequency,num_iter)

peaks = [];
indices = [];
tic;

for i = 1:num_iter
center_frequency = frequencies(i);


rxPluto.CenterFrequency = center_frequency;

data = rxPluto();
%release(rxPluto);

 [p, f] = pspectrum(data, sample_frequency);
xdata = f+center_frequency;
ydata = pow2db(p);
%cent_x_label = num2str(center_frequency/1e+9);

[maxim index] = max(p);

peaks = [peaks maxim];
indices = [indices index];

% if (i==1)
% 
% figure;
% plt = plot(xdata,ydata);
% xlabel(["center frequency (GHz) = ",cent_x_label])
% ylabel("power (in db)")
% grid on;
% plt.XDataSource = 'xdata';
% plt.YDataSource = 'ydata';
% 
% else
%     refreshdata;
%     xlabel(["center frequency (GHz) = ",cent_x_label])
%     drawnow;
% end
% pause(1);
end
toc

% rxPluto = sdrrx('Pluto',...
%            'RadioID','usb:0',...
%            'CenterFrequency',center_frequency,...
%            'BasebandSampleRate',sample_frequency,...
%            'OutputDataType','double'); 
% 
% rxLogNoOverflow = dsp.SignalSink;
% rxLogDataValid = dsp.SignalSink;
% rxPluto.ShowAdvancedProperties = true;
% rxPluto.EnableBasebandDCCorrection = true;
% rxPluto.EnableRFDCCorrection = true;
% rxPluto.GainSource = "AGC Fast Attack";
% %rxPluto.GainSource = "Manual";
% %rxPluto.Gain = 10;
% for counter = 1:10
%     center_frequency = center_frequency + 1e6;
%     [data,datavalid,overflow] = rxPluto();
% 
%     %disp(data);
% 
%     [p, f] = pspectrum(data,sample_frequency);
% 
%     figure;
%     plot(f+center_frequency,pow2db(p));
%     xlabel(["center frequency = ",num2str(center_frequency)])
%     ylabel("power(in_db)")
%     pause(4) %in seconds
%     close;
% end
[M, I] = max(peaks);
f = frequencies(I);

gain = pow2db(M);

j = indices(I);

detected_f = (f-sample_frequency/2)+j;

end