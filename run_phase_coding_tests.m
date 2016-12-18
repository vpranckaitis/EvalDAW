function [ results, failed ] = run_phase_coding_tests()
  results = containers.Map('KeyType','double','ValueType','any');
  failed = containers.Map('KeyType','double','ValueType','double');
  text = 'tekstas uzslepimui';
  
  global algorithm_id;
  algorithm_id = 0;
  
  for segment_size=1024*[1,2,4,8]
    results(segment_size) = [];
    failed(segment_size) = 0;
    for audio_name=[66,69,70]
        
      sample_rate = 44100;
      start_pos = floor(3*sample_rate / segment_size);
      step = floor(sample_rate / segment_size);
      end_pos = start_pos + step * 5;
      
      for position=start_pos:step:end_pos
        DoEmbedding(audio_name, text, segment_size, position)
        [result,ODG] = AllDoDetection(audio_name, text, 1, segment_size, position);
        ODG
        if result.orig > 0
          failed(segment_size) = failed(segment_size) + 1;
        else
          results(segment_size) = [results(segment_size) result];
        end
      end
    end
  end
end

