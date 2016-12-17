function [y,err] = embed(x,fs,m,varargin)
%
% input
%   x : host data
%   fs : sampling frequency of host data
%   m : secret bits in [-1,1] 
%   varargin : etc. parameter
% output
%   y : stego data
%   err : error of embedding
%

addpath('algorithms');
segment_size = varargin{1};
shift = varargin{2};
y = phase_coding_encode(x, m, segment_size, shift);
err = 0;

end