function tr = upstate_model(num_pyramid,num_inter,inter_freq,trans_prob,hist_len,up_prob,avg_upstate,tot_time)
%tr = upstate_model(num_pyramid,num_inter,inter_freq,trans_prob,hist_len,up_prob,avg_upstate,tot_time)
%   model for the firing of upstates by pyramidal cells as a result of post-inhibitory rebound
%   num_pyramid - number of pyramidal cells
%   num_inter   - number of interneurons
%   inter_freq  - frequency of Poisson firing by interneurons in Hz
%   trans_prob  - probability an IPSP in response to an interneuron spike 
%   hist_len    - length of history in msec that determines the probability of going into an upstate
%   up_prob     - parameter that determines the probability of going into an upstate after an IPSP:
%                 a sigmoidal function, P(transition) = f^p/(f^p+th^p)
%                 where f is the frequency of IPSP's throughout the history,
%                 th is the threshold frequency, and p is the "roughness" of the threshold
%                 The input, up_prob = [th p]
%   avg_upstate - the average length of an upstate in msec; lengths follow an exponential distribution
%   tot_time    - total length of the recording in seconds

opengl neverselect;

spks = [];
for c = 1:num_inter
    spks = [spks poisson(inter_freq,tot_time)];
end
spks = sort(spks);

warning off
tr = zeros(num_pyramid,tot_time);
for c = 1:num_pyramid
    nums = rand(1,size(spks,2));
    f = find(nums<trans_prob);
    ipsp = spks(f);
    num_ipsp = zeros(1,tot_time);
    for d = 1:hist_len
        k = histc(ipsp,d:hist_len:tot_time+1);
        num_ipsp(hist_len+d:tot_time+1) = k(1:end-1)/hist_len;
        k = sum(hist(ipsp,[0 d]));
        num_ipsp(d) = k/d;
    end
    ipsp = round(ipsp+0.5);
    nums = num_ipsp(ipsp);
    %probs = 1-exp(-(nums/hist_len)*up_prob);
    probs = (nums/hist_len).^up_prob(2)./((nums/hist_len).^up_prob(2)+up_prob(1).^up_prob(2));
    is_up = (rand(size(probs,1),size(probs,2))<probs);
    upstates = ipsp(find(is_up==1));
    lengths = round(random('Exponential',avg_upstate,1,size(upstates,2))-0.5)+1;
    for d = 1:size(upstates,2)
        if tr(c,upstates(d))==0
            tr(c,upstates(d):min([upstates(d)+lengths size(tr,2)])) = 1;
        end
    end
    if mod(c,10)==0; fprintf('.'); end
end
warning on




function poisson = poisson(r,t)
%poisson = poisson(r,t)
%   creates a Poisson spike train with average firing rate r and length t

m = cumsum(random('Exponential',1/(r+eps),1,fix(5*t*r)+10));
poisson = m(find(m<t));