function m_stego = decode(y, fs, nbits, m, varargin)
    %
    % input
    %   y : stego data
    %   fs : sampling frequency of stego data
    %   nbits : bits per sample
    %   m : original secret message
    %   varargin : etc parameter
    % output
    %   m_stego : detected secret message
    %

    addpath('algorithms');

    global algorithm_id;
    
    if algorithm_id == 0
        % Phase coding
        segment_size = varargin{1};
        shift = varargin{2};
        text_length = length(m);
        m_stego = phase_coding_decode(y, text_length, segment_size, shift);
    else
        % Echo
        % NOTE: statistically best delays:
        % zero delay = 0.61 | Should result in 27 samples
        % one delay = 0.73  | Should result in 32 samples
        zero_delay = varargin{1};
        one_delay = varargin{2};
        m_stego = echo_decode(y, fs, nbits, zero_delay, one_delay);
    end
end