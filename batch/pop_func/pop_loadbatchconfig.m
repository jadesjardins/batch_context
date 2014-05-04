function pop_loadbatchconfig(fname,fpath)

if nargin < 1
    
    results=inputgui( ...
        'geom', ...
        {...
        ... %{8 22 [0 0] [3 1]} ... %1
        {8 10 [0.05 0] [8 1]} ... %2
        ... %{8 22 [0.22 3] [1 1]} ... %3
        {8 10 [0.05 1] [8 1]} ... %4
        ... %{8 22 [0.32 4] [1 1]} ... %5
        {8 10 [0.05 2] [8 8]} ... %6
        ... %{8 22 [4.7 0] [3.3 1]} ... %7
        ... %{8 22 [4.22 1] [1 1]} ... %8
        ... %{8 22 [4.7 1] [3.3 1]} ... %9
        ... %{8 22 [4.32 2] [1 1]} ... %10
        ... %{8 22 [4.7 2] [3.3 20]} ... %11
        ... %{8 22 [0.05 5] [3 1]} ...%17
        }, ...
        'uilist', ...
        {...
        ... %{'Style', 'text', 'string', 'Select batching files:', 'FontWeight', 'bold'} ... %1
        {'Style', 'pushbutton', 'string', 'Batch configuration file', ...
        'callback', ...
        ['[bcfgFName, bcfgFPath] = uigetfile(''*.cfg'',''Select batch configuration file:'',''*.cfg'',''multiselect'',''on'');', ...
        'if isnumeric(bcfgFName);return;end;', ...
        'set(findobj(gcbf,''tag'',''edt_bcp''),''string'',bcfgFPath);', ...
        'set(findobj(gcbf,''tag'',''edt_bcn''),''string'',bcfgFName);']} ... %2
        ... %{'Style', 'text', 'string', 'path:'} ... %3
        {'Style', 'edit', 'tag','edt_bcp'} ... %4
        ... %{'Style', 'text', 'string', 'file:'} ... %5
        {'Style', 'edit', 'max', 500, 'tag', 'edt_bcn'}, ... %6
        ...%{'Style', 'pushbutton','string','Data files', ...
        ...%'callback', ...
        ...%['[BatchFName, BatchFPath] = uigetfile(''*.**'',''Select data files:'',''*.*'',''multiselect'',''on'');', ...
        ...%'if isnumeric(BatchFName);return;end;', ...
        ...%'set(findobj(gcbf,''tag'',''edt_dfp''),''string'',BatchFPath);', ...
        ...%'set(findobj(gcbf,''tag'',''lst_dfn''),''string'',BatchFName);']} ... %7
        ...%{'Style', 'text', 'string', 'path:'} ... %8
        ...%{'Style', 'edit', 'tag','edt_dfp'} ... %9
        ...%{'Style', 'text', 'string', 'file:'} ... %10
        ...%{'Style', 'edit', 'max', 500, 'tag', 'lst_dfn'} ... %11
        ...%{'Style', 'check', 'string', 'Use Batch configuration object','Enable',ubcv,'Value',ubco} ... %17
        }, ...
        'title', 'Select batching parameters -- pop_runhtb()' ...
        ...%'eval',PropGridStr ...
        );

    if isempty(results);return;end

    %global bcp;
    %if ~isempty(bcp);
    %    BATCH_CONFIG=propgrid2batchconfig(bcp);
    %end
    %clear global bcp
  
    fpath=    results{1};
    fname=    results{2};
    %BatchFPath=   results{3};
    %BatchFName=   results{4};
    %batchcfg=     results{5};
    
    
end;

if ~iscell(fname);
    fname={fname};
end

clear global BATCH_CONFIG
global BATCH_CONFIG

for i=1:length(fname)
    if isempty(BATCH_CONFIG);
        evalin('base',['global BATCH_CONFIG;load(''',fullfile(fpath,fname{i}),''',''-mat'');']);
    else
        tmp=load(fullfile(fpath,fname{i}),'-mat');
        BATCH_CONFIG=[BATCH_CONFIG,tmp.BATCH_CONFIG];
    end
end