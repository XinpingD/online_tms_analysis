% written by Xinping Deng 2021/08/13
% this is a function script of project online-TMS
% This function calculate amplitude and phase of each trials given certain frequency band

% three inputs
% EEG EEG data structure of EEGlab
% lband, low edge of the filering band
% hband, up edge of the filtering band

% two outputs
% amp, amplitude of trial time series
% pha, phase of trial time series

function [amp,pha]=Dhilbert(EEG,lband,hband)

        EEG=pop_eegfiltnew(EEG,lband,hband,[],0,0,0);
        for channelnum=1:size(EEG.data,1)
            for eponum=1:size(EEG.data,3)
                x= hilbert(EEG.data(channelnum,:,eponum));
                amp(channelnum,:,eponum)=sqrt(real(x).*real(x)+imag(x).*imag(x));
                pha(channelnum,:,eponum)=atan2(real(x),imag(x));
                clear x
            end
        end
   
end
