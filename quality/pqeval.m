function ODG = pqeval(ref,tes,fs)
%
% ODG = pqeval(ref,tes,fs)
%
%  ODG : Objective Difference Grade
%  ref : reference signal
%  tes : test signal
%  fs  : sampling frequency

global tmpnam;

rfile = [tmpnam,'rr.wav'];
rfile48 = [tmpnam,'rw.wav'];
tfile = [tmpnam,'tr.wav'];
tfile48 = [tmpnam,'tw.wav'];

[rh,~] = size(ref);
[h,ch] = size(tes);

hmin = min(rh,h);
ref = ref(1:hmin,:);
tes = tes(1:hmin,:);
ODG = zeros(1,ch);
for k = 1:ch
    audiowrite(rfile, ref(:,k), fs);
	Resamp_code = sprintf('ResampAudio -s 48000 %s %s > nul',...
		 rfile, rfile48);
	system(Resamp_code);

    audiowrite(tfile, tes(:,k), fs);
	Resamp_code = sprintf('ResampAudio -s 48000 %s %s > nul',...
		 tfile, tfile48);
	system(Resamp_code);
	PQeval_code = sprintf('PQevalAudio %s %s | grep Grade',...
		 rfile48,tfile48);
	[~,res] = system(PQeval_code)
    res = strsplit(res); res = res{end - 1};
%     a = sscanf(res,'%f');
	ODG(:,k) = sscanf(res,'%f');
end
system(['rm ',rfile,' ',tfile,' ',rfile48,' ',tfile48]);
ODG = min(ODG);
