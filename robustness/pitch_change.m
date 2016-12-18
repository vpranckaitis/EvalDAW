function out = pitch_change(sig, sf, ratio);

% pitch change using picola

global tmpnam;

fprintf('====pitch_change %fratio start===\n',ratio);
[c, ch] = size(sig);
wfile = [tmpnam, 'w.wav'];
rfile = [tmpnam, 'r.wav'];

for k=1:ch
  audiowrite(wfile, sig(:,k), sf);
  system(sprintf('picola %s %s %g', wfile, rfile, ratio));
  system(sprintf('ResampAudio -s %d %s %s > nul', round(sf/ratio), rfile, wfile));
  tmp = audioread(wfile);
  out(1:length(tmp),k) = tmp;
end
system(['rm ', wfile, ' ', rfile]);
fprintf('====pitch_change %fratio end===\n\n',ratio);
  
