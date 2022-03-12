 % time-frequency analysis script for online-tms study
% last modified: 20220220
% ------------------------------------------------
clear
clc
%run('D:\MRItool\eeglab2021.1\eeglab.m')
run('D:\MRItool\eeglab2022.0\eeglab.m')
close all
ver='1115'; % data processing verstion (date)
pt='D:\Aonline_tms\';
mark= [116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946];     % mark for each condition  116 126 left same change 136 146 right same change
chan=[51:53 55:57];
lchan=[51:53];
rchan=[55:57];
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
pt_pac=[pt_work 'erprej'];  %pt_pac=[pt_work 'ICA'];
[fpath,pcapool]=Dfullpath(pt_pac,'*.set');
datapath=fpath;
baseline=176:325;% power baseline correction:600ms before cue(200ms) present

conmark= [116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946]';     % mark for each condition  116 126 left same change 136 146 right same change



for n=1:size(datapath,1)
    
    fn=pcaepool{n};
    % fn='1201_yangyongqiang';  % input filename to be processing  fn=file name 1101=tms test sub (tms:1,2,3=real,sham,only real)  (test:1,2=pre,post) (sub=01,21...)
    %'031_wangcong'
    %tms=str2double(fn(1)); % tms 1,real tms; 2,sham tms
    test=str2double(fn(2)); % test 1, pre-test, 2, post-test
    if fn(3)=='0'
        sub=str2double(fn(4));
    else
        sub=str2double(fn([3,4]));
    end
    
    tic
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
                for band=1:3   %1 for theta band(4-7), 2 for alpha band(8-12), 3 for beta band(13-30)
                    if band==1
                        lband=4; hband=7;
                    elseif band==2
                        lband=8; hband=12;
                    else
                        lband=13; hband=30;
                    end
                    gEEG=pop_eegfiltnew(EEG,lband,hband,[],0,0,0);
                    for c=1:size(chan,2)
                        clear a b
                        for i=1:size(trial,1)
                            x= hilbert(gEEG.data(chan(c),:,trial(i)));
                            a(i,:)=sqrt(real(x).*real(x)+imag(x).*imag(x));
                            %a(i,:)=a(i,:)-mean(a(i,baseline));
                            b(i,:)=atan2(real(x),imag(x));
                        end
                        amp(sub,test,con,cue,band,c,:)=mean(a,1); %size(amp)
                        pha(sub,test,con,cue,band,c,:)=mean(b,1);
                    end
                end
            end
            clear   ltrial rtrial
        end
    end
    eplapsetime=toc;
    disp(['eplapsetime for   ' num2str(n) ' is  ' num2str(eplapsetime)])
    clear sub test
end
save([pt_work  'pac.mat'], 'amp', 'pha', '-v7.3')

% save([pt_work  'MI.mat'], 'gMI_theta_alpha','gMI_theta_beta','gMI_theta_lgamma','gMI_theta_hgamma','gMI_alpha_beta','gMI_alpha_lgamma','gMI_alpha_hgamma','-v7.3')

%%
% plot
% size(amp)   squeeze(amp(1,1,:,1,2,:,1))   plot(squeeze(amp(:,1,:,1,2,1,1))')                   %sub,test,con,cue,band,c,:
cd([pt_ver '\' 'result' ])
load([pt_work  'pac.mat'])
load('outsub.mat')

e=0; % whether exclude subjects
twin=451:800;  %176:325; %451:800; 300ms-1700ms   cue:200ms memory:100ms retention:1900ms  response:until made response  interval between stimuli:1000~1150

data=amp;
mkdir('PCA')
mkdir(['x_' 'PCA' ])
cd('PCA')


% plot pac for left and right channel separately
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    sube=outsub(:,1);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'PCA' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('PCA')
        subr=isubr;
        subs=isubs;
    end
    
    for c=1:2 % channeal: 1 left, 2 right
        if c==1
            ch=1:3;
        else
            ch=4:6;
        end
        
        for band=2%1:3
            
            figure('Position',[0 0 1920 1080])
            
            p=0;
            for cue=1:2
                
                %for band=1:3
                
                
                for tms=1:2
                    if tms==1
                        sub=subr;
                        col='r';
                    else
                        sub=subs;
                        col='b';
                    end
                    p=p+1;
                    tdata=squeeze(data(:,:,con,cue,band,ch,:)); %(sub,test,con,cue,band,c,:) size(tdata) tdata(:,:,2,1,1) size(data)
                    tdata(isnan(tdata))=0;
                    x1=tdata(sub,1,:,:); %size(x1)
                    x1=mean(x1,3);
                    x1=squeeze(mean(x1,1));
                    x1=smoothdata(x1,'gaussian',5);
                    x2=tdata(sub,2,:,:); %size(x1)
                    x2=mean(x2,3);
                    x2=squeeze(mean(x2,1));
                    x2=smoothdata(x2,'gaussian',5);
                    subplot(2,2,p)
                    plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
                    ylim([1,8])
                    xticks([1 375 612 875]);
                    xticklabels(string([-1500 0 950 1996]));
                    %set(gca,'YDir','reverse');
                    %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
                    grid on
                    legend('pre','pos')
                    title( ['con' num2str(con) ' cue' num2str(cue) ' chan' num2str(c) ' tms' num2str(tms)  ' band' num2str(band)])
                    clear sub
                end
            end
        
        % end
        print( '-djpeg',  '-r300', ['band' num2str(band) '_chan' num2str(c) '_con' num2str(con) ])
        close all
        end
    end
end   %CDA plot
cd([pt_ver '\' 'result' ])


% plot  left-right cue pac for left right channel separately
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    sube=outsub(:,1);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'PCA' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('PCA')
        subr=isubr;
        subs=isubs;
    end
    
    
    
    figure('Position',[0 0 1920 1080])
    
    p=0;
    
    for c=1:2 % channeal: 1 left, 2 right
        if c==1
            ch=1:3;
        else
            ch=4:6;
        end
        
        
        for band=2%1:3
            for tms=1:2
                if tms==1
                    sub=subr;
                    col='r';
                else
                    sub=subs;
                    col='b';
                end
                p=p+1;
                %tdata=squeeze(data(:,:,con,1,band,ch,:)-data(:,:,con,2,band,ch,:)); %(sub,test,con,cue,band,c,:) size(tdata) tdata(:,:,2,1,1) size(data)
                tdata=squeeze((data(:,:,con,1,band,ch,:)-data(:,:,con,2,band,ch,:))./(data(:,:,con,1,band,ch,:)+data(:,:,con,2,band,ch,:)));
                tdata(isnan(tdata))=0;
                x1=tdata(sub,1,:,:); %size(x1)
                x1=mean(x1,3);
                x1=squeeze(mean(x1,1));
                x1=smoothdata(x1,'gaussian',5);
                x2=tdata(sub,2,:,:); %size(x1)
                x2=mean(x2,3);
                x2=squeeze(mean(x2,1));
                x2=smoothdata(x2,'gaussian',5);
                subplot(2,2,p)
                plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
                %ylim([-1,1.5])
                ylim([-0.1,0.1])
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                %set(gca,'YDir','reverse');
                %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
                grid on
                legend('pre','pos')
                title( ['con' num2str(con)  ' chan' num2str(c) ' tms' num2str(tms)  ' band' num2str(band)])
            end
        end
        
    end
    print( '-djpeg',  '-r300', ['cue l_r band' num2str(band)  '_con' num2str(con) ])
    close all
    
end   %CDA plot
cd([pt_ver '\' 'result' ])

% plot  left-right channel pac for left right cue separately
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    sube=outsub(:,1);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'PCA' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('PCA')
        subr=isubr;
        subs=isubs;
    end
    
    
    
    figure('Position',[0 0 1920 1080])
    
    p=0;
    
    for cue=1:2 % channeal: 1 left, 2 right
        
        for band=2%1:3
            for tms=1:2
                if tms==1
                    sub=subr;
                    col='r';
                else
                    sub=subs;
                    col='b';
                end
                p=p+1;
                %tdata=squeeze(data(:,:,con,cue,band,[1 2 3],:)-data(:,:,con,cue,band,[4 5 6],:)); %(sub,test,con,cue,band,c,:) size(tdata) tdata(:,:,2,1,1) size(data)
                tdata=squeeze((data(:,:,con,cue,band,[1 2 3],:)-data(:,:,con,cue,band,[4 5 6],:))./(data(:,:,con,cue,band,[1 2 3],:)+data(:,:,con,cue,band,[4 5 6],:)));
                tdata(isnan(tdata))=0;
                x1=tdata(sub,1,:,:); %size(x1)
                x1=mean(x1,3);
                x1=squeeze(mean(x1,1));
                x1=smoothdata(x1,'gaussian',5);
                x2=tdata(sub,2,:,:); %size(x1)
                x2=mean(x2,3);
                x2=squeeze(mean(x2,1));
                x2=smoothdata(x2,'gaussian',5);
                subplot(2,2,p)
                plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
                %ylim([-2,0.5])
                ylim([-0.1,0.1])
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                %set(gca,'YDir','reverse');
                %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
                grid on
                legend('pre','pos')
                title( ['con' num2str(con)  ' cue' num2str(cue) ' tms' num2str(tms)  ' band' num2str(band)])
            end
        end
        
    end
    print( '-djpeg',  '-r300', ['chan l_r band' num2str(band)  '_con' num2str(con) ])
    close all
    
end   %CDA plot
cd([pt_ver '\' 'result' ])




% corr pac pre-pos
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    
    sube=outsub(:,con);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'PCA' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('PCA')
        subr=isubr;
        subs=isubs;
        
    end
    
    
    figure('Position',[0 0 1920 1080])
    
    p=0;
    
    for cue=1:2
        p=p+1;
        for band=2%1:3
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
                
                tdata=squeeze(data(:,:,con,cue,band,:,:)); %(sub,test,con,cue,band,c,:) size(tdata) tdata(:,:,2,1,1)
                tdata(isnan(tdata))=0;
                x1=tdata(sub,1,:,:); %size(x1)
                x1=mean(x1,3);
                x1=x1(:,:,:,twin);
                x1=squeeze(mean(x1,4));
                x1=double(x1);
                
                x2=tdata(sub,2,:,:); %size(x1)
                x2=mean(x2,3);
                x2=x2(:,:,:,twin);
                x2=squeeze(mean(x2,4));
                x2=double(x2);
                
                
                
                plot([0,10],[0,10])
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
                title( ['con' num2str(con) ' cue' num2str(cue)   ' band' num2str(band)])
            end
            hold off
        end
    end
    
    
    print( '-djpeg',  '-r300', ['corr_band' num2str(band) '_con' num2str(con) ])
    close all
end   %CDA plot
cd([pt_ver '\' 'result' ])

%%
% plot pac
for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    sube=outsub(:,con);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' 'PCA' ])
    else
        cd([pt_ver '\' 'result' ])
        cd('PCA')
        subr=isubr;
        subs=isubs;
    end
    
    figure('Position',[0 0 1920 1080])
    
    p=0;
    for cue=1:2
        for band=2%1:3
            for tms=1:2
                if tms==1
                    sub=subr;
                    col='r';
                else
                    sub=subs;
                    col='b';
                end
                p=p+1;
                tdata=squeeze(data(:,:,con,cue,band,:,:)); %(sub,test,con,cue,band,c,:) size(tdata) tdata(:,:,2,1,1)
                tdata(isnan(tdata))=0;
                x1=tdata(sub,1,:,:); %size(x1)
                x1=mean(x1,3);
                x1=squeeze(mean(x1,1));
                x1=smoothdata(x1,'gaussian',5);
                x2=tdata(sub,2,:,:); %size(x1)
                x2=mean(x2,3);
                x2=squeeze(mean(x2,1));
                x2=smoothdata(x2,'gaussian',5);
                subplot(2,2,p)
                plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
                ylim([-6,2])
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                %set(gca,'YDir','reverse');
                %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
                grid on
                legend('pre','pos')
                title( ['con' num2str(con) ' cue' num2str(cue) ' tms' num2str(tms)  ' band' num2str(band)])
            end
        end
    end
    
    print( '-djpeg',  '-r300', ['band' num2str(band) '_con' num2str(con) ])
    close all
end   %CDA plot
cd([pt_ver '\' 'result' ])

[ersp,itc, powbase, times, freqs,erspboot,itcboot,tfdata]=newtimef( EEG.data(channelnum,:,trial(:,1)),EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate , [0 0] ,  'baseline',baseline, 'scale', 'log', 'freqs', [2 40], 'timesout', 200, 'padratio', 4, 'winsize', winsize, 'newfig', 'off', 'plotersp', 'off', 'plotitc', 'off', 'plotphasesign', 'off');
topoplot

eeglab redraw
