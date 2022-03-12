%this function control data analysis version of online-TMS project, which will made new directory
%according custome analysis structure. raw data to be processeed later were
%stored in the task_temp directory and rest_temp directory seperatately.
%
%pt: parent working directory, such as 'D:\Aonline_tms\'
%ver: date of data analysis begins 
%
%pt_work:path of working directory
%
%pt_raw:path of the raw data directory
% usage:[pt_ver, pt_work,pt_raw,pt_save,namepool]=Dversion('1201','D:\Aonline_tms\')
%

%last modified 202111221

function [pt_ver, pt_work,pt_raw,pt_save,namepool]=Dversion(ver, pt)
%ver='0812'; % data processing verstion (date)

% '1101_yangyongqiang' '1201_yangyongqiang' '1102_renhaoli' '1202_renhaoli'...
% '1103_wangcong' '1203_wangcong' '2104_wudan' '2204_wudan'...
% '1105_liangguangyi' '1205_liangguangyi' '2106_zhaiandi'  '2206_zhaiandi'...
% '1107_zhanziyi' '1207_zhanziyi' '2108_harigui'  '2208_harigui'...
% '1109_zhaiyun' '1209_zhaiyun'  '2110_zhangxueying'   '2210_zhangxueying'...
% '1111_sunyidan' '1211_sunyidan' '2112_xiehanqianxi' '2212_xiehanqianxi'...
% '2113_yangzhen' '%2213_yangzhen'  '2114_baiyulong'  '2214_baiyulong'

% namepool={ '1101_yangyongqiang' '1201_yangyongqiang' '1102_renhaoli' '1202_renhaoli'...
%  '1103_wangcong' '1203_wangcong' '2104_wudan' '2204_wudan'...
%  '1105_liangguangyi' '1205_liangguangyi' '2106_zhaiandi'  '2206_zhaiandi'...
%  '1107_zhanziyi' '1207_zhanziyi' '2108_harigui'  '2208_harigui'...
%  '1109_zhaiyun' '1209_zhaiyun'  '2110_zhangxueying'   '2210_zhangxueying'...
%  '1111_sunyidan' '1211_sunyidan' '2112_xiehanqianxi' '2212_xiehanqianxi'...
%  '2113_yangzhen' '2213_yangzhen'  '2114_baiyulong'  '2214_baiyulong'...
%  '1115_wanghaolan'  '1215_wanghaolan' '1116_dongjinfang' '1216_dongjinfang'};
%   ICA=0;
% run('D:\MRItool\eeglab2019_1\eeglab.m')
% ver='0913'
pt_raw=[pt 'rawdata\temp\']; %path of raw data
if ~exist([pt, ver],'dir')
    mkdir(pt, ver)
   
end
cd([pt, ver])
if ~exist ([pt ver '\task'],'dir')
    mkdir('task')
    mkdir('pic')
    mkdir('result','test')
    mkdir('result','tms')
    mkdir('task','ICA')
    mkdir('task','erp')
    mkdir('task','erprej')
end

pt_work=[pt ver '\task\']; %path of working directory
pt_save=[pt_work  'erprej\' ];
pt_ver=[pt, ver];
%pt_eeg=[pt_work  'erprej\' ];
name=dir([pt_raw '*.cdt']);
if size(name)~=0
for i=1:length(name)
    namepool{i}=erase(name(i).name,'.cdt');
end
else
    namepool=[];
end