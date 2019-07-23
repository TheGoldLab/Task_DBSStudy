function topNode = DBSrun(location, varargin)
%% function [mainTreeNode, datatub] = DBSrun(location, varargin)
%
% DBSrun = Response-Time Dots
%
% This function configures, initializes, runs, and cleans up a DBS
%  experiment (OR or office)
%
% Arguments:
%  location    ... string name, listed below
%  varargin    ... property/value pairs, as in arglists below
%
% 11/17/18   jig wrote it

%% ---- Clear globals
%
% umm, duh
clear globals

%% ---- Configure experiment based on location
%
% UIs:
%  'dotsReadableDummy'
%  'dotsReadableEyeEyelink'
%  'dotsReadableEyePupilLabs'
%  'dotsReadableEyeEOG'
%  'dotsReadableHIDKeyboard'
%  'dotsReadableEyeMouseSimulator'
%  'dotsReadableHIDButtons'
%  'dotsReadableHIDGamepad'

if nargin < 1 || isempty(location)
    location = 'OR';
end

switch location
    
    case {'calibrate' 'Calibrate'}
        arglist = { ...
            'taskSpecs',            {'VGS' 1}, ...
            'readables',            {'dotsReadableEyePupilLabs'}, ...
            'displayIndex',         0, ... % 0=small, 1=main
            'remoteDrawing',        false, ...
            'sendTTLs',             false, ...
            'showEye',              true, ...
            };
        
    case {'ors'} % OR Saccade task
        arglist = { ...
            'taskSpecs',            {'VGS' 10 'MGS' 10}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableDummy'}, ...
            'displayIndex',         1, ... % 0=small, 1=main
            'remoteDrawing',        true, ...
            'sendTTLs',             true, ...
            };
        
    case {'orb'} % OR Bandit task
        arglist = { ...
            'taskSpecs',            {'SB' 10}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableHIDKeyboard'}, ...
            'displayIndex',         0, ... % 0=small, 1=main
            'remoteDrawing',        false, ...
            'sendTTLs',             false, ...
            };
        
    case {'or' 'OR'}
        arglist = { ...
            'taskSpecs',            {'VGS' 5 'MGS' 5 'Quest' 40 'SN' 40 'AN' 40}, ...
            'readables',            {'dotsReadableEyeEOG'}, ...
            };
        
    case {'orh' 'ORH'}
        arglist = { ...
            'taskSpecs',            {'VGS' 5 'MGS' 5 'Quest' 40 'SN' 40 'AN' 40}, ...
            'readables',            {'dotsReadableEyeEOG'}, ...
            'saccadeDirections',    [0 180], ...
            };
        
    case {'orSaccades' 'ORSACCADES'}
        arglist = { ...
            'taskSpecs',            {'VGS' 5 'MGS' 5 'VGS' 5 'MGS' 5 'VGS' 5 'MGS' 5}, ...
            'readables',            {'dotsReadableEyeEOG'}, ...
            };
        
    case {'orSacDemo' 'ORSACDEMO'}
        arglist = { ...
            'taskSpecs',            {'VGS' 5 'MGS' 5 'VGS' 5 'MGS' 5 'VGS' 5 'MGS' 5 'VGS' 5 'MGS' 5}, ...
            'readables',            {'dotsReadableDummy'}, ...
            'doCalibration',        false, ...
            };
        
    case {'buttons' 'Buttons'}  % Or using buttons
        arglist = { ...
            'taskSpecs',            {'Quest' 40 'SN' 40 'AN' 40}, ...
            'readables',            {'dotsReadableHIDButtons'}, ...
            };
        
    case {'debug' 'Debug'}
        arglist = { ...
            'taskSpecs',            {'VGS' 2 'SB' 1}, ...%{'VGS' 1 'MGS' 1 'SB' 2}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableHIDKeyboard'}, ...
            'displayIndex',         -1, ... % -1=none, 0=small, 1=main
            'remoteDrawing',        false, ...
            'sendTTLs',             false, ...
            };
        
    otherwise % office
        arglist = { ...
            'taskSpecs',            {'VGS' 5 'MGS' 5 'Quest' 40 'SN' 25 'AN' 25}, ...
            'readables',            {'dotsReadableEyePupilLabs'}, ...
            'remoteDrawing',        true, ...
            };
end

%% ---- Call the configuration routine
%
topNode = DBSconfigure(arglist{:});

%% ---- Run it!
%
topNode.run();