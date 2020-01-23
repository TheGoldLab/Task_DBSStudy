% analysis script
%
% Created 9/23/2019 by jig

%% Get the data
patientID = 'INFD040';
data = DBSparseRawData(patientID);

%% Sync data

% Right now getting fields by hand... probably need to generalize
% 1: TTL/spike/LFP data (*HMS1)
% 2: EOG data (*HMS2LFS)
fnames = fieldnames(data.IntraOp.EOG.STN.Pass1);

% Find TTLs
% Get TTL Channel
ttl  = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.aux.channels(2).continuous;

% Threshold values to find TTLs
TTL_THRESHOLD = 0.0015;
ttl(ttl< TTL_THRESHOLD) = 0;
ttl(ttl>=TTL_THRESHOLD) = 1;

% Get start time of each TTL
ttl_start = find(diff([0 ttl])==1);

% Get trials by finding "bursts" of TTLs within a short time
TTL_BURST_DIFF  = 1000; % min samples between TTL bursts
ttl_trialStart  = ttl_start([1 find(diff(ttl_start)>TTL_BURST_DIFF)+1]);
numTrials       = length(ttl_trialStart);
ttl_pulseCounts = nans(1,numTrials);
for tt = 1:numTrials
   if tt < numTrials
      ttl_pulseCounts(tt) = sum(ttl_start>=ttl_trialStart(tt) & ...
         ttl_start<ttl_trialStart(tt+1));
   else
      ttl_pulseCounts(tt) = sum(ttl_start>=ttl_trialStart(tt));
   end
end

% Match bandit/saccade pulse patterns
bandit_pulseCounts               = data.IntraOp.bandit.FIRA.ecodes.data(:,15)';
bandit_numTrials                 = length(bandit_pulseCounts);
data.IntraOp.bandit.ttl_indices  = [];
saccade_pulseCounts              = data.IntraOp.saccade.FIRA.ecodes.data(:,16)';
saccade_numTrials                = length(saccade_pulseCounts);
data.IntraOp.saccade.ttl_indices = [];
startIndex                      = 1;
while (isempty(data.IntraOp.bandit.ttl_indices) || ...
      isempty(data.IntraOp.saccade.ttl_indices)) && ...
      startIndex <= numTrials
   
   % Check bandit
   inds = startIndex:startIndex+bandit_numTrials-1;
   if all(inds<=numTrials) && all(ttl_pulseCounts(inds) == bandit_pulseCounts)
      data.IntraOp.bandit.ttl_indices = ttl_trialStart(inds);
   end
   
   % Check bandit
   inds = startIndex:startIndex+saccade_numTrials-1;
   if all(inds<=numTrials) && all(ttl_pulseCounts(inds) == saccade_pulseCounts)
      data.IntraOp.saccade.ttl_indices = ttl_trialStart(inds);
   end
   
   % Update index
   startIndex = startIndex + 1;
end

% Figure out and store aux sample rate
% aux_sr = median(round(diff(data.IntraOp.saccade.ttl_indices)./ ...
%    diff(data.IntraOp.saccade.FIRA.ecodes.data(:,15))'));
data.IntraOp.bandit.ttl_sr  = 8000;
data.IntraOp.saccade.ttl_sr = 8000;

% Get TTL time=0
ttl_t0 = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.aux.timestamps_aux(1);

% Get spikes, LFP, EOG
%
% Get spike channel and sample rate
spikes = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.channels.continuous;
spikes_sr = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.sampling_rate_mer;

% Get LFP channel and sample rate
lfp = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.channels.LFP;
lfp_sr = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.sampling_rate_lfs;

% Get spike/LFP time=0
record_t0 = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.first_ts;

% Get EOG data
eog = data.IntraOp.EOG.STN.Pass1.(fnames{2}).t(2).device;


for tt = {'bandit', 'saccade'}
   



   
   
   
   
   
   

% Get spike channel and sample rate
spikes = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.channels.continuous;
spikes_sr = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.sampling_rate_mer;

% Get LFP channel and sample rate
lfp = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.channels.LFP;
lfp_sr = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device.sampling_rate_lfs;

% Get EOG data
eog = data.IntraOp.EOG.STN.Pass1.(fnames{2}).t(2).device;



% Get spike/TTL data
ts   = data.IntraOp.EOG.STN.Pass1.(fnames{1}).ts;
sdat = data.IntraOp.EOG.STN.Pass1.(fnames{1}).t.device;

% Get EOG data
edat = data.IntraOp.EOG.STN.Pass1.(fnames{2}).t.device;


%% BANDIT TASK
figure

% Performance
sessions = {'PreOp', 'IntraOp'};
for ii = 1:length(sessions)
   subplot(3,1,ii); cla reset; hold on;
   ecd = data.(sessions{ii}).bandit.FIRA.ecodes.data;
   ecn = data.(sessions{ii}).bandit.FIRA.ecodes.name;
   pli = find(strcmp(ecn, 'probabilityLeft'));
   ci  = find(strcmp(ecn, 'choice'));
   ri  = find(strcmp(ecn, 'rewarded'));
   trs = 1:size(ecd,1);
   plot(1-ecd(:,pli), 'b.-'); % prob rightsdat
   
   % Plot rewarded/not choices
   Lrew = ecd(:,ri) == 1;
   plot(trs(Lrew), ecd(Lrew, ci), 'ro');
   plot(trs(~Lrew), ecd(~Lrew, ci), 'cx');
end


%% SACCADE TASK


studyTag = 'DBSStudy';
filebase = '2019_08_29_14_23';
[topNode, FIRA] = topsTreeNodeTopNode.loadRawData(studyTag, filebase);

% task indices
%  1  = VGS
%  2  = MGS
%  3  = Quest dots
%  7  = Speed, no bias
%  10 = Accuracy, no bias
%figure
tis = [1 2 3 7 10];
nts = length(tis);
lm  = 15;
td  = topNode.nodeData{'Settings'}{'targetDistance'}; 
clf

durs = FIRA.ecodes.data(:,strcmp(FIRA.ecodes.name, 'trialEnd')) - ...
   FIRA.ecodes.data(:,strcmp(FIRA.ecodes.name, 'trialStart'));

% For each task
for tt = 1:nts
   
   % For each trial
   for ii = find(FIRA.ecodes.data(:,1)==tis(tt))'
      
      
      tax   = FIRA.analog.data{ii}(:,1);
      xs    = nanrunmean(FIRA.analog.data{ii}(:,2),50);
      ys    = nanrunmean(FIRA.analog.data{ii}(:,3),50);
            
      % get index of saccade soon after RT
      if FIRA.ecodes.data(ii,1) <= 2
         refTime = FIRA.ecodes.data(ii,strcmp(FIRA.ecodes.name, 'fixationOff')); % Fix off for VGS/MGS
      else
         refTime = FIRA.ecodes.data(ii,strcmp(FIRA.ecodes.name, 'dotsOn')); % Dots on
      end
      
      % Event times
      fixIndex    = find(tax>=refTime,1);
      sacEndTime  = refTime+FIRA.ecodes.data(ii,strcmp(FIRA.ecodes.name, 'RT'))+0.1;
      sacEndIndex = find(tax>=(sacEndTime),1);
      Lgood       = tax>=(refTime-0.4) & tax<=min(sacEndTime+0.5, durs(ii));
      
      % rezero just before fpoff
      %xs = xs - nanmean(xs(fixIndex-10:fixIndex));
      %ys = ys - nanmean(ys(fixIndex-10:fixIndex));
      
      % x vs y
     %  subplot(nts, 2, (tt-1)*2+1); hold on;
     subplot(2,1,1); cla reset; hold on;
      plot([-lm lm], [0 0], 'k:');
      plot([0 0], [-lm lm], 'k:');
      if FIRA.ecodes.data(ii,1) <= 2
         plot([-td td 0 0], [0 0 -td td], 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 12);
      else
         plot([-td td], [0 0], 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 12);
      end
      plot(xs(Lgood), ys(Lgood), 'k-');
      plot(xs(fixIndex), ys(fixIndex), 'go', 'MarkerSize', 12);
      plot(xs(sacEndIndex), ys(sacEndIndex), 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 12);
      axis([-lm lm -lm lm]);
      
      % x,y vs t
      %subplot(nts, 2, (tt-1)*2+2); hold on;
      subplot(2,1,2); cla reset; hold on;
      plot([-1 2], [0 0], 'k:');
      plot([0 0], [-lm lm], 'k:');
      plot([-1 2],  [td td], 'r:');
      plot([-1 2], -[td td], 'r:');
      plot(tax(Lgood)-refTime, xs(Lgood), 'c-');
      plot(tax(Lgood)-refTime, ys(Lgood), 'm-');
      
      r = input('next')
   end
end
