function mat = sinwav(Frequency,Duration,SamplingRate)
mat = sin((1:Duration*SamplingRate)*2*pi*Frequency/SamplingRate);
return
