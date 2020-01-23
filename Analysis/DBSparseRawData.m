function data = DBSparseRawData(patientID, sessionTag)
% function data = DBSparseRawData(patientID, sessionTag)
%
% Assumes file are organized as:
%  <base>/<patientID>/<sessionTag>
% 
% Where:
%  <sessionTag> = PreOp, IntraOp, etc

% Check args
if nargin < 1 || isempty(patientID)
   patientID = 'INFD040'; % Example
end

if nargin < 2
   sessionTag = '';
end

% Define study tag
studyTag = 'DBSStudy';

% Get base path
basepath = fullfile( ...
   dotsTheMachineConfiguration.getDefaultValue('dataPath'), ...
   studyTag, 'raw', patientID);

% Make a struct
data = struct;

%% Open Pre-Operative data
%
if isempty(sessionTag) || strcmp(sessionTag, 'Preop')
   
   % Find the data directory
   d = dir(fullfile(basepath, 'Preop'));
   Ldir = strncmp('20', {d.name}, 2);
         
   % Check if data directory exists
   if any(Ldir)
      
      % Clear the data log
      topsDataLog.theDataLog(true);

      % Get filename
      filename = fullfile(basepath, 'Preop', d(Ldir).name);
      
      % get the mainTreeNode
      mainTreeNodeStruct = topsDataLog.getTaggedData(...
         'mainTreeNode', filename);
                  
      % Save the topNode
      data.PreOp.bandit.topNode = mainTreeNodeStruct.item;
         
      % Now read the ecodes -- note that this works only if the trial
      %  struct was made with SCALAR entries only
      data.PreOp.bandit.FIRA.ecodes = topsDataLog.parseEcodes('trial');
   end
end

%% Open Intra-Operative data
%
if isempty(sessionTag) || strcmp(sessionTag, 'Intraop')
   
   % Get saccade data
   d = dir(fullfile(basepath, 'Intraop', '*_saccade'));
   
   % Check if data directory exists
   if ~isempty(d)
      
      % Clear the data log
      topsDataLog.theDataLog(true);
      
      % Get filename
      filename = fullfile(basepath, 'Intraop', d.name, ...
         [d.name(1:end-length('_saccade')) '_topsDataLog.mat']);
      
      % get the mainTreeNode
      mainTreeNodeStruct = topsDataLog.getTaggedData(...
         'mainTreeNode', filename);
                  
      % Save the topNode
      data.IntraOp.saccade.topNode = mainTreeNodeStruct.item;
         
      % Now read the ecodes -- note that this works only if the trial
      %  struct was made with SCALAR entries only
      data.IntraOp.saccade.FIRA.ecodes = topsDataLog.parseEcodes('trial');
   end
   
   % Get bandit data
   d = dir(fullfile(basepath, 'Intraop', '*_bandit'));
   
   % Check if data directory exists
   if ~isempty(d)
      
      % Clear the data log
      topsDataLog.theDataLog(true);
      
      % Get filename
      filename = fullfile(basepath, 'Intraop', d.name, ...
         [d.name(1:end-length('_bandit')) '_topsDataLog.mat']);
      
      % get the mainTreeNode
      mainTreeNodeStruct = topsDataLog.getTaggedData(...
         'mainTreeNode', filename);
                  
      % Save the topNode
      data.IntraOp.bandit.topNode = mainTreeNodeStruct.item;
         
      % Now read the ecodes -- note that this works only if the trial
      %  struct was made with SCALAR entries only
      data.IntraOp.bandit.FIRA.ecodes = topsDataLog.parseEcodes('trial');
   end
   
   % Get EOG data
   data.IntraOp.EOG = parseDir(struct(), fullfile(basepath, 'Intraop', 'EOG'));
end


%% Look through directory tree and find .apm files
%
% Naming convention:
%  1. <date+time>HMS2.apm     ... spike/LFP/TTL data
%  2. <date+time>HMS2LFS.apm  ... EOG data

function dataOut = parseDir(dataIn, dirname)

% Swap in/out
dataOut = dataIn;

% Check contents
d = dir(dirname);
for ii = 1:length(d)
   
   % Check entry
   if ~d(ii).isdir && ~isempty(strfind(d(ii).name, '.apm'))
      
      % Parse the data and put it in the struct
      [t, t_stim, ts] = APMParserGL5(fullfile(dirname, d(ii).name));    
      
      % Save it in the struct
      name = d(ii).name(1:end-4);
      name = ['f' name(~isspace(name) & ~(name=='-'))];
      dataOut.(name).t      = t;
      dataOut.(name).t_stim = t_stim;
      dataOut.(name).ts     = ts;

   elseif d(ii).isdir && d(ii).name(1) ~= '.'
      
      % Check sub-directory
      parseOut = parseDir(struct(), fullfile(dirname, d(ii).name));      
      
      % Update the struct
      if ~isempty(parseOut)
         name = d(ii).name;
         name = name(~isspace(name) & ~(name=='-'));
         dataOut.(name) = parseOut;
      end
   end 
end




