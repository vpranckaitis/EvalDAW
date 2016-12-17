function m_stego = decode(y,fs,m,varargin)
%
% input
%   y : stego data
%   fs : sampling frequency of stego data
%   m : original secret message
%   varargin : etc parameter
% output
%   m_stego : detected secret message
%

addpath('algorithms');
segment_size = varargin{1};
shift = varargin{2};
text_length = length(m);
m_stego = phase_coding_decode(y, text_length, segment_size, shift);
end