function y = change_speed(x,fs,ratio)

global tmpnam;

fprintf('====speed_change %fratio start===\n',ratio);
[c, ch] = size(x);
wfile = [tmpnam, 'w.wav'];
rfile = [tmpnam, 'r.wav'];

for k=1:ch
    audiowrite(rfile, x(:,k), fs);
	resamp_code = sprintf('ResampAudio -s %d %s %s > nul', round(fs/ratio), rfile, wfile);
	system(resamp_code);
    tmp = audioread(wfile);
	y(1:length(tmp),k) = tmp;
end
system(['rm ', wfile, ' ', rfile]);

fprintf('====speed_change %fratio end===\n\n',ratio);