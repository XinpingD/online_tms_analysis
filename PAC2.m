
% time-frequency analysis script for online-tms study using newtimef function
% experiment design: cue:200ms memory:100ms retention:1900ms  response:until made response  interval between stimuli:1000~1150
% cue:200ms memory:100ms retention1:850ms  retro-cue:200 retention2:850ms  response:until made response  interval between stimuli:1000~1150
% last modified: 20220311
% write by Deng
% ------------------------------------------------
%% initianization&preprocessing
clear
clc
%run('D:\MRItool\eeglab2021.1\eeglab.m')
run('D:\MRItool\eeglab2022.0\eeglab.m')
close all
ver='0222'; % data processing verstion (date)
pt='D:\Aonline_tms\';
mark= [116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946];     % mark for each condition  116 126 left same change 136 146 right same change
lchan=[1,4,6:9,15:18,24:27,33:36,42:45,51:53,59];
rchan=[3,5,11:14,20:23,29:32,38:41,47:50,55:57,61];
pre=0;
ICA=1;
filt=[ ];
epochtime=[-1.5,2];
[pt_ver, pt_work,pt_raw,pt_save,namepool]=Dversion(ver,pt);
%[result]=Dpre(namepool,pt_raw,pt_work,ICA,chan);

if pre==1
    [result]=Dpre(namepool,pt_raw,pt_work,pt_save,ICA,chan,filt,mark,epochtime);
end
clc
%% Time frequency calculation
pt_pac=[pt_work 'ICA'];  %pt_pac=[pt_work 'ICA'];
[fpath,pcapool]=Dfullpath(pt_pac,'*.set');
datapath=fpath;
%baseline=[176:325];% power baseline correction:600ms before cue(200ms) present
baseline=[-700 -100];
conmark= [116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946]';     % mark for each condition  116 126 left same change 136 146 right same change

tic
for n=1:size(datapath,1)
    
    fn=pcapool{n};
    % fn='1201_yangyongqiang';  % input filename to be processing  fn=file name 1101=tms test sub (tms:1,2,3=real,sham,only real)  (test:1,2=pre,post) (sub=01,21...)
    %'031_wangcong'
    %tms=str2double(fn(1)); % tms 1,real tms; 2,sham tms
    test=str2double(fn(2)); % test 1, pre-test, 2, post-test
    if fn(3)=='0'
        sub=str2double(fn(4));
    else
        sub=str2double(fn([3,4]));
    end
    
    
    EEG=pop_loadset(datapath{n});
    
    
    for con=1:5  %[2TR 2T2DR 2T 2T2D 4T ]
        
        type=[conmark(4*con-3,1) conmark(4*con-2,1) conmark(4*con-1,1) conmark(4*con,1)]';
        %         trial_type1=conmark(4*con-3,1); %tiral_type1 means correct response for left same condition
        %         trial_type2=conmark(4*con-2,1); %tiral_type2 means correct response for left change condition
        %         trial_type3=conmark(4*con-1,1);%tiral_type3 means correct response for right same condition
        %         trial_type4=conmark(4*con,1);%tiral_type4 means correct response for right change condition
        
        %a(con,1)=0;% counter for each trial
        for i=1:length(EEG.event)
            if EEG.event(1,i).type==type(1,1)||EEG.event(1,i).type==type(2,1)%(conmark(4*con-3,1)
                % a(con,1)=a(con,1)+1;
                ltrial(i,1)=EEG.event(1,i).epoch;%con1_left store the index of trial number of left target correct response of condition 1
            else
                ltrial(i,1)=0; %find(ltrial)
            end
            ltrial(ltrial==0)=[];
            if EEG.event(1,i).type==type(3,1)||EEG.event(1,i).type==type(4,1)%(conmark(4*con-3,1)
                % a(con,1)=a(con,1)+1;
                rtrial(i,1)=EEG.event(1,i).epoch;%con1_left store the index of trial number of left target correct response of condition 1
            else
                rtrial(i,1)=0;
            end
            rtrial(rtrial==0)=[];
        end
        
        if ~isempty(ltrial)
            for  cue=1:2
                if cue==1   %1 for left cue, 2 for right cue
                    trial=ltrial;
                else
                    trial=rtrial;
                end
                
                for channelnum=1:size(EEG.data,1)
                    for t=1:size(trial,1)
                        
                        %[ersp,~, ~, times, freqs,~,~,~]=newtimef( EEG.data(channelnum,:,trial),EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate , [0 0] ,  'baseline',baseline, 'scale', 'log', 'freqs', [2 40], 'timesout', 600, 'padratio', 4, 'winsize', 64, 'newfig', 'off', 'plotersp', 'off', 'plotitc', 'off', 'plotphasesign', 'off');
                        %tic
                        [ersp,~, ~, times, freqs,~,~,~]=newtimef( EEG.data(channelnum,:,trial(t)),EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate , [0 0] ,  'baseline',baseline, 'scale', 'log', 'freqs', [2 40], 'timesout', 300, 'padratio', 4, 'winsize', 64, 'newfig', 'off', 'plotersp', 'off', 'plotitc', 'off', 'plotphasesign', 'off');
                        %toc
                        gersp(t,:,:)=ersp;
                        %gtfdata(t,:,:)=tfdata;
                        % ttt=0.016589 *1000*63*100/3600/24
                    end
                    
                    %ERSP(con,cue,test,:,:,channelnum,sub)=ersp;
                    %TFdata(con,cue,test,:,:,channelnum,sub)=tfdata;
                    
                    ERSP(con,cue,test,:,:,channelnum,sub)=squeeze(mean(gersp,1));
                    %TFdata(con,cue,test,:,:,channelnum,sub)=squeeze(mean(gtfdata,1)); %size(TFdata)
                    clear gersp %gtfdata
                end
                clear trial
                
                
                
            end
            clear   ltrial rtrial
        end
    end
    
    
    clear sub test
end
eplapsetime=toc/3600;
disp(['eplapsetime for   ' num2str(n) ' is  ' num2str(eplapsetime)])
save([pt_work  'tf.mat'], 'ERSP', 'times','freqs','-v7.3')

% save([pt_work  'MI.mat'], 'gMI_theta_alpha','gMI_theta_beta','gMI_theta_lgamma','gMI_theta_hgamma','gMI_alpha_beta','gMI_alpha_lgamma','gMI_alpha_hgamma','-v7.3')
%% data vasulization
cd([pt_ver '\' 'result' ])
load('outsub.mat')
if ~exist('ERSP','var')
load([pt_work  'tf.mat'])
end
e=1; % whether exclude subjects
if e==1
    cd([pt_ver '\' 'result' ])
    mkdir(['x_' 'TF' ])
    cd(['x_' 'TF' ])
    subr=setdiff(isubr,sube);
    subs=setdiff(isubs,sube);
    edata=ERSP;% size(edata) (con,cue,test,frequency,times,channelnum,sub)
    edata(isnan(edata))=0;
    [edata,sub_outlier,~,~,~]=filloutliers(edata,7); %  sum_sub_outlier=sum(sub_outlier,5); sum_sub_outlier=sum(sum_sub_outlier,6);      squeeze(sum_sub_outlier(:,1,1,1,1,1,:))';  size(sum_sub_outlier)

   
else
    cd([pt_ver '\' 'result' ])
    mkdir(['TF' ])
    cd('TF')
    subr=isubr;
    subs=isubs;
    edata=ERSP;% size(edata) (con,cue,test,frequency,times,channelnum,sub)
    edata(isnan(edata))=0;
end


% topoplot  fre time pre test
fre=[4 10 16 24 40];   %9:16=9.7-16.7 Hz
twin=[82 128 156 220 257]; %-500 0 300 1000 1400ms     %220:266; %156:193; %128:174 0-500ms 220 266=1000-1500ms
for f=1:size(fre,2)
    for t=1:size(twin,2)
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot

    figure('Position',[0 0 1920 1080])
    
    p=0;
    
    for cue=1:2
        for tms=1:2
            p=p+1;
            subplot(2,2,p);
            if tms==1
                sub=subr;
                col='r';
            else
                sub=subs;
                col='b';
            end
            
            %tdata=squeeze(edata(con,cue,2,fre(f),twin(t),:,sub)-edata(con,cue,1,fre(f),twin(t),:,sub)); %(con,cue,test,frequency,times,channelnum,sub)  tdata(:,:,2,1,1) size(tdata)
            tdata=edata(con,cue,1,fre(f),twin(t),:,sub); %  size(tdata)
            tdata(isnan(tdata))=0;
            tdata=squeeze(mean(tdata,7));  % size(tdata)
            
            topoplot(tdata,loc,'style','fill','electrodes','labelpoint','chaninfo',chanfo,'numcontour' ,10,'conv' ,'on','maplimits',[-5 5]);
            % 'maplimits',[-4 4],
            colorbar
            title( [ 'fre' num2str(freqs(f)) ' time' num2str(times(t))  ' tms' num2str(tms) ' con' num2str(con) ' cue' num2str(cue)  ])
        end
       
    end
  
    print( '-djpeg',  '-r300', ['con' num2str(con) ' fre' num2str(f) ' time' num2str(t)   ])
    close all
 
end   %CDA plot
    end
end
cd([pt_ver '\' 'result' ])


%% plot section
% all channel lineplot
chan=[1:61];

for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    figure('Position',[0 0 1920 1080])
    p=0;
    for cue=1:2
        for tms=1:2
            p=p+1;
            subplot(2,2,p)
            if tms==1
                sub=subr;
                col='r';
            else
                sub=subs;
                col='b';
            end
            
          
            tdata(isnan(edata))=0;
            tdata=tdata(con,cue,:,fre,:,chan,sub); %(con,cue,test,frequency,times,channelnum,sub) size(data) tdata(:,:,2,1,1) size(data)
            tdata=mean(tdata,4);
            tdata=squeeze(mean(tdata,7));
            x1=squeeze(tdata(1,:,:));
            x2=squeeze(tdata(2,:,:));
            plot(times,x1,'r',times,x2,'c', 'LineWidth',3)
            %plot(times,x1,'r', 'LineWidth',3)
            ylim([-7,0])
            set(gca,'YDir','reverse');
            %legend('pre','pos')
            
            title( [   'con' num2str(con)  ' tms' num2str(tms) ' cue' num2str(cue)  ])
            clear sub
        end
    end
    
    print( '-djpeg',  '-r300', ['line_power_con' num2str(con) ])
    close all
end   %CDA plot
cd([pt_ver '\' 'result' ])



%%   useful function and codes

% [ersp,itc, powbase, times, freqs,erspboot,itcboot,tfdata]=newtimef( EEG.data(channelnum,:,trial(:,1)),EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate , [0 0] ,  'baseline',baseline, 'scale', 'log', 'freqs', [2 40], 'timesout', 200, 'padratio', 4, 'winsize', winsize, 'newfig', 'off', 'plotersp', 'off', 'plotitc', 'off', 'plotphasesign', 'off');
% topoplot
% filloutliers
% tftopo(tfdata,times,freqs);
% eeglab redraw



% plot line pac  for left-right channel
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    sube=outsub(:,2);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'TF' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('TF')
        subr=isubr;
        subs=isubs;
    end
    
    
    %for test=1:2
    figure('Position',[0 0 1920 1080])
    
    p=0;
    for cue=1:2
        
        
        
        for tms=1:2
            if tms==1
                sub=subr;
                %col='r';
            else
                sub=subs;
                %col='b';
            end
            p=p+1;
            tdata=squeeze(edata(con,cue,:,fre,:,lchan,sub)-edata(con,cue,:,fre,:,rchan,sub)); %(con,cue,test,frequency,times,channelnum,sub) size(tdata) tdata(:,:,2,1,1) size(tdata)
            tdata(isnan(tdata))=0;% size(tdata)
            tdata=mean(tdata,2);
            tdata=mean(tdata,4);
            tdata=squeeze(mean(tdata,5));
            
            subplot(2,2,p)
            hold on
            plot(times,tdata(1,:),'r',times,tdata(2,:),'c', 'LineWidth',3)
            plot([-1500 2000],[0,0],'b')
            %tftopo(tdata,times,freqs,'limits',[nan nan nan nan -2 2]);
            %colorbar
            %plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
            ylim([-1,1])
            %xticks([1 375 612 875]);
            %xticklabels(string([-1500 0 950 1996]));
            %set(gca,'YDir','reverse');
            %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
            grid on
            legend('pre','pos')
            title( [ 'test' num2str(test)  ' con' num2str(con) ' cue' num2str(cue)  ' tms' num2str(tms)  ])
            clear sub
            hold off
        end
    end
    
    % end
    print( '-djpeg',  '-r300', ['line l-r chan'  '_con' num2str(con) '_test' num2str(test)])
    close all
    %end
    
end   %CDA plot
cd([pt_ver '\' 'result' ])

% corr pac cue channel pre-pos
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    
    sube=outsub(:,con);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'TF' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('TF')
        subr=isubr;
        subs=isubs;
        
    end
    
    for c=1:2 % channeal: 1 left, 2 right
        if c==1
            ch=lchan;
        else
            ch=rchan;
        end
        
        figure('Position',[0 0 1920 1080])
        
        p=0;
        
        for cue=1:2
            p=p+1;
            
            %hold(h,'on')
            %hold on
            subplot(1,2,p);
            hold on
            for tms=1:2
                if tms==1
                    sub=subr;
                    col='r';
                else
                    sub=subs;
                    col='b';
                end
                
                tdata=squeeze(edata(con,cue,:,fre,twin,ch,sub)); %(con,cue,test,frequency,times,channelnum,sub) size(tdata) tdata(:,:,2,1,1) size(tdata)
                tdata(isnan(tdata))=0;
                tdata=mean(tdata,2);
                tdata=mean(tdata,3);
                tdata=squeeze(mean(tdata,4));
                
                
                
                x1=tdata(1,:); %size(x1)
                x1=double(x1);
                
                x2=tdata(2,:); %size(x2)
                x2=double(x2);
                
                
                
                plot([-10,2],[-10,2])
                scatter(x1,x2,'filled',col)
                scatter(mean(x1),mean(x2),140,'filled',col)
                text(x1+0.02,x2,string(sub))
                ylabel('pos')
                xlabel('pre')
                %axis square
                
                %set(gca,'YDir','reverse');
                %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
                grid on
                %legend('pre','pos')
                title( [ 'chan' num2str(c) 'con' num2str(con) ' cue' num2str(cue)  ])
            end
            hold off
            
        end
        
        
        print( '-djpeg',  '-r300', ['corr_chan' num2str(c) '_con' num2str(con) ])
        close all
    end
end   %CDA plot
cd([pt_ver '\' 'result' ])

% corr pac cue channel l-r pre-pos
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    
    sube=outsub(:,con);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'TF' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('TF')
        subr=isubr;
        subs=isubs;
        
    end
    
    %for c=1:2 % channeal: 1 left, 2 right
    %         if c==1
    %             ch=lchan;
    %         else
    %             ch=rchan;
    %         end
    
    figure('Position',[0 0 1920 1080])
    
    p=0;
    
    for cue=1:2
        p=p+1;
        
        %hold(h,'on')
        %hold on
        subplot(1,2,p);
        hold on
        for tms=1:2
            if tms==1
                sub=subr;
                col='r';
            else
                sub=subs;
                col='b';
            end
            
            tdata=squeeze(edata(con,cue,:,fre,twin,lchan,sub)-edata(con,cue,:,fre,twin,rchan,sub)); %(con,cue,test,frequency,times,channelnum,sub) size(tdata) tdata(:,:,2,1,1) size(tdata)
            tdata(isnan(tdata))=0;
            tdata=mean(tdata,2);
            tdata=mean(tdata,3);
            tdata=squeeze(mean(tdata,4));
            
            
            
            x1=tdata(1,:); %size(x1)
            x1=double(x1);
            
            x2=tdata(2,:); %size(x2)
            x2=double(x2);
            
            
            
            plot([-5,5],[0,0])
            plot([0,0],[-5,5])
            plot([-5,5],[-5,5])
            scatter(x1,x2,'filled',col)
            scatter(mean(x1),mean(x2),140,'filled',col)
            text(x1+0.02,x2,string(sub))
            ylabel('pos')
            xlabel('pre')
            %axis square
            
            %set(gca,'YDir','reverse');
            %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
            grid on
            %legend('pre','pos')
            title( [ 'con' num2str(con) ' cue' num2str(cue)  ])
        end
        hold off
        
    end
    
    
    print( '-djpeg',  '-r300', ['corr_l_r_chan' '_con' num2str(con) ])
    close all
    %end
end   %CDA plot
cd([pt_ver '\' 'result' ])

