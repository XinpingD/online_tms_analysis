% CDA calculation for online-TMS
% last modified 20211207
run('D:\MRItool\eeglab2021.1\eeglab.m')
clear
clc
close all
% run('D:\MRItool\eeglab2021.1\eeglab.m')

ver='1115'; % data processing verstion (date)
pre=0;
ICA=1;
cal=1;
chan=[51:53 55:57];
filt=[0.1 30];
epochtime=[-1.5,2];
%chan=[51:53 55:57];
lchan=[51:53];
rchan=[55:57];
mark= [116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946];     % mark for each condition  116 126 left same change 136 146 right same change
filter='*.set' ;
pt='D:\Aonline_tms\';
[pt_ver,pt_work,pt_raw,pt_save,namepool]=Dversion(ver,pt);
namepool=namepool(3:end);
if pre==1
    [result]=Dpre(namepool,pt_raw,pt_work,pt_save,ICA,chan,filt,mark,epochtime);
end

[fpath,name]=Dfullpath(pt_save,filter);
%%
conmark=mark';
if cal==1
    for s=1:size(name,1)
        clear EEG tms test ltrial rtrial type ltrial rtrial erp_con_cl erp_ips_cl erp_con_cr erp_ips_cr cda_cl cda_cr cda_tr cda_tl cda
        sname=name{s,1};
        tms=str2double(sname(1)); %  tms 1,real tms; 2,sham tms
        test=str2double(sname(2)); %  test 1, pre-test, 2, post-test
        
        if sname(3)=='0'
            sub=str2double(sname(4));
        else
            sub=str2double(sname([3,4]));
        end
        
        EEG=pop_loadset(fpath{s,1});
        
        cd(pt_ver)
        cd('pic')
        mkdir(['sub' num2str(sub)])
        cd(['sub' num2str(sub)])
        
        for con=1:5  %[2TR 2T2DR 2T 2T2D 4T ]
            figure('Position',[0 0 1920 1080])
            clear type ltrial rtrial erp_con_cl erp_ips_cl erp_con_cr erp_ips_cr cda_cl cda_cr cda_tr cda_tl cda
            
            
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
                    ltrial(i,1)=0;
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
            
            
            
            for channel=1
                % channel type erp
                erp_con_cl=squeeze(mean(mean(EEG.data(lchan,:,rtrial),1),3));% size( erp_con_tl) size(EEG.data(rchan,:,ltrial))
                erp_ips_cl=squeeze(mean(mean(EEG.data(lchan,:,ltrial),1),3));
                erp_con_cr=squeeze(mean(mean(EEG.data(rchan,:,ltrial),1),3));
                erp_ips_cr=squeeze(mean(mean(EEG.data(rchan,:,rtrial),1),3));
                erp_con=0.5*(erp_con_cl+erp_con_cr);
                erp_ips=0.5*(erp_ips_cl+erp_ips_cr);
                
                cda_cl=erp_con_cl-erp_ips_cl;
                cda_cr=erp_con_cr-erp_ips_cr;
                cda_tl=erp_con_cr-erp_ips_cl;
                cda_tr=erp_con_cl-erp_ips_cr;
                cda=erp_con-erp_ips;
                
                ERP_con_cl(sub,tms,test,con,:)=erp_con_cl;      %(sub,tms,test,condition,time)
                ERP_ips_cl(sub,tms,test,con,:)=erp_ips_cl;
                ERP_con_cr(sub,tms,test,con,:)=erp_con_cr;
                ERP_ips_cr(sub,tms,test,con,:)=erp_ips_cr;
                ERP_con(sub,tms,test,con,:)=erp_con;
                ERP_ips(sub,tms,test,con,:)=erp_ips;
                
                CDA_cl(sub,tms,test,con,:)=cda_cl;
                CDA_cr(sub,tms,test,con,:)=cda_cr;
                CDA_tl(sub,tms,test,con,:)=cda_tl;
                CDA_tr(sub,tms,test,con,:)=cda_tr;
                CDA(sub,tms,test,con,:)=cda;
                
                % plot chan type erp
                x1=erp_con_cl;
                x1=smoothdata(x1,'gaussian',5);
                x2=erp_ips_cl;
                x2=smoothdata(x2,'gaussian',5);
                
                subplot(3,2,1)
                plot(1:875,x1,1:875,x2,'LineWidth',3)
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                ylim([-8,8])
                set(gca,'YDir','reverse');
                legend('对侧', '同侧')
                title( ['chan left erp' '  tms' num2str(tms) '  sub' num2str(sub) '  test' num2str(test)  '  con' num2str(con) ])
                grid on
                
                %close all
                
                % plot channel type erp
                x1=erp_con_cr;
                x1=smoothdata(x1,'gaussian',5);
                %x1=smoothdata(x1);
                x2=erp_ips_cr;
                x2=smoothdata(x2,'gaussian',5);
                %x2=smoothdata(x2);
                
                subplot(3,2,3)
                plot(1:875,x1,1:875,x2,'LineWidth',3 )
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                ylim([-8,8])
                set(gca,'YDir','reverse');
                legend('对侧', '同侧')
                title( ['chan right erp ' ' tms' num2str(tms) '  sub' num2str(sub) '  test' num2str(test) '  con' num2str(con)  ])
                grid on
                
                
                
                x1=erp_con;
                x1=smoothdata(x1,'gaussian',5);
                x2=erp_ips;
                x2=smoothdata(x2,'gaussian',5);
                
                subplot(3,2,5)
                plot(1:875,x1,1:875,x2,'LineWidth',3 )
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                ylim([-8,8])
                set(gca,'YDir','reverse');
                legend('对侧', '同侧')
                title( ['erp ' 'tms' num2str(tms) '  sub' num2str(sub) '  test' num2str(test) '  con' num2str(con)  ])
                grid on
                
                x1=cda_cl;
                x1=smoothdata(x1,'gaussian',5);
                x2=cda_cr;
                x2=smoothdata(x2,'gaussian',5);
                
                subplot(3,2,2)
                plot(1:875,x1,1:875,x2,'LineWidth',3 )
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                ylim([-5,5])
                set(gca,'YDir','reverse');
                legend('左半球', '右半球')
                title( ['chan cda ' 'tms' num2str(tms) '  sub' num2str(sub) '  test' num2str(test) '  con' num2str(con)  ])
                grid on
                
                x1=cda_tl;
                x1=smoothdata(x1,'gaussian',5);
                x2=cda_tr;
                x2=smoothdata(x2,'gaussian',5);
                
                subplot(3,2,4)
                plot(1:875,x1,1:875,x2,'LineWidth',3 )
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                ylim([-5,5])
                set(gca,'YDir','reverse');
                legend('左视野', '右视野')
                title( ['cue cda ' 'tms' num2str(tms) '  sub' num2str(sub) '  test' num2str(test) '  con' num2str(con)  ])
                grid on
                
                
                x1=cda;
                x1=smoothdata(x1,'gaussian',5);
                
                subplot(3,2,6)
                plot(1:875,x1,'LineWidth',3 )
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                ylim([-5,5])
                set(gca,'YDir','reverse');
                legend('全脑CDA')
                title( ['cda ' 'tms' num2str(tms) '  sub' num2str(sub) '  test' num2str(test) '  con' num2str(con)  ])
                grid on
                
                print( '-djpeg',  '-r300', [  num2str(sub) '_' num2str(tms) '_' num2str(test) '_'  num2str(con) ])
                close all
            end
            
            
        end
        cd(pt_ver)
        
        %clear ltrial rtrial erp_con_tl erp_ips_tl erp_con_tr erp_ips_tr erp_con_cl erp_ips_cl erp_con_cr erp_ips_cr sCDAc sCDAcr sCDAcl sCDAt sCDAtr sCDAtl
    end
    
    save([pt_work  'CDA.mat'], 'CDA', 'CDA_cl', 'CDA_cr', 'CDA_tl', 'CDA_tr', 'ERP_con_cl','ERP_ips_cl', 'ERP_con_cr','ERP_ips_cr','ERP_con','ERP_ips')
end

%imagesc
%%

clear
clc
ver='1115'; % data processing verstion (date)
pt='D:\Aonline_tms\';
[pt_ver,pt_work,pt_raw,pt_save,namepool]=Dversion(ver,pt);
load([pt_work  'predata.mat'])
load([pt_work  'CDA.mat']) %(sub,tms,test,condition,time)


cd([pt_ver '\' 'result' ])
load('outsub.mat')
d={'CDA' 'CDA_cl' 'CDA_cr' 'CDA_tl' 'CDA_tr' 'ERP_con'  'ERP_con_cl'  'ERP_con_cr' 'ERP_ips' 'ERP_ips_cl' 'ERP_ips_cr'};
%samplerate=1; ('2TR', '2T2DR', '2T', '2T2D', '4T')

e=0;

%line plot
for n=1:5%:11
    data=eval(d{n}); %size(data)
    mkdir(d{n})
    mkdir(['x_' d{n} ])
    cd(d{n})
    %data=datasample(data,floor(size(data,1)*samplerate),1,'Replace',false);%(sub,tms,test,condition,time) size(data)
    %squeeze(data(:,1,1,1,1))
    
    %data=data-data(:,:,:,3,:);  %squeeze(data17(:,1,1,3,1))
    %data=data(:,:,:,[1 3],:);
    
    % plot CDA
    for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
        sube=outsub(:,2);
        if e==1
            subr=setdiff(isubr,sube);
            subs=setdiff(isubs,sube);
            cd([pt_ver '\' 'result' ])
            cd(['x_' d{n} ])
        else
            cd([pt_ver '\' 'result' ])
            cd(d{n})
            subr=isubr;
            subs=isubs;
            
        end
        
        
        figure('Position',[0 0 1920 1080])
        p=0;
        for tms=1:2
            if tms==1
                isub=subr;
                
            else
            
                isub=subs;
            end
            p=p+1;
            %for test=1:2
                tdata=squeeze(data(:,tms,:,con,:)); %(sub,tms,test,condition,time) size(tdata) tdata(:,:,2,1,1)
                tdata(isnan(tdata))=0;
                x1=tdata(isub,1,:); %size(x1)
                x1=squeeze(mean(x1,1))';
                x1=smoothdata(x1,'gaussian',5);
                x2=tdata(isub,2,:); %size(x2)
                x2=squeeze(mean(x2,1))';
                x2=smoothdata(x2,'gaussian',5);
                subplot(2,1,p)
                plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
                %plot(1:875,x1,'LineWidth',3);
                ylim([-5,3])
                xticks([1 375 612 875]);
                xticklabels(string([-1500 0 950 1996]));
                set(gca,'YDir','reverse');
                legend('pre','pos')  %[2TR 2T2DR 2T 2T2D 4T ]
                grid on
                title( [ 'tms'  num2str(tms) ])
            %end
        end
        print( '-djpeg',  '-r300', [d{n}  ' con'  num2str(con) ])
        close all
    end   %CDA plot
    cd([pt_ver '\' 'result' ])
end

% scatter plot
for n=1%:5%:11
    data=eval(d{n});
    mkdir(d{n})
    mkdir(['x_' d{n} ])
    cd(d{n})
    %data=datasample(data,floor(size(data,1)*samplerate),1,'Replace',false);%(sub,tms,test,condition,time) size(data)
    %squeeze(data(:,1,1,1,1))
    
    %data=data-data(:,:,:,3,:);  %squeeze(data17(:,1,1,3,1))
    data(isnan(data))=0;
    eff=(data(:,:,:,4,:)-data(:,:,:,3,:))./(data(:,:,:,5,:)-data(:,:,:,3,:));
    bas=data(:,:,:,5,:)-data(:,:,:,3,:);
    twin=451:800;
    % plot CDA
    %for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
    sube=outsub(:,1);
    if e==1
        subr=setdiff(isubr,sube);
        subs=setdiff(isubs,sube);
        cd([pt_ver '\' 'result' ])
        cd(['x_' d{n}])
    end
    
    figure('Position',[0 0 1920 1080])
    for test=1:2
        hold on
        subplot(1,2,test)
        for tms=1:2
            if tms==1
                isub=subr;
                
                col='r';
            else
                
                isub=subs;
                col='b';
            end
            y=squeeze(eff(:,tms,test,:,:)); %(sub,time) size(tdata) tdata(:,:,2,1,1) size(eff)
            y=y(isub,twin); %size(x)
            y=mean(y,2);
            y=double(y);
            x=squeeze(bas(:,tms,test,:,:)); %(sub,time) size(tdata) tdata(:,:,2,1,1)
            x=x(isub,twin); %size(x1)
            x=mean(x,2);
            x=double(x);
            scatter(x,y,'filled',col)
            text(x,y,string(isub))
            ylabel('eff')
            xlabel('bas')
            title( [ 'tms'  num2str(tms) ' test' num2str(test) ])
            
            
        end
        hold off
    end
    %print( '-djpeg',  '-r300', [d{n} 'between_con' ])
    %close all
    %end   %CDA plot
    cd([pt_ver '\' 'result' ])
end