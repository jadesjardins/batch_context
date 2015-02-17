% pop_runhtb() - Run history template on multiple data files.
% See runhtb for more details.
%
% Usage:
%   >>  com = pop_runhtb(execmeth,HistFName,HistFPath,BatchFName,BatchFPat);
%
% Inputs:
%   execmeth     - Execution method. "serial" = run batch serial mode using
%                  for loop, "parallel" = run batch in parallel mode using
%                  parfor loop (requires Matlab PCT).
%   HistFName    - Name of history template file.
%   HistFPath    - Path of history template file.
%   BatchFName   - Name of batch files.
%   BatchFPath   - Path of batch files
%    
% Outputs:
%   com             - Current command.
%
% See also:
%   savehtb 
%

% Copyright (C) <2006>  <James Desjardins>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_runhtb.m edit history...
%

function com = pop_runhtb(HistFName, HistFPath, BatchFName, BatchFPath)

com = ''; % this initialization ensure that the function will return something
% if the user press the cancel button

rsub_meth_cell={'system','sshfrommatlab','none'};

%% HANDLE BATCH_CONFIG...
global BATCH_CONFIG
if isempty(BATCH_CONFIG);
    BATCH_CONFIG=batchconfig_obj;
    %PropGridStr='';
    %ubco=0;
    %ubcv='off';
end%else
ubco=1;
ubcv='on';
PropGridStr_batchconfig=['global bcp;' ...
    'properties=batchconfig2propgrid();' ...
    'properties = properties.GetHierarchy();' ...
    'bcp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.046 .42 .48 .395]);' ...
    ];

%% HANDLE CONTEXT_CONFIG...
global CONTEXT_CONFIG
if isempty(CONTEXT_CONFIG);
    CONTEXT_CONFIG=contextconfig_obj;
    %PropGridStr='';
    %ubco=0;
    %ubcv='off';
end
PropGridStr_contextconfig=['global ccp;' ...
    'properties=contextconfig2propgrid();' ...
    'properties = properties.GetHierarchy();' ...
    'ccp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.046 .087 .912 .298]);' ...
    ];

%% POP_RUNHTB GUI...
% pop up window
% -------------
if nargin < 4
    
    results=inputgui( ...
        'geom', ...
        {...
        {8 26 [0 0] [1 1]} ... %1 blanks.
        {8 26 [0.05 -1] [1.8 1]} ... %2 history file push button
        {8 26 [0.05 -.2] [4.3 1]} ... %3 history path edit box
        {8 26 [0.05 .6] [4.3 2.5]} ... %4 history file edit box
        {8 26 [4.7 -1] [1.8 1]} ... %5 data file push button
        {8 26 [4.22 -.2] [1 1]} ... %6 path: text
        {8 26 [4.7 -.2] [3.3 1]} ... %7 data path edit box
        {8 26 [4.32 .6] [1 1]} ... %8 file: text
        {8 26 [4.7 .6] [3.3 16]} ... %9 data file edit box
        {8 26 [0.05 3] [1.8 1]} ... %10 batch config push button
        {8 26 [0.05 16.5] [1.8 1]} ... %11 batch config push button
        {8 26 [0.05 27.3] [2 1]} ...
        {8 26 [1.8 26.9] [1.36 1]} ...
        
        }, ...
        'uilist', ...
        {...
        {'Style', 'text', 'string',blanks(16)} ... %1 This is just for a blank string of a given length to set the width of the GUI.
        {'Style', 'pushbutton', 'string', 'History file', ...
        'callback', ...
        ['[HistFName, HistFPath] = uigetfile(''*.htb'',''Select History Template Batch file:'',''*.htb'',''multiselect'',''on'');', ...
        'if isnumeric(HistFName);return;end;', ...
        'set(findobj(gcbf,''tag'',''edt_hfp''),''string'',HistFPath);', ...
        'set(findobj(gcbf,''tag'',''edt_hfn''),''string'',HistFName);']} ... %2 history file push button
        {'Style', 'edit', 'tag','edt_hfp'} ... %3 history path edit box
        {'Style', 'edit', 'max', 500, 'tag', 'edt_hfn'} ... %4 history file edit box
        {'Style', 'pushbutton','string','Data files', ...
        'callback', ...
        ['[BatchFName, BatchFPath] = uigetfile(''*.**'',''Select data files:'',''*.*'',''multiselect'',''on'');', ...
        'if isnumeric(BatchFName);return;end;', ...
        'set(findobj(gcbf,''tag'',''edt_dfp''),''string'',BatchFPath);', ...
        'set(findobj(gcbf,''tag'',''lst_dfn''),''string'',BatchFName);']} ... %5 data file push button
        {'Style', 'text', 'string', 'path:'} ... %6 path: text
        {'Style', 'edit', 'tag','edt_dfp'} ... %7 data path edit box
        {'Style', 'text', 'string', 'file:'} ... %8 file: text
        {'Style', 'edit', 'max', 500, 'tag', 'lst_dfn'} ... %9 data file edit box
        {'Style', 'pushbutton','string','Load batch config', ...
        'callback', ...
        ['pop_loadbatchconfig();', ...
        'global bcp;' ...
        'properties=batchconfig2propgrid();' ...
        'properties = properties.GetHierarchy();' ...
        'bcp = PropertyGrid(gcf,' ...
        '''Properties'', properties,' ...
        '''Position'', [.046 .42 .48 .395]);']} ... %10 batch config push button
        {'Style', 'pushbutton','string','Load context config', ...
        'callback', ...
        ['[configFName, configFPath] = uigetfile(''*.cfg'',''Select Context configuration file:'',''*.cfg'',''multiselect'',''off'');', ...
        'if isnumeric(configFName);return;end;', ...
        'evalin(''base'',[''global CONTEXT_CONFIG;load(fullfile(configFPath,configFName),''''-mat'''');'']);', ...
        'global ccp;' ...
        'properties=contextconfig2propgrid();' ...
        'properties = properties.GetHierarchy();' ...
        'ccp = PropertyGrid(gcf,' ...
        '''Properties'', properties,' ...
        '''Position'', [.046 .087 .912 .298]);']} ... %11 context config push button
        {'Style','text','string','Remote submit communication method'} ...
        {'Style','popup','string',rsub_meth_cell} ...
        }, ...
        'title', 'Select batching parameters -- pop_runhtb()', ...
        'eval',[PropGridStr_batchconfig PropGridStr_contextconfig] ...
        );

    if isempty(results);return;end

    global bcp;
    BATCH_CONFIG=propgrid2batchconfig(bcp);
    clear global bcp
  
    global ccp;
    CONTEXT_CONFIG=propgrid2contextconfig(ccp);
    clear global ccp

    
    HistFPath=      results{1};
    HistFName=      results{2};
    BatchFPath=     results{3};
    BatchFName=     results{4};
    rsub_meth=      rsub_meth_cell{results{5}};

end;

%% HANDLE REQUIRED INPUTS...
% check that required files have been specified...
if isempty(HistFName);
    disp('No history template files have been specified');
    disp('Quitting batch procedure...');
    return
end
if isempty(BatchFName);
    disp('No input data files have been specified');
    disp('Quitting batch procedure...');
    return
end

% if a single history file is chosen convert the HistFName string into a cell array...
if ischar(HistFName)
    HistFName=cellstr(HistFName);
end

% if a single input data file is chosen convert the BatchFName string into a cell array...
if ischar(BatchFName)
    BatchFName=cellstr(BatchFName);
end


%% START BATCHING PROCEDURE...
for hi=1:length(HistFName)
    %% DO FOR EACH HISTORY FILES FILE...
    order_inds=[1,1];
    for oi=1:length(BATCH_CONFIG(hi).order);
        order_inds(oi)=BATCH_CONFIG(hi).order(oi);
    end
    job_struct(order_inds(1),order_inds(2)).batch_config=BATCH_CONFIG(hi);
    job_struct(order_inds(1),order_inds(2)).context_config=CONTEXT_CONFIG;
    job_struct(order_inds(1),order_inds(2)).submeth=rsub_meth;
    job_struct(order_inds(1),order_inds(2)).batch_dfn=BatchFName;
    job_struct(order_inds(1),order_inds(2)).batch_dfp=BatchFPath;
    job_struct(order_inds(1),order_inds(2)).batch_hfn=HistFName{hi};
    job_struct(order_inds(1),order_inds(2)).batch_hfp=HistFPath;
    job_struct(order_inds(1),order_inds(2)).m_path='';
    
    %% BUILD THE .M FILES IN THE LOG PATH...
    if any(~strcmp(BATCH_CONFIG(hi).software,{'octave','matlab'})); 
        job_struct(order_inds(1),order_inds(2))=ef_gen_m(job_struct(order_inds(1),order_inds(2)));
    end
    
    switch BATCH_CONFIG(hi).exec_func
        case 'ef_current_base'
        %% EXECUTE HTB SCRIPTS IN CURRENT MATLAB BASE...
            job_struct=ef_current_base(job_struct,[order_inds(1),order_inds(2)]);        
        case 'ef_sqsub'
        %% EXECUTE HTB SCRIPTS ON REMOTE SHARCNET CLUSTER USING SQSUB PROTOCOL...
            job_struct=ef_sqsub(job_struct,[order_inds(1),order_inds(2)]);
                        
        otherwise
            disp('invalid execution function... doing nothing.');
    end    
    %% EXECUTE/SUBMIT JOBS...
    if ~strcmp(BATCH_CONFIG(hi).exec_func,'ef_current_base');
        switch rsub_meth
            case 'system'
                %disp('''system'' submission is not programmed yet... doing nothing.');
                job_struct=rsub_sys(job_struct,[order_inds(1),order_inds(2)]);
            case 'sshfrommatlab'
                disp('submitting jobs using sshfrommatlab...')
                job_struct=conn_sshfm(job_struct,[order_inds(1),order_inds(2)]);
            case 'none'
                disp('The job files are generated ... finished.');
        end
    end
end
