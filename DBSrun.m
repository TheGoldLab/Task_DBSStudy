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
    
    case {'ors'} % OR Saccade task
        arglist = { ...
            'taskSpecs',            {'VGS' 10 'MGS' 10}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableDummy'}, ...
            'displayIndex',         -1, ... % 0=small, 1=main
            'remoteDrawing',        false, ...
            'sendTTLs',             true, ...
            };
        
    case {'orb'} % OR Bandit task
        arglist = { ...
            'taskSpecs',            {'SB' 40}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableHIDButtons'}, ...
            'displayIndex',         -1, ... % 0=small, 1=main
            'remoteDrawing',        false, ...
            'sendTTLs',             true, ...
            };
        
    case {'offices'} % Office Saccade task
        arglist = { ...
            'taskSpecs',            {'VGS' 1 'MGS' 1}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableDummy'}, ...
            'displayIndex',         -1, ... % 0=small, 1=main
            'remoteDrawing',        false, ...
            'sendTTLs',             false, ...
            };
        
    case {'officeb'} % Office Bandit task
        arglist = { ...
            'taskSpecs',            {'SB' 20}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableHIDButtons'}, ...
            'displayIndex',         -1, ... % 0=small, 1=main
            'remoteDrawing',        false, ...
            'sendTTLs',             false, ...
            };
        
    case {'debug' 'Debug'}
        arglist = { ...
            'taskSpecs',            {'VGS' 2 'SB' 1}, ...%{'VGS' 1 'MGS' 1 'SB' 2}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'readables',            {'dotsReadableDummy'}, ...
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