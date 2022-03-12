clear
clc

srate=100;
time=-1:1/srate:2;
pnts=length(time);

hz=linspace(0,srate/2,floor(length(time)/2)-1);

stretch=3;
shift=0;

rng(3);

noise=stretch_randn(size(time))+shift;

amp=abs(fft(noise)/pnts);


figure(4), 
subplot


%%
cftool
load franke
cftool


phas=rand(100,1)*2*pi-pi;
ampl=randn(100,1)*30+100;
x= hilbert(ampl);
a=sqrt(real(x).*real(x)+imag(x).*imag(x));
b=atan2(real(x),imag(x));
a1=abs(x);
b1= (x);



[MI,distKL]=DmodulationIndex(ampl,phas);






s=0:0.1:10;
si=10*sin(2*pi*1*s);
a= hilbert(si);
amp=sqrt(real(a).*real(a)+imag(a).*imag(a));
pha=atan2(real(a),imag(a));
[MI,distKL]=DmodulationIndex(amp,pha);

%bin=linspace(-pi,pi,18);
[n,edge,bin]=histcounts(pha,18);
for i=1:18
   ampg(i)=mean(amp(bin==i)); 
end


