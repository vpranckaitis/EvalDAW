function [er,ODG] = AllDoDetection(wavname,dat,Nite,varargin)
owave = sprintf('input/%d.wav',wavname);
rwave = sprintf('%d',wavname);
for i=1:length(varargin)
	tmp = sprintf('_%d',varargin{i});
	rwave = strcat(rwave,tmp)
end
rwave = strcat(rwave,'_stego.wav');

[o,fs,nbits] = wavread(owave);
[x,fs,nbits] = wavread(rwave);

addpath('quality');
ODG = pqeval(o,x,fs);

addpath('robustness');
y = ihc2013attack(x,fs);
er.orig = DoDetection(y.orig,fs,nbits,dat,Nite,varargin{:});
er.mp3o = DoDetection(y.mp3o,fs,nbits,dat,Nite,varargin{:});
er.wgn0 = DoDetection(y.wgn0,fs,nbits,dat,Nite,varargin{:});
er.bapf = DoDetection(y.bapf,fs,nbits,dat,Nite,varargin{:});
er.tsmp = DoDetection(y.tsmp,fs,nbits,dat,Nite,varargin{:});
er.tsmm = DoDetection(y.tsmm,fs,nbits,dat,Nite,varargin{:});
er.spep = DoDetection(y.spep,fs,nbits,dat,Nite,varargin{:});
er.spem = DoDetection(y.spem,fs,nbits,dat,Nite,varargin{:});
er.echo = DoDetection(y.echo,fs,nbits,dat,Nite,varargin{:});
er.mp3t = DoDetection(y.mp3t,fs,nbits,dat,Nite,varargin{:});
er.mp4a = DoDetection(y.mp4a,fs,nbits,dat,Nite,varargin{:});
er.daad = DoDetection(y.daad,fs,nbits,dat,Nite,varargin{:});
