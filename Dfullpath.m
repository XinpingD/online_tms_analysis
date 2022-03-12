% return fullpath of certain files 
% path:path of father directory
% filter:filter for file selection for example '*.set'
% fpath: full path for chosen files
% name: file name for chosen files
% last modified 20210924
% usage: [fpath,name]=Dfullpath(path,filter)


function [fpath,name]=Dfullpath(path,filter)
flist=dir([path '\' filter]);
fpath=cell(size(flist,1),1);
name=cell(size(flist,1),1);
for i=1:size(flist,1)
fpath{i}=[path '\' flist(i).name];
name{i}= flist(i).name;
end



% path=pt_eeg;
% filter='*.set';
% flist=dir([path '\' filter]);
% fpath=cell(size(flist,1),1);
% for i=1:size(flist,1)
% fpath{i}=[path '\' flist(i).name];
% end
