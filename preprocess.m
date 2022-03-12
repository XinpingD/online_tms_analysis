% CDA calculation for online-TMS
% last modified 20211104
clear
clc
% run('D:\MRItool\eeglab2021.1\eeglab.m')

ver='1103'; % data processing verstion (date)

ICA=1;
chan=[51:53 55:57];
filt=1;

%chan=[51:53 55:57];
lchan=[51:53];
rchan=[55:57];
mark= [116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946];     % mark for each condition  116 126 left same change 136 146 right same change
filter='*.set' ;
[pt_ver,pt_work,pt_raw,pt_save,namepool]=Dversion(ver);
[result]=Dpre(namepool,pt_raw,pt_work,pt_save,ICA,chan,filt,mark,epochtime);



%[fpath,name]=Dfullpath(pt_save,filter);