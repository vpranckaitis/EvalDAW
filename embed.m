function [y, err] = embed(x, fs, nbits, m, varargin)
    %
    % input
    %   x : host data
    %   fs : sampling frequency of host data
    %   nbits : bits per sample
    %   m : secret bits in [-1,1] 
    %   varargin : etc. parameter
    % output
    %   y : stego data
    %   err : error of embedding
    %

    addpath('algorithms');

    % Phase coding
%     segment_size = varargin{1};
%     shift = varargin{2};
%     y = phase_coding_encode(x, m, segment_size, shift);

    % Echo
    % NOTE: statistically best delays:
    % zero delay = 0.61 | Should result in 27 samples
    % one delay = 0.73  | Should result in 32 samples
    % decay rate = 0.8  | Must be between 0.3 and 0.85
    zero_delay = varargin{1};
    one_delay = varargin{2};
    decay_rate = varargin{3};
    y = echo_encode(x, m, fs, nbits, zero_delay, one_delay, decay_rate);

    err = 0;

end