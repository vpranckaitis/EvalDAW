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
	
	lengthm = min(length(m),length(m_stego));

	er(ite) = 100 * length(find(m(1:lengthm)-m_stego(1:lengthm))) / lengthm; 
end
er = mean(er);
end
