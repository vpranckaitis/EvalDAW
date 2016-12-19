function [ results, failed ] = run_echo_tests()
  results = containers.Map('KeyType','double','ValueType','any');
  failed = containers.Map('KeyType','double','ValueType','double');

  Nite = 1

  watermarks = {'test', ...
                'Tekstas uzslepimui', ...
                'Slaptas Tekstas', ...
                'ALL CAPS', ...
                '0123456789', ...
                '!@#$%^&*()_+', ...
                'אטזכבנרû‏', ...
                ' g h j y  2    a    f   '};
% 
%   watermarks = {'Tekstas uzslepimui'};

%   audio_names = {'1_mono', '66', '69', '70'};

  % NOTE: 1 and 2 are mono; 69, 69 and 70 are stereo
%  audio_names = [1, 66, 69, 70, 51];
  audio_names = [51];

  % zero delay = 0.61 | Should result in 27 samples
  % one delay = 0.73  | Should result in 32 samples
  % decay rate = 0.8  | Must be between 0.3 and 0.85
  zero_delay = 0.61;
  one_delay = 0.73;
  decay_rate = 0.8;
  
%   zero_delays = [0.1, 0.3, 0.5];
%   one_delays = 0.73;
%   decay_rates = 0.8;
  

  global algorithm_id;
  algorithm_id = 1;

%   for
  for audio_name = audio_names
    results(audio_name) = [];
    failed(audio_name) = 0;

    for watermark = watermarks
        random_stuff = round(rand() * 10000);
        text = char(watermark);
        DoEmbedding(audio_name, text, zero_delay, one_delay, decay_rate, random_stuff);
        [result,ODG] = AllDoDetection(audio_name, text, Nite, zero_delay, one_delay, decay_rate, random_stuff);
        ODG

        if result.orig == 0
            failed(audio_name) = failed(audio_name) + 1;
        end

        results(audio_name) = [results(audio_name) result];

    end
      
  end
%   end

  for k=cell2mat(keys(results))
      display(k);
      vals = results(k);
      if isempty(vals)
          display('Nothing to show equate to 0');
          continue;
      end
      fn = fieldnames(vals(1));
      for j = 1:length(fn)
        f = fn(j);
        f = f{1};
        ss = [];
        for i=1:length(vals)
            s = vals(i).(f);
            ss = [ss s];
        end
        display(sprintf('%s\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f', ...
            f, min(ss), max(ss), mean(ss), median(ss), std(ss)));
      end
  end

end
