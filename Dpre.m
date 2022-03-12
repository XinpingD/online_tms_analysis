%EEG pre processing for online TMS project
% steps include: pick right trials,select channel,resample,filtering,epoch,rmbase,
% ICA, EEG threshold (150), re-reference(average)
%
%input: 
%namepool:name for subjects to be processed
%pt_raw:path for raw data
%pt_work:path for working directory
%ICA: doing ICA or not, 1,do,0,do not
%chan:channel for EEG thresholding
%filt: [0.1 30] doing filter if filt~=[], not do it if filt=[]; default
%value is 0.1-30 Hz   filt=[0.1 30]
%epochtime:time window for epoch epochtime=[-1.5,2]
%mark:eeg epoch mark:[116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946];  
%[2TR 2T2DR 2T 2T2D 4T ]
%
% return summary results for pre-processing whihc include: ACC,number of rejected epochs,number of rejected
% components also return savepath of processed data
% usage:[result]=Dpre(namepool,pt_raw,pt_work,pt_save,ICA,chan,filt,mark,epochtime);
% last modified 20211105


function [result]=Dpre(namepool,pt_raw,pt_work,pt_save,ICA,chan,filt,mark,epochtime)
%chan=[51:53 55:57];
 conmark=mark';     % mark for each condition  116 126 left same change 136 146 right same change


for n=1:length(namepool)
    
    % fn='1101_yangyongqiang';
    fn=namepool{n};
    % fn='1201_yangyongqiang';  % input filename to be processing  fn=file name 1101=tms test sub (tms:1,2,3=real,sham,only real)  (test:1,2=pre,post) (sub=01,21...)
    %'031_wangcong'
    
    
    
    
    tms=str2double(fn(1)); % tms 1,real tms; 2,sham tms
    test=str2double(fn(2)); % test 1, pre-test, 2, post-test
    
    if fn(3)=='0'
        sub=str2double(fn(4));
    else
        sub=str2double(fn([3,4]));
    end
    
    %conmark= [116  126  136  146  316 326 336 346 516  526  536  546  716 726  736  746  916  926  936  946]';     % mark for each condition  116 126 left same change 136 146 right same change
    % chan=[51:53 55:57];  % parietal chan PO7/5/3/4/6/8
    % time=[-1500,-1496,-1492,-1488,-1484,-1480,-1476,-1472,-1468,-1464,-1460,-1456,-1452,-1448,-1444,-1440,-1436,-1432,-1428,-1424,-1420,-1416,-1412,-1408,-1404,-1400,-1396,-1392,-1388,-1384,-1380,-1376,-1372,-1368,-1364,-1360,-1356,-1352,-1348,-1344,-1340,-1336,-1332,-1328,-1324,-1320,-1316,-1312,-1308,-1304,-1300,-1296,-1292,-1288,-1284,-1280,-1276,-1272,-1268,-1264,-1260,-1256,-1252,-1248,-1244,-1240,-1236,-1232,-1228,-1224,-1220,-1216,-1212,-1208,-1204,-1200,-1196,-1192,-1188,-1184,-1180,-1176,-1172,-1168,-1164,-1160,-1156,-1152,-1148,-1144,-1140,-1136,-1132,-1128,-1124,-1120,-1116,-1112,-1108,-1104,-1100,-1096,-1092,-1088,-1084,-1080,-1076,-1072,-1068,-1064,-1060,-1056,-1052,-1048,-1044,-1040,-1036,-1032,-1028,-1024,-1020,-1016,-1012,-1008,-1004,-1000,-996,-992,-988,-984,-980,-976,-972,-968,-964,-960,-956,-952,-948,-944,-940,-936,-932,-928,-924,-920,-916,-912,-908,-904,-900,-896,-892,-888,-884,-880,-876,-872,-868,-864,-860,-856,-852,-848,-844,-840,-836,-832,-828,-824,-820,-816,-812,-808,-804,-800,-796,-792,-788,-784,-780,-776,-772,-768,-764,-760,-756,-752,-748,-744,-740,-736,-732,-728,-724,-720,-716,-712,-708,-704,-700,-696,-692,-688,-684,-680,-676,-672,-668,-664,-660,-656,-652,-648,-644,-640,-636,-632,-628,-624,-620,-616,-612,-608,-604,-600,-596,-592,-588,-584,-580,-576,-572,-568,-564,-560,-556,-552,-548,-544,-540,-536,-532,-528,-524,-520,-516,-512,-508,-504,-500,-496,-492,-488,-484,-480,-476,-472,-468,-464,-460,-456,-452,-448,-444,-440,-436,-432,-428,-424,-420,-416,-412,-408,-404,-400,-396,-392,-388,-384,-380,-376,-372,-368,-364,-360,-356,-352,-348,-344,-340,-336,-332,-328,-324,-320,-316,-312,-308,-304,-300,-296,-292,-288,-284,-280,-276,-272,-268,-264,-260,-256,-252,-248,-244,-240,-236,-232,-228,-224,-220,-216,-212,-208,-204,-200,-196,-192,-188,-184,-180,-176,-172,-168,-164,-160,-156,-152,-148,-144,-140,-136,-132,-128,-124,-120,-116,-112,-108,-104,-100,-96,-92,-88,-84,-80,-76,-72,-68,-64,-60,-56,-52,-48,-44,-40,-36,-32,-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104,108,112,116,120,124,128,132,136,140,144,148,152,156,160,164,168,172,176,180,184,188,192,196,200,204,208,212,216,220,224,228,232,236,240,244,248,252,256,260,264,268,272,276,280,284,288,292,296,300,304,308,312,316,320,324,328,332,336,340,344,348,352,356,360,364,368,372,376,380,384,388,392,396,400,404,408,412,416,420,424,428,432,436,440,444,448,452,456,460,464,468,472,476,480,484,488,492,496,500,504,508,512,516,520,524,528,532,536,540,544,548,552,556,560,564,568,572,576,580,584,588,592,596,600,604,608,612,616,620,624,628,632,636,640,644,648,652,656,660,664,668,672,676,680,684,688,692,696,700,704,708,712,716,720,724,728,732,736,740,744,748,752,756,760,764,768,772,776,780,784,788,792,796,800,804,808,812,816,820,824,828,832,836,840,844,848,852,856,860,864,868,872,876,880,884,888,892,896,900,904,908,912,916,920,924,928,932,936,940,944,948,952,956,960,964,968,972,976,980,984,988,992,996,1000,1004,1008,1012,1016,1020,1024,1028,1032,1036,1040,1044,1048,1052,1056,1060,1064,1068,1072,1076,1080,1084,1088,1092,1096,1100,1104,1108,1112,1116,1120,1124,1128,1132,1136,1140,1144,1148,1152,1156,1160,1164,1168,1172,1176,1180,1184,1188,1192,1196,1200,1204,1208,1212,1216,1220,1224,1228,1232,1236,1240,1244,1248,1252,1256,1260,1264,1268,1272,1276,1280,1284,1288,1292,1296,1300,1304,1308,1312,1316,1320,1324,1328,1332,1336,1340,1344,1348,1352,1356,1360,1364,1368,1372,1376,1380,1384,1388,1392,1396,1400,1404,1408,1412,1416,1420,1424,1428,1432,1436,1440,1444,1448,1452,1456,1460,1464,1468,1472,1476,1480,1484,1488,1492,1496,1500,1504,1508,1512,1516,1520,1524,1528,1532,1536,1540,1544,1548,1552,1556,1560,1564,1568,1572,1576,1580,1584,1588,1592,1596,1600,1604,1608,1612,1616,1620,1624,1628,1632,1636,1640,1644,1648,1652,1656,1660,1664,1668,1672,1676,1680,1684,1688,1692,1696,1700,1704,1708,1712,1716,1720,1724,1728,1732,1736,1740,1744,1748,1752,1756,1760,1764,1768,1772,1776,1780,1784,1788,1792,1796,1800,1804,1808,1812,1816,1820,1824,1828,1832,1836,1840,1844,1848,1852,1856,1860,1864,1868,1872,1876,1880,1884,1888,1892,1896,1900,1904,1908,1912,1916,1920,1924,1928,1932,1936,1940,1944,1948,1952,1956,1960,1964,1968,1972,1976,1980,1984,1988,1992,1996];
    
    if exist([pt_work  'predata.mat'],'file')
        load([pt_work  'predata.mat'])
       
        TMS=result.TMS;
        ICArej=result.ICArej;
        %ntrial=result.ntrial;
        %erp=result.erp;
        eporej=result.eporej;
        %CDA=result.CDA;
        acc=result.acc;
        trialnum=result.trialnum;
        %lCDA=result.lCDA;
        %rCDA=result.rCDA;
        
        
    else
        %result.erp=[];
        result.ICArej=[];
        result.acc=[];
        result.TMS=[];
        %result.ntrial=[];
        result.eporej=[];
        result.trialnum=[];
        %result.CDA=[];
        %result.lCDA=[];
        %result.rCDA=[];
    end
    
    % find(result.erp(:,1,1,1,1,1,1))
    % result.ICArej=[];
    % result.eporej=[];
    % result.ntrial=[];
    % result.erp=[];
    % result.CDA=[];
    % result.acc=[];
    % result.tms=[];
    TMS(sub,1)=tms;
    result.TMS=TMS;
    
    
    %eeglab;-------------------------------------------------------------------
    EEG = loadcurry([pt_raw fn '.cdt'], 'CurryLocations', 'False');
    
    
    % mark right trials=====================================================
    for i= 1:length(EEG.event)   %oevent=EEG.event;
        a(i,1)=EEG.event(i).type; %a(i,1)=str2double(EEG.event(i).type);%newvar提出markerfor i=1:length(a)
        if i>2&&(a(i,1)==35||a(i,1)==55||a(i,1)==75||a(i,1)==95)||a(i,1)==115||a(i,1)==135
            a(i-2,1)=a(i-2,1)*10+6;
        elseif i>3&&a(i,1)==15
            a(i-3,1)=a(i-3,1)*10+6;
        end
    end
    %加6,尾号6代表正确
    
    for i=1:length(EEG.event)
        EEG.event(1,i).type=a(i,1);% add new mark back into EEG data
    end
    
    % count correct trials
    for i= 1:length(conmark)
        c=0; %count for each trial type
        for j=1:length(EEG.event)
            if EEG.event(j).type==conmark(i)
                c=c+1;
            end
        end
        acc(sub,tms,test,i)=c;
    end
    result.acc=acc; % sub tms test con*type      [2TR 2T2DR 2T 2T2D 4T ]    1:left same 2:left change 3:right same 4:right change
    
    
    %figure; pop_erpimage(EEG,1, [53],[[]],'PO7',10,1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','topo', { [53] EEG.chanlocs EEG.chaninfo } );
    %figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
    % eeglab redraw
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',{'M1' 'M2' 'HEO' 'VEO'});
    EEG = pop_resample( EEG, 250);
    
    %EEG = eeg_checkset( EEG );
    if filt~=0 %filt=[];
    EEG = pop_eegfiltnew(EEG, 'locutoff',filt(1,2),'hicutoff',filt(1,1),'plotfreqz',1);
    end
    %EEG = eeg_checkset( EEG );
    %EEG = pop_reref( EEG, []);
    %EEG = eeg_checkset( EEG );
    
    
    %===========================epoch and ICA========================================================================
    
    EEG = pop_epoch( EEG,  num2cell(conmark), epochtime, 'newname', [fn '_epochs'], 'epochinfo', 'yes');
    % epoEEG = pop_epoch( EEG,  num2cell(conmark), epochtime, 'newname', [fn '_epochs'], 'epochinfo', 'yes');
    %EEG = eeg_checkset( EEG );
    %-------------------------------------------------------------------------------------------
    EEG = pop_rmbase( EEG, [-1200 -200] ,[]);
    %-------------------------------------------------------------------------------------------
    EEG = pop_saveset( EEG, 'filename',[fn  '_epoch.set'],'filepath', [pt_work  'erp\' ]);
    
    
    for ICA=ICA
        EEG=pop_loadset([pt_work  'erp\' fn  '_epoch.set']);
        if ICA==1
            EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
            EEG = pop_saveset( EEG, 'filename',[fn  '_ICA.set'],'filepath', [pt_work  'ICA\' ]);
            EEG = pop_iclabel(EEG, 'default');
            EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;0.99 1;0.99 1;0.99 1;0.99 1]);
            ICAreject=find(EEG.reject.gcompreject);% save reject ICA compnents information
            if find(EEG.reject.gcompreject)
                ICArej(sub,test)=length(ICAreject);
                EEG = pop_subcomp( EEG, find(EEG.reject.gcompreject), 0);
            else
                ICArej=[];
                
            end
            result.ICArej=ICArej;
        else
            EEG=pop_loadset([pt_work  'ICA\' fn  '_ICA.set']);
            EEG = pop_iclabel(EEG, 'default');
            EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;0.99 1;0.99 1;0.99 1;0.99 1]);
            ICAreject=find(EEG.reject.gcompreject);% save reject ICA compnents information
            if find(EEG.reject.gcompreject)
                ICArej(sub,test)=length(ICAreject);
                EEG = pop_subcomp( EEG, find(EEG.reject.gcompreject), 0);
            else
                ICArej=[];
            end
            result.ICArej=ICArej;
        end
        
        
        
        
        
        
        
    end
    
    
    %EEG = pop_rmbase( EEG, [-1500 -500] ,[]);
    %EEG = pop_rmbase( EEG, [-1200 -200] ,[]);
    %EEG = eeg_checkset( EEG );
    %EEG = pop_eegthresh(EEG,1,chan ,-75,75,-1.5,1.996,1,0); %211115
    %-------------------------------------------------------------------------------------------
    %EEG = pop_eegthresh(EEG,1,chan ,-200,200,0.3,1.996,1,0);  %220110
    EEG = pop_eegthresh(EEG,1,chan ,-60,60,-1.5,1.996,1,0);  %220114
    %-------------------------------------------------------------------------------------------
    
    EEG = eeg_checkset( EEG );
    rejtrials=find(EEG.reject.rejthresh);
    
    
    eporej(sub,test)=length(find(rejtrials)); % sub test
    result.eporej=eporej;
    
    EEG=pop_rejepoch(EEG,rejtrials,0);
    EEG = pop_reref( EEG, []);
    % save rejepoch data in the erp directory
    EEG = pop_saveset( EEG, 'filename',[fn  '_ICA_rejepoch.set'],'filepath', pt_save);
    %gEEG(sub,test)=EEG;
    
    %save([pt_work  'predata.mat'], 'result')
    %save([pt_work  'predata.mat'], 'result','gEEG','-v7.3')
    

    for con=1:5  %[2TR 2T2DR 2T 2T2D 4T ]   
    clear ltrial rtrial 
    type=[conmark(4*con-3,1) conmark(4*con-2,1) conmark(4*con-1,1) conmark(4*con,1)]';   
     for i=1:length(EEG.event)
            if EEG.event(1,i).type==type(1,1)||EEG.event(1,i).type==type(2,1)%(conmark(4*con-3,1)
                % a(con,1)=a(con,1)+1;
                ltrial(i,1)=EEG.event(1,i).epoch;%con1_left store the index of trial number of left target correct response of condition 1
            else
                ltrial(i,1)=0;
            end
            ltrial(ltrial==0)=[];
            lnum=size(ltrial,1);
            if EEG.event(1,i).type==type(3,1)||EEG.event(1,i).type==type(4,1)%(conmark(4*con-3,1)
                % a(con,1)=a(con,1)+1;
                rtrial(i,1)=EEG.event(1,i).epoch;%con1_left store the index of trial number of left target correct response of condition 1
            else
                rtrial(i,1)=0;
            end
            rtrial(rtrial==0)=[];
            rnum=size(rtrial,1);
     end
       result.trialnum(sub,tms,test,con,1,:)=rnum; % trialnum(sub,tms,test,con,cue,trialnum)
       result.trialnum(sub,tms,test,con,2,:)=lnum; 
    end
    
    save([pt_work  'predata.mat'], 'result','-v7.3')
    close all
end  
end