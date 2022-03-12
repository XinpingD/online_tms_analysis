% calculate stata index for online-tms study

% last modified 20220103

clear
clc
ver='1115'; % data processing verstion (date)
pt='D:\Aonline_tms\';
[pt_ver,pt_work,pt_raw,pt_save,namepool]=Dversion(ver,pt);
load([pt_work  'predata.mat'])
load([pt_work  'CDA.mat']) %(sub,tms,test,condition,time)


%% plot
cd([pt_ver '\' 'result' ])
load('outsub.mat')
d={'CDA' 'CDA_cl' 'CDA_cr' 'CDA_tl' 'CDA_tr' 'ERP_con'  'ERP_con_cl'  'ERP_con_cr' 'ERP_ips' 'ERP_ips_cl' 'ERP_ips_cr'};
%samplerate=1; ('2TR', '2T2DR', '2T', '2T2D', '4T')

e=1;
%identify ID number for real and sham TMS condition
data=eval(d{1});
indr=squeeze(data(:,1,1,1,1)~=0);
isubr=find(indr);
inds=squeeze(data(:,2,1,1,1)~=0);
isubs=find(inds);

for n=1:11
    data=eval(d{n});
    mkdir(d{n})
    mkdir(['x_' d{n} ])
    cd(d{n})
    %data=datasample(data,floor(size(data,1)*samplerate),1,'Replace',false);%(sub,tms,test,condition,time) size(data)
    %squeeze(data(:,1,1,1,1))
    
        
    
    % plot CDA
    for con=1:5 %[2TR 2T2DR 2T 2T2D 4T ] CDA plot
         sube=outsub(:,con);
         if e==1
            subr=setdiff(isubr,sube);
            subs=setdiff(isubs,sube);
            cd([pt_ver '\' 'result' ])
            cd(['x_' d{n}])
         end
        
        figure('Position',[0 0 1920 1080])
            
         for tms=1:2
            if tms==1
                isub=subr;
                p=1;
            else
                p=2;
                isub=subs;
            end
            
            tdata=squeeze(data(:,tms,:,:,:)); %(sub,tms,test,condition,time) size(tdata) tdata(:,:,2,1,1)
            tdata(isnan(tdata))=0;
            x1=tdata(isub,:,:,:);%(sub,test,condition,time) size(x1)
            x1=squeeze(mean(x1(:,1,con,:),1))';
            x1=smoothdata(x1,'gaussian',5);
            x2=tdata(isub,:,:,:);
            x2=squeeze(mean(x2(:,2,con,:),1))'; %size(x2)
            x2=smoothdata(x2,'gaussian',5);
            subplot(2,2,tms)
            plot(1:875,x1,'g',1:875,x2,'b','LineWidth',3);
            ylim([-5,2])
            xticks([1 375 612 875]);
            xticklabels(string([-1500 0 950 1996]));
            set(gca,'YDir','reverse');
            grid on
            legend('pre','pos')
            title( ['con' num2str(con) '  tms' num2str(tms) ])
        end
        for test=1:2
            tdata=squeeze(data(:,:,test,:,:)); %(sub,tms,condition,time) size(tdata) tdata(:,:,2,1,1)
            tdata(isnan(tdata))=0;
            x1=tdata(subr,:,:,:); %size(x1)
            x1=squeeze(mean(x1(:,1,con,:),1))';
            x1=smoothdata(x1,'gaussian',5);
            x2=tdata(subs,:,:,:); %size(x2)
            x2=squeeze(x2(:,2,con,:));
            x2=mean(x2);%(sub,test,condition,channel,time)
            x2=smoothdata(x2,'gaussian',5);
            subplot(2,2,test+2)
            plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
            ylim([-5,2])
            xticks([1 375 612 875]);
            xticklabels(string([-1500 0 950 1996]));
            set(gca,'YDir','reverse');
            %legend('2TR', '2T2DR', '2T', '2T2D', '4T')
            grid on
            legend('real','sham')
            title( ['con' num2str(con) ' test' num2str(test) ])
        end
        print( '-djpeg',  '-r300', [d{n} '_con' num2str(con) ])
        close all
    end   %CDA plot
    cd([pt_ver '\' 'result' ])
end
%% plot between conditions
cd([pt_ver '\' 'result' ])
%load('outsub.mat')
d={'CDA' 'CDA_cl' 'CDA_cr' 'CDA_tl' 'CDA_tr' 'ERP_con'  'ERP_con_cl'  'ERP_con_cr' 'ERP_ips' 'ERP_ips_cl' 'ERP_ips_cr'};
%samplerate=1; ('2TR', '2T2DR', '2T', '2T2D', '4T')

e=1;
%identify ID number for real and sham TMS condition
data=eval(d{1});
indr=squeeze(data(:,1,1,1,1)~=0);
isubr=find(indr);
inds=squeeze(data(:,2,1,1,1)~=0);
isubs=find(inds);

%line plot
for n=1%:5%:11
    data=eval(d{n});
    mkdir(d{n})
    mkdir(['x_' d{n} ])
    cd(d{n})
    %data=datasample(data,floor(size(data,1)*samplerate),1,'Replace',false);%(sub,tms,test,condition,time) size(data)
    %squeeze(data(:,1,1,1,1))
    
    %data=data-data(:,:,:,3,:);  %squeeze(data17(:,1,1,3,1))
     data=data(:,:,:,[1 3],:);  
    
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
            
         for tms=1:2
            if tms==1
                isub=subr;
                p=0;
            else
                p=2;
                isub=subs;
            end
        
        for test=1:2
            tdata=squeeze(data(:,tms,test,:,:)); %(sub,tms,condition,time) size(tdata) tdata(:,:,2,1,1)
            tdata(isnan(tdata))=0;
            x1=tdata(isub,:,:); %size(x1)
            x1=squeeze(mean(x1,1))';
            x1=smoothdata(x1,'gaussian',5);
            subplot(2,2,p+test)
            %plot(1:875,x1,'r',1:875,x2,'c','LineWidth',3);
            plot(1:875,x1,'LineWidth',3);
            ylim([-3,3])
            xticks([1 375 612 875]);
            xticklabels(string([-1500 0 950 1996]));
            set(gca,'YDir','reverse');
            %legend('2TR', '2T2DR', '2T', '2T2D', '4T')  %[2TR 2T2DR 2T 2T2D 4T ]
            grid on
            title( [ 'tms'  num2str(tms) ' test' num2str(test) ])
        end
        end
        print( '-djpeg',  '-r300', [d{n} 'between_con' ])
        %close all
    %end   %CDA plot
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

%% behavior stata===============================
cd([pt_ver '\' 'result' ])
mkdir('Beh')
cd('Beh')
% load('predata.mat')
acc=result.acc;  % size(acc)    % sub tms test con*type       [2TR 2T2DR 2T 2T2D 4T ]  1:left same 2:left change 3:right same 4:right change
% ACC plot
for con=1:5
    figure('Position',[0 0 1920 1080])
    for tms=1:2
        if tms==1
            isub=isubr;
            p=1;
        else
            p=2;
            isub=isubs;
        end
        acc1=squeeze(acc(isub,tms,:,[4*con-3 4*con-2])); % left cue trial
        acc1=sum(acc1,3); % sub test
        acc2=squeeze(acc(isub,tms,:,[4*con-1 4*con])); % right cue trial
        acc2=sum(acc2,3); % sub test
        
        acc12=(acc1+acc2)/2;
        
        subplot(3,2,p)
        bar(acc1)
        grid on
        ylim([0,100])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('前测', '后测')
        title( ['acc' ' con' num2str(con) ' tms' num2str(tms) ' cue left'] )
        
        subplot(3,2,p+2)
        bar(acc2)
        grid on
        ylim([0,100])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('前测', '后测')
        title( ['acc' ' con' num2str(con) ' tms' num2str(tms) ' cue right'] )
        
        
        subplot(3,2,p+4)
        bar(acc12)
        grid on
        ylim([0,100])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('前测', '后测')
        title( ['acc' ' con' num2str(con) ' tms' num2str(tms) ' all'] )
        
    end
    
    print( '-djpeg',  '-r300', ['dacc_con' num2str(con) ])
    close all
end
cd([pt_ver '\' 'result' ])

% ACC change plot
cd([pt_ver '\' 'result' ])
cd('Beh')
for con=1:5
    figure('Position',[0 0 1920 1080])
    for tms=1:2
        if tms==1
            isub=isubr;
            p=1;
        else
            p=2;
            isub=isubs;
        end
        acc1=squeeze(acc(isub,tms,:,[4*con-3 4*con-2])); % left cue trial
        acc1=sum(acc1,3); % sub test
        acc1=acc1(:,2)-acc1(:,1);
        acc2=squeeze(acc(isub,tms,:,[4*con-1 4*con])); % right cue trial
        acc2=sum(acc2,3);% sub test
        acc2=acc2(:,2)-acc2(:,1);
        
        acc12=(acc1+acc2)/2;
        
        subplot(3,2,p)
        bar(acc1)
        grid on
        ylim([-50,50])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('pos-pre')
        title( ['acc change' ' con' num2str(con) ' tms' num2str(tms) ' cue left'] )
        
        subplot(3,2,p+2)
        bar(acc2)
        grid on
        ylim([-50,50])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('pos-pre')
        title( ['acc change' ' con' num2str(con) ' tms' num2str(tms) ' cue right'] )
        
        
        subplot(3,2,p+4)
        bar(acc12)
        grid on
        ylim([-50,50])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('pos-pre')
        title( ['acc change' ' con' num2str(con) ' tms' num2str(tms) ' all'] )
        
    end
    
    print( '-djpeg',  '-r300', ['cdacc_con' num2str(con) ])
    close all
end
cd([pt_ver '\' 'result' ])
%% number of rejected trials ===============================
cd([pt_ver '\' 'result' ])
mkdir('Beh')
cd('Beh')
% load('predata.mat')
ntri=result.trialnum;      %trialnum(sub,tms,test,con,cue,trialnum) trialnum(sub,tms,test,con,cue,trialnum)
for con=1:5
    figure('Position',[0 0 1920 1080])
    for tms=1:2
        if tms==1
            isub=isubr;
            p=1;
        else
            p=2;
            isub=isubs;
        end
        ntri1=squeeze(ntri(isub,tms,:,con,1)); % left cue trial
        ntri2=squeeze(ntri(isub,tms,:,con,2)); % right cue trial
        ntri12=ntri1+ntri2;
        subplot(3,2,p)
        bar(ntri1)
        grid on
        ylim([0,100])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('前测', '后测')
        title( ['con' num2str(con) ' tms' num2str(tms) ' cue left'] )
        
        subplot(3,2,p+2)
        bar(ntri2)
        grid on
        ylim([0,100])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('前测', '后测')
        title( ['con' num2str(con) ' tms' num2str(tms) ' cue right'] )
        
        
        
        subplot(3,2,p+4)
        bar(ntri12)
        grid on
        ylim([0,200])
        xticks(1:size(isub));
        xticklabels(string(isub));
        legend('前测', '后测')
        title( ['con' num2str(con) ' tms' num2str(tms) ' all'] )
        
    end
    
    print( '-djpeg',  '-r300', ['ntril_con' num2str(con) ])
    close all
end
cd([pt_ver '\' 'result' ])
%% mean CDA value
cd([pt_ver '\' 'result' ])
twin=451:800; %450-800 4ms/tpoints 350*4 300ms-1700ms   ('2TR', '2T2DR', '2T', '2T2D', '4T')
d={'CDA' 'CDA_cl' 'CDA_cr' 'CDA_tl' 'CDA_tr' 'ERP_con'  'ERP_con_cl'  'ERP_con_cr' 'ERP_ips' 'ERP_ips_cl' 'ERP_ips_cr'};

% bar plot with mean CDA value
cd([pt_ver '\' 'result' ])
for n=1
    cd(d{n})
    
    for con=1:5
        figure('Position',[0 0 1920 1080])
        
        
        
        for tms=1:2
            if tms==1
                isub=isubr;
                p=1;
            else
                p=2;
                isub=isubs;
            end
            c=squeeze(mvalue(n,:,:,con)); %size(exsub)
            c=reshape(c,1,4);
            subplot(2,2,p)
            bar([c{p} c{p+2}])
            ylim([-5,3])
            xticks(1:size(isub));
            xticklabels(string(isub));
            legend('前测', '后测')
            title( ['con' num2str(con) ' tms' num2str(tms)] )
            subplot(2,2,p+2)
            bar(c{p+2}-c{p})
            ylim([-5,3])
            xticks(1:size(isub));
            xticklabels(string(isub));
            legend('后测-前测')
            title( ['con' num2str(con) '  pos-pre'])
        end
        print( '-djpeg',  '-r300', ['m_' d{n} '_con' num2str(con) ])
        close all
    end
end

% identify outlier according to mean CDA value
for n=1:11
    data=eval(d{n});
    
    %data=datasample(data,floor(size(data,1)*samplerate),1,'Replace',false);%(sub,tms,test,condition,time) size(data)
    %squeeze(data(:,1,1,1,1))
    %outer=zeros(size(data,1),2,2,5);
    for con=1:5 %('2TR', '2T2DR', '2T', '2T2D', '4T')
        for tms=1:2
            for test=1:2
                clear isub
                y=data;%size(y)
                ind=squeeze(y(:,tms,test,con,1)~=0);
                isub=find(ind);
                y=y(ind,tms,test,con,twin);
                y=mean(y,5);     %size(y)
                [TF,L,U,C]=isoutlier(y,1);
                ID=TF.*isub;
                ID=ID(ID~=0);
                %
                %exsub(n,tms,test,con)={TF};    %squeeze(outer(1,2,:))
                exsub{n,tms,test,con}=[find(TF), ID]; % arrange number and ID number [find(TF) ID]
                mvalue{n,tms,test,con}=y;%n(indicator type:CDA,rCDA...),tms,test,con,mean
            end
        end
    end
end
save('exsub.mat','exsub','mvalue','isubr','isubs')



%% ACC-CDA correlation plot 2
% plot average CDA after exclude certain subjects
cd([pt_ver '\' 'result' ])
load('outsub.mat')

d={'CDA' 'CDA_cl' 'CDA_cr' 'CDA_tl' 'CDA_tr' 'ERP_con'  'ERP_con_cl'  'ERP_con_cr' 'ERP_ips' 'ERP_ips_cl' 'ERP_ips_cr'};
twin=451:800; %450-800 4ms/tpoints 350*4 300ms-1700ms   ('2TR', '2T2DR', '2T', '2T2D', '4T')

% exclude subjects by mean value outliers ================================
cd([pt_ver '\' 'result' ])

e=0; %whether exclude subjects
for n=1:11
    cd([pt_ver '\' 'result' ])
    data=eval(d{n}); %size(data)
    acc=result.acc; %size(acc)
    mkdir(['x_' d{n} ])
    cd([ d{n} ])
    %data=datasample(data,floor(size(data,1)*samplerate),1,'Replace',false);%(sub,tms,test,condition,time) size(data)
    %squeeze(data(:,1,1,1,1))
    
    
    
    
    
    
    for con=1:5
        edata=data;
        eacc=acc; %sub,tms,test,condition*type
        sube=outsub(:,con);
        subr=isubr;
        subs=isubs;
        
        
        
        if e==1
            subr=setdiff(isubr,sube);
            subs=setdiff(isubs,sube);
            cd([pt_ver '\' 'result' ])
            cd(['x_' d{n}])
        end
        
        
        % acc
        acc1=squeeze(eacc(:,:,:,[4*con-3 4*con-2])); % left cue trial size(acc1) sub tms test diff
        acc1=sum(acc1,4); % sub tms test
        acc2=squeeze(eacc(:,:,:,[4*con-1 4*con])); % right cue trial size(acc2)
        acc2=sum(acc2,4); % sub tms test
        acc12=(acc1+acc2)/2;  %   size(acc12)  sub tms test
        
        %acc change
        cacc12=acc12(:,:,2)-acc12(:,:,1);
        
        % CDA
        edata=edata(:,:,:,:,twin);
        edata=mean(edata,5); %(sub,tms,test,condition)  size(edata)
        cda=squeeze(edata(:,:,:,con));         %   sub,tms,test
        
        % change CDA
        ccda=cda(:,:,2)-cda(:,:,1); %   sub,tms
        
      
        
        
        figure('Position',[0 0 1920 1080])
        for test =1:2
            subplot(1,3,test)
            for tms=1:2
                hold on
                if tms==1
                    isub=subr;
                    p=1;
                    col='r';
                else
                    p=2;
                    isub=subs;
                    col='g';
                end
                
                x=acc12(isub,tms,test);
                y=cda(isub,tms,test);
                y=double(y);
                scatter(x,y,'filled',col)
                text(x+0.1,y+0.1,string(isub))
                ylim([-8,8])
                xlim([30,100])
                mdl=fitlm(x,y);
                rs=mdl.Rsquared.Adjusted;
                be=mdl.Coefficients{2,1};
                int=mdl.Coefficients{1,1};
                pvalue=mdl.Coefficients{2,4};
                iy=mdl.Fitted;
                plot(x,iy,col)
                plot([30 100],[0,0],'--')
                plot([50 50],[-8,8],'--');
                %line(0,0)
                %set(gca,'XAxisLocation','origin')
                %set(gca,'YAxisLocation','right')
                %text(x(5)+0.2,iy(5)+0.2,['Rsquared=' num2str(rs) ' p=' num2str(pvalue)])
                ylabel('CDA')
                xlabel('acc')
                
                axis square
                %legend('data',['y= ' num2str(int) '+ ' num2str(be) '*x'])
                title( ['test' num2str(test)  ' acc-CDA con' num2str(con) ])
                hold off
            end
        end
        
        subplot(1,3,3)
        for tms=1:2
            hold on
            if tms==1
                isub=subr;
                p=1;
                col='r';
            else
                p=2;
                isub=subs;
                col='g';
            end
       
            % correlation calculate
        x=cacc12(isub,tms);
        y=ccda(isub,tms);
        [rr,rp]=corr(x,y);
        correl(con,tms,:)=[rr rp];
        %=========================================================    
            
            x=cacc12(isub,tms);
            y=ccda(isub,tms);
            y=double(y);
            scatter(x,y,'filled',col)
            text(x+0.1,y+0.1,string(isub))
            ylim([-8,8])
            xlim([-50,50])
            mdl=fitlm(x,y);
            rs=mdl.Rsquared.Adjusted;
            be=mdl.Coefficients{2,1};
            int=mdl.Coefficients{1,1};
            pvalue=mdl.Coefficients{2,4};
            iy=mdl.Fitted;
            %hold on
            plot(x,iy,col)
            plot([-50 50],[0,0],'--')
            plot([0 0],[-8,8],'--');
            ylabel('CDA pos-pre')
            xlabel('acc pos-pre')
            axis square
            %legend('data',['y= ' num2str(int) '+ ' num2str(be) '*x'])
            title( ['change corr acc-CDA con' num2str(con) ' tms' num2str(tms)  ' Rsquared=' num2str(rs) ' p=' num2str(pvalue)])
            hold off
        end
        
        print( '-djpeg',  '-r300', ['corr_con' num2str(con) ])
        close all
        hold off
    end
  
end
close all
cd([pt_ver '\' 'result' ])

%% trilnum-CDA correlation plot 
% plot average CDA after exclude certain subjects
cd([pt_ver '\' 'result' ])
load('outsub.mat')
%outsub=[];  unique(outsub)
d={'CDA' 'CDA_cl' 'CDA_cr' 'CDA_tl' 'CDA_tr' 'ERP_con'  'ERP_con_cl'  'ERP_con_cr' 'ERP_ips' 'ERP_ips_cl' 'ERP_ips_cr'};
twin=451:800; %450-800 4ms/tpoints 350*4 300ms-1700ms   ('2TR', '2T2DR', '2T', '2T2D', '4T')

% exclude subjects by mean value outliers ================================
cd([pt_ver '\' 'result' ])
di=[1];
e=1;
for n=1%:5
    data=eval(d{n}); %size(data)
    ntri=result.trialnum;      %trialnum(sub,tms,test,con,cue,trialnum) size(ntri)
    mkdir(['x_' d{n} ])
    cd([ d{n} ])
    
    for con=1:5
        edata=data;
        ctri=ntri; %sub,tms,test,condition*type
        sube=outsub(:,con);
        subr=isubr;
        subs=isubs;
        
        
        
        if e==1
            subr=setdiff(isubr,sube);
            subs=setdiff(isubs,sube);
            cd([pt_ver '\' 'result' ])
            cd(['x_' d{n}])
        end
        
        
        % ntrials
        ctri1=squeeze(ctri(:,:,:,con,1,:)); % sub,tms,test,con,cue,trialnum  size(ctri) squeeze(ctri(:,1,1,1,:)) size(squeeze(ntri))
        ctri2=squeeze(ctri(:,:,:,con,1,:));% sub tms test size(ctri2)
        ctri12=ctri1+ctri2;  %   size(acc12)  sub tms test

        % CDA
        edata=edata(:,:,:,:,twin);
        edata=mean(edata,5); %(sub,tms,test,condition)  size(edata)
        cda=squeeze(edata(:,:,:,con));         %   sub,tms,test
        
        % change CDA
        ccda=cda(:,:,2)-cda(:,:,1); %   sub,tms
        
        
        figure('Position',[0 0 1920 1080])
        for test =1:2
            subplot(1,2,test)
            for tms=1:2
                hold on
                if tms==1
                    isub=subr;
                    p=1;
                    col='r';
                else
                    p=2;
                    isub=subs;
                    col='g';
                end
                
                x=ctri12(isub,tms,test);
                y=cda(isub,tms,test);
                y=double(y);
                scatter(x,y,'filled',col)
                text(x+0.1,y+0.1,string(isub))
                ylim([-5,5])
                xlim([0,200])
                mdl=fitlm(x,y);
                rs=mdl.Rsquared.Adjusted;
                be=mdl.Coefficients{2,1};
                int=mdl.Coefficients{1,1};
                pvalue=mdl.Coefficients{2,4};
                iy=mdl.Fitted;
                plot(x,iy,col)
                text(x(5)+0.2,iy(5)+0.2,['Rsquared=' num2str(rs) ' p=' num2str(pvalue)])
                ylabel('CDA')
                xlabel('trials')
                
                axis square
                %legend('data',['y= ' num2str(int) '+ ' num2str(be) '*x'])
                title( ['test' num2str(test)  ' trial-CDA con' num2str(con) ])
                hold off
            end
        end
        
        print( '-djpeg',  '-r300', ['corr_trial_con' num2str(con) ])
        close all
        hold off
    end
  
end
cd([pt_ver '\' 'result' ])

%% stata

cd([pt_ver '\' 'result' ])
%size(result.trialnum)  %(sub,tms,test,con,cue)
 %size(acc)
% plot average CDA after exclude certain subjects
% unique(outsub)
cd([pt_ver '\' 'result' ])
load('outsub.mat')

d={'CDA' 'CDA_cl' 'CDA_cr' 'CDA_tl' 'CDA_tr' 'ERP_con'  'ERP_con_cl'  'ERP_con_cr' 'ERP_ips' 'ERP_ips_cl' 'ERP_ips_cr'};
twin=451:800; %450-800 4ms/tpoints 350*4 300ms-1700ms   ('2TR', '2T2DR', '2T', '2T2D', '4T')
di=[1];
e=1;
for n=1%:5
    data=eval(d{n}); %size(data)
    acc=result.acc; %size(acc)
    for con=1:5
        edata=data;
        eacc=acc; %sub,tms,test,condition*type
        % acc
        acc1=squeeze(eacc(:,:,:,[4*con-3 4*con-2])); % left cue trial size(acc1) sub tms test diff
        acc1=sum(acc1,4); % sub tms test
        acc2=squeeze(eacc(:,:,:,[4*con-1 4*con])); % right cue trial size(acc2)
        acc2=sum(acc2,4); % sub tms test
        sacc(con)={(acc1+acc2)/2};  %   size(acc12)  sub tms test
        
        % acc change
        % cacc12=acc12(:,:,2)-acc12(:,:,1);
        
        % CDA
        edata=edata(:,:,:,:,twin);
        edata=mean(edata,5); %(sub,tms,test,condition)  size(edata)
        scda(con)={squeeze(edata(:,:,:,con))};         %   sub,tms,test
        
        % change CDA
        % ccda=cda(:,:,2)-cda(:,:,1); %   sub,tms
    end   
end

cd([pt_ver '\' 'result' ])

s_cda=[];
for i=1:5
cc=sacc{1,i}; %sub tms test con1(:,1,1)+con1(:,2,1)
cc=squeeze(cc(:,1,:)+cc(:,2,:));
s_cda=[s_cda cc];
end

for con=1:5
 sube=outsub(:,con);
        subr=isubr;
        subs=isubs;
        if e==1
            subr=setdiff(isubr,sube);
            subs=setdiff(isubs,sube);
        end
    
        
        
end




p=anovan(y,group);
perms
randsample
datasample
filloutliers
patch
reshape
shiftdim
permute