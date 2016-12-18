function er = DoDetection(astego,fs,nbits,m,Nite,varargin)
%
% er = DoDetection(astego,fs,m,Nite)
%
% astego : attacked stego signal (example y.mp3 )
% fs: sampling rate
% m: original message


[h,ch] = size(astego);
for ite = 1:Nite
	ich = randperm(ch,1);
	y = astego(:,ich);

	% Detection Code here
% 	[m_stego(:,ite)] = detection_code(y,....);
	m_stego = decode(y,fs,nbits,m,varargin{:});

% 	% BEGIN == fix for tsedec == 
% 	wavwrite(y,fs,'tseenc.wav');	
% 	[m_stego, idx, cn, flag] = d;
% 	% END == fix for tsedec ==
	
	lengthm = length(text2bits(m));
    
    if length(m_stego) >= length(m)
        m_stego_adjusted = m_stego(1, 1 : length(m));

        er(ite) = 100 * length(find(text2bits(m)-text2bits(m_stego_adjusted))) / lengthm;
    else
        er(ite) = 100;
    end
end
er = mean(er);
end

function Y = de2bi(X)
    Y = zeros(size(X, 1), 8);
    for i = 1 : size(X, 1)
        Y(i, :) = bitget(X(i), 8 : -1 : 1);
    end
end

function [ textBits ] = text2bits(text)
    textBytes = unicode2native(text)';
    textBitsMatrix = de2bi(textBytes);
    textBits = reshape(textBitsMatrix', length(textBitsMatrix(:)), 1);
end