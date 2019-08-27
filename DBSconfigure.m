function topNode =  DBSconfigure(varargin)
%% function topNode =  DBSconfigure(varargin)
%
% This function sets up a DBS experiment. We keep this logic separate from
% running and cleaning up an experiment because we may want to decide
% when/how do do those other things on the fly (e.g., add/subtract tasks
% depending on the subject's motivation, etc).
%
% Arguments:
%  varargin  ... optional <property>, <value> pairs for settings variables
%                 note that <property> can be a cell array for nested
%                 property structures in the task object
%
% Returns:
%  mainTreeNode ... the topsTreeNode at the top of the hierarchy
%
% 11/17/18   jig wrote it

%% ---- Parse arguments for configuration settings
%
% Name of the experiment, which determines where data are are stored
name = 'DBSStudy';

% Other defaults
settings = { ...
   'taskSpecs',                  {'VGS' 1 'MGS' 1}, ... %'NN' 1 'Quest' 1 'AN' 1 'SN' 1 'NL' 1 'NR' 1}, ...
   'runGUIname',                 'eyeGUI', ...
   'databaseGUIname',            [], ...
   'remoteDrawing',              true, ...
   'instructionDuration',        10.0, ...
   'speakInstructions',          true, ...
   'displayIndex',               1, ... % 0=small, 1=main
   'readables',                  {'dotsReadableHIDKeyboard'}, ...
   'doRecording',                true, ...
   'doCalibration',              true, ...
   'showEye',                    false, ...
   'queryDuringCalibration',     false, ...
   'sendTTLs',                   true, ...
   'targetDistance',             10, ...
   'gazeWindowSize',             6, ...
   'gazeWindowDuration',         0.15, ...
   'saccadeDirections',          0:90:270, ...
   'dotDirections',              [0 180], ...
   'referenceRT',                500, ...   % for speed feedback
   'showFeedback',               true, ...  % for graphical feedback
   };

% Update from argument list (property/value pairs)
for ii = 1:2:nargin
   settings{find(strcmp(varargin{ii}, settings),1) + 1} = varargin{ii+1};
end

%% ---- Create topsTreeNodeTopNode to control the experiment
%
% Make the topsTreeNodeTopNode
topNode = topsTreeNodeTopNode(name);

% Add a topsGroupedList as the nodeData, which here just stores the
% property/value "settings" we use to control task behaviors
topNode.nodeData = topsGroupedList.createGroupFromList('Settings', settings);

% Add GUIS. The first is the "run gui" that has some buttons to start/stop
% running and some real-time output of eye position. The "database gui" is
% a series of dialogs that execute at the beginning to collect subject/task
% information and store it in a standard format.
topNode.addGUIs(  ...
   'run',               topNode.nodeData{'Settings'}{'runGUIname'}, ...
   'database',          topNode.nodeData{'Settings'}{'databaseGUIname'});

% Add the screen ensemble as a "helper" object. See
% topsTaskHelperScreenEnsemble for details
if topNode.nodeData{'Settings'}{'displayIndex'} >= 0
   topNode.addHelpers('screenEnsemble',  ...
      'displayIndex',   topNode.nodeData{'Settings'}{'displayIndex'}, ...
      'remoteDrawing',  topNode.nodeData{'Settings'}{'remoteDrawing'}, ...
      'topNode',        topNode);
end

% Add readable(s). See topsTaskHelperReadable for details.
readables = topNode.nodeData{'Settings'}{'readables'};
for ii = 1:length(readables)
   theHelper = topNode.addReadable(readables{ii}, ...
      'doRecording',    topNode.nodeData{'Settings'}{'doRecording'}, ...
      'doCalibration',  topNode.nodeData{'Settings'}{'doCalibration'}, ...
      'doShow',         topNode.nodeData{'Settings'}{'showEye'});
   
   % For readableEye objects, set default gaze window size and duration
   theHelper.(readables{ii}).setGazeParameters( ...
      topNode.nodeData{'Settings'}{'gazeWindowSize'}, ...
      topNode.nodeData{'Settings'}{'gazeWindowDuration'});
end

% Add writable (TTL out). See topsTaskHelperTTL for details.
if topNode.nodeData{'Settings'}{'sendTTLs'}
   topNode.addHelpers('TTL');
end

%% ---- Make call lists to show text/images between tasks
%
%  Use the message helper class
topNode.addHelpers('message', 'name', 'topNodeMessages');

% Welcome call list
paceStr = 'Work at your own pace.';
strs = { ...
   'dotsReadableEye',         paceStr, 'Each trial starts by fixating the central cross.'; ...
   'dotsReadableHIDGamepad',  paceStr, 'Each trial starts by pulling either trigger.'; ...
   'dotsReadableHIDButtons',  paceStr, 'Each trial starts by pushing either button.'; ...
   'dotsReadableHIDKeyboard', paceStr, 'Each trial starts by pressing the space bar.'; ...
   'default',                 'Each trial starts automatically.', ' '};
for index = 1:size(strs,1)
   if ~isempty(topNode.getHelperByClassName(strs{index,1}))
      break;
   end 
end
topNode.helpers.topNodeMessages.addGroup('Welcome', ...
   'text',           strs(index, 2:3), ...
   'speakText',      topNode.nodeData{'Settings'}{'speakInstructions'}, ...
   'duration',       topNode.nodeData{'Settings'}{'instructionDuration'}, ...
   'pauseDuration',	0.5);
welcomeFevalable = {@show, topNode.helpers.topNodeMessages, 'Welcome'};

% Countdown call list
% callStrings = sprintfc('Next task starts in: %d', (10:-1:0)');
topNode.helpers.topNodeMessages.addGroup('Countdown', ...
   'text',           {'Starting next task...', 'y', -6}, ...
   'speakText',      topNode.nodeData{'Settings'}{'speakInstructions'}, ...
   'drawables',      {{@dotsDrawableImages, 'fileNames', 'greatJob.jpg', 'y', 3, 'height', 13}}, ...
   'duration',       2.0, ...
   'pauseDuration',  0.5);
countdownFevalable = {@show, topNode.helpers.topNodeMessages, 'Countdown'};
% countdownFevalable = {@showTexts, topNode.helpers.topNodeMessages, 'Countdown', callStrings};

%% ---- Loop through the task specs array, making tasks with appropriate arg lists
%
taskSpecs = topNode.nodeData{'Settings'}{'taskSpecs'};
QuestTask = [];
noDots    = true;
for ii = 1:2:length(taskSpecs)
   
   % Make list of properties to send
   args = {taskSpecs{ii},                 ...
      'trialIterations',               taskSpecs{ii+1}, ...
      {'message', 'groups', 'Instructions', 'duration'},  topNode.nodeData{'Settings'}{'instructionDuration'}, ...      
      {'message', 'groups', 'Instructions', 'speakText'}, topNode.nodeData{'Settings'}{'speakInstructions'}, ...      
      {'settings', 'targetDistance'},  topNode.nodeData{'Settings'}{'targetDistance'}, ...
      'taskID',                        (ii+1)/2, ...
      'taskTypeID',                    find(strcmp(taskSpecs{ii}, ...
      {'VGS' 'MGS' 'Quest' 'NN' 'NL' 'NR' 'SN' 'SL' 'SR' 'AN' 'AL' 'AR' 'SB'}),1)};
   
   switch taskSpecs{ii}
      
      case {'VGS' 'MGS'}
         
         % SACCADE TASK -- use all args
         % possibly min RT for dummy
         if strcmp(readables{1}, 'dotsReadableDummy')
            args = cat(2, args, {{'timing', 'minimumRT'}, 0.4});
         end
         task = topsTreeNodeTaskSaccade.getStandardConfiguration(args{:}, ...
            {'task', 'independentVariables', 'direction', 'value'}, ...
            topNode.nodeData{'Settings'}{'saccadeDirections'});
         
      case {'SB'}
         
         % SIMPLE BANDIT TASK
         task = topsTreeNodeTaskSimpleBandit.getStandardConfiguration(args{:});
         
         % Update instructions
         topNode.helpers.topNodeMessages.setText('Welcome', ...
             {'Each trial starts automatically.', ' '});

       otherwise
         
         % DOTS TASK
         % If there was a Quest task, use to update coherences in other tasks
         if ~isempty(QuestTask)
            args = cat(2, args, ...
               {{'settings' 'useQuest'},   QuestTask, ...
               {'settings' 'referenceRT'}, QuestTask});
         end
         
         % Make RTDots task with args
         task = topsTreeNodeTaskRTDots.getStandardConfiguration(args{:}, ...
         {'task', 'independentVariables', 'direction', 'value'}, ...
            topNode.nodeData{'Settings'}{'dotDirections'});

         % Add special instructions for first dots task
         if noDots
            task.settings.textStrings = cat(1, ...
               {'When flickering dots appear, decide their overall direction', ...
               'of motion, then look at the target in that direction'}, ...
               task.settings.textStrings);
            noDots = false;
         end
         
         % Special case of quest ... use output as coh/RT refs
         if strcmp(taskSpecs{ii}, 'Quest')
            QuestTask = task;
         end
   end
  
   % Add some fevalables to show instructions/feedback before/after tasks
   if ii == 1
      task.addCall('start', welcomeFevalable);
   else
      task.addCall('start', countdownFevalable);
   end
   
   % Add as child to the topsTreeNode.
   topNode.addChild(task);
end
