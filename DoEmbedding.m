function [encbit,err] = DoEmbedding(wavname,dat,varargin)

fname = sprintf('input/%d.wav',wavname);
[x,fs] = audioread(fname, 'native');

info = audioinfo(fname);
nbits = info.BitsPerSample;

fname_out = sprintf('%d',wavname);
for i = 1:length(varargin)
    tmp = sprintf('_%d',round(varargin{i}));
    fname_out = strcat(fname_out,tmp)
end
fname_out = strcat(fname_out,'_stego.wav')

for ich = 1:size(x,2)
	[y(:,ich),err(ich)] = embed(x(:,ich),fs,nbits,dat,varargin{:});
	waveval = sprintf('%d.wav',wavname);

    audiowrite(waveval, x(:,ich), fs);
% 	[y(:,ich), encbit] = tse_enc(waveval,dat);
end
err = 0;

if length(find(err==1)) == 0
    if nbits == 8
        y = uint8(y);
    elseif nbits == 16
        y = int16(y);
    end
    audiowrite(fname_out, y, fs);
end
