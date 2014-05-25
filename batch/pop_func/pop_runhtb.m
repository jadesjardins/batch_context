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

submeth_cell={'system','sshfrommatlab','none'};

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

%% HANDLE BATCH_CONFIG...
global CONTEXT_CONFIG
if isempty(CONTEXT_CONFIG);
    CONTEXT_CONFIG=contextconfig_obj;
    %PropGridStr='';
    %ubco=0;
    %ubcv='off';
end%else
PropGridStr_contextconfig=['global ccp;' ...
    'properties=contextconfig2propgrid();' ...
    'properties = properties.GetHierarchy();' ...
    'ccp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.046 .087 .912 .298]);' ...
    ];

%end

%% OBSOLETE... CONTEXT EDIT ENABLE...
%if exist('pop_context_edit');
%    c_edit_enable='on';else;c_edit_enable='off';
%end
%% OBSOLETE... HANDLE CONTEXT_CONFIG...
%global CONTEXT_CONFIG
%if isempty(CONTEXT_CONFIG);
%    c_str_swap_enable='off';else;c_str_swap_enable='on';
%end

%% POP_RUNHTB GUI...
% pop up window
% -------------
if nargin < 4
    
    results=inputgui( ...
        'geom', ...
        {...
        {8 26 [0 0] [1 1]} ... %1 blanks.
        {8 26 [0.05 -1] [1.8 1]} ... %2 history file push button
        {8 26 [2 -.92] [1.2 1]} ...
        {8 26 [3 -1.08] [1.36 1]} ...
        {8 26 [0.05 -.2] [4.3 1]} ... %3 history path edit box
        {8 26 [0.05 .6] [4.3 2.5]} ... %4 history file edit box
        {8 26 [4.7 -1] [1.8 1]} ... %5 data file push button
        {8 26 [4.22 -.2] [1 1]} ... %6 path: text
        {8 26 [4.7 -.2] [3.3 1]} ... %7 data path edit box
        {8 26 [4.32 .6] [1 1]} ... %8 file: text
        {8 26 [4.7 .6] [3.3 16]} ... %9 data file edit box
        {8 26 [0.05 3] [1.8 1]} ... %10 batch config push button
        {8 26 [0.05 16.5] [1.8 1]} ... %10 batch config push button
        
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
        {'Style','text','string','Submit method'} ...
        {'Style','popup','string',submeth_cell} ...
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

    submeth=        submeth_cell{results{1}};
    HistFPath=      results{2};
    HistFName=      results{3};
    BatchFPath=     results{4};
    BatchFName=     results{5};

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
    job_struct.batch_config=BATCH_CONFIG(hi);
    job_struct.context_config=CONTEXT_CONFIG;
    job_struct.submeth=submeth;
    job_struct.batch_dfn=BatchFName;
    job_struct.batch_dfp=BatchFPath;
    job_struct.batch_hfn=HistFName{hi};
    job_struct.batch_hfp=HistFPath;
    
    %% OBSOLETE... EMPTY HOST_NAME EXECUTION...
    %    if ~batchcfg
    %% OBSOLETE... DO "NOT" BATCH_CONFIG STUFF...
    
    %        % DO FOR EACH DATA FILE ...
    %        for i=1:length(BatchFName);
    %
    %            % on the first data file loop build the waitbar ...
    %            if i==1;
    %                WHBatch=waitbar(i/length(BatchFName), sprintf('%s%s%s%s%s','Processing file # ', num2str(i), ' of ', num2str(length(BatchFName)), '.'), ...
    %                    'Visible','off','units','normalized');
    %                WHBatch_pos=get(WHBatch,'Position');
    %                WHBatch_pos([1,2])=[.75, .75];
    %                set(WHBatch,'Position',WHBatch_pos,'visible','on');
    %                pause(0.1);
    %            else
    %            % on subsequent data file loops update the waitbar ...
    %                waitbar(i/length(BatchFName), WHBatch, sprintf('%s%s%s%s%s','Processing file # ', num2str(i), ' of ', num2str(length(BatchFName)), '.'));
    %                pause(0.01);
    %            end
    %
    %            % print the "processing file # ..." string to the comamnd line.
    %            sprintf('%s %s %s %s %s','PROCESSING FILE', num2str(i), 'OF', num2str(length(BatchFName)), 'FILES...');
    %
    %            % store the runhtb call string to the com variable ...
    %            com = sprintf('runhtb(''%s'', ''%s'', ''%s'', ''%s'');', HistFName{hi}, HistFPath, BatchFName{i}, BatchFPath);
    %
    %            % TRY EXECUTING THE RUNHTB COMMAND, OTHERWISE PRINT FAILURE MESSAGE AND CONTINUE TO NEXT DATA FILE ...
    %            try
    %                runhtb(HistFName{hi}, HistFPath, BatchFName{i}, BatchFPath);
    %            catch
    %                sprintf('%s%s%s', 'FAILURE WHILE PROCESSING FILE "', BatchFName{i}, '"... CONTINUED TO NEXT FILE."');
    %
    %            end
    %        end
    %
    %
    %    else
    %% OBSOLETE... CHECK FOR BATCH_CONFIG...
    
    %    % get the BATCH_CONFIG global structure... if absent quit...
    %    %global BATCH_CONFIG
    %    if isempty(BATCH_CONFIG);
    %        sprintf('%s','There is no BATCH_CONFIG structure in the workspace\n')
    %        sprintf('%s','Use "File > Batch > Load batch configuration file" from eeglab GUI\n')
    %        sprintf('%s','Quitting batch procedure...\n')
    %        return
    %    end
    %% OBSOLETE LOCAL EXECUTION...
    %        if strcmp(BATCH_CONFIG(hi).host_name,'local');
    %        %% DO "LOCAL" HOST_NAME EXECUTION
    %
    %            % DO LOCAL MATLAB EXECUTION
    %            if strcmp(BATCH_CONFIG(hi).software,'Matlab');
    %                %nothing yet...
    %            end
    %
    %            % DO LOCAL MATLAB PARALLEL EXECUTION ... REQUIRES PCT
    %            if strcmp(BATCH_CONFIG(hi).software,'MatlabPCT');
    %                %nothing yet...
    %
    %                %poolstr='matlabpool open';
    %                %if ~isempty(parconfig);poolstr=[poolstr,' ', parconfig];end
    %                %if ~isempty(poolsize);poolstr=[poolstr,' ', num2str(poolsize)];end
    %
    %                %if matlabpool('size') ~= 0 % checking to see if my pool is already open
    %                %    matlabpool close
    %                %end
    %                %eval(poolstr);
    %
    %                %parfor i=1:length(BatchFName);
    %                %    try
    %                %        runhtb(HistFName{hi}, HistFPath, BatchFName{i}, BatchFPath);
    %                %    catch
    %                %        sprintf('%s%s%s', 'FAILURE WHILE PROCESSING FILE "', BatchFName{i}, '"... CONTINUED TO NEXT FILE."')
    %                %    end
    %                %end
    %                %matlabpool close
    %            end
    
    
    %        else
    % DO REMOTE HOST_NAME EXECUTION ...  THIS WILL CONTAIN ALL PROCEDURES   
    %% EXEC_FUNC CALLS...
    %% BUILD THE .M FILES IN THE LOG PATH...
    job_struct=ef_gen_m(job_struct);
    
    switch BATCH_CONFIG(hi).exec_func
        case 'ef_current_base'
        %% EXECUTE HTB SCRIPTS IN CURRENT MATLAB BASE...
            job_struct=ef_current_base(job_struct);        
        case 'ef_sqsub'
        %% EXECUTE HTB SCRIPTS ON REMOTE SHARCNET CLUSTER USING SQSUB PROTOCOL...
            job_struct=ef_sqsub(job_struct);
                        
        otherwise
            %% OBSOLETE SINCE EF_* EXECUTION FUNCTIONS...
            
            
            % MATLAB OR OCTAVE EXECUTION (BUILD M FILE)...
            if strcmp(BATCH_CONFIG(hi).software,'octave')||strcmp(BATCH_CONFIG(hi).software,'matlab');
                %% OBSOLETE... DO OCTAVE EXECUTION ... REQUIRES SSHFROMMATLAB ... MUCH OF THIS MAY NOT BE SPECIFIC TO OCTAVE
                % IT IS SPECIFIC TO BUILDING M FILES FOR EXECUTION IN EITHER
                % MATLAB OR OCTAVE... THE ELSE ALTERNATIVE IF FOR EXECUTING
                % BINARIES (NO M FILE GENERATION)...
                
                % BUILD M FILE FOR EXECUTION ON HOST ..
                
                %built inital portion of the string .m file to execute on the host.
                %add dependencies path... and navigate to work_path ...
                %THIS SHOULD NOT BE SPECIFIC TO OCTAVE...
                %THIS INITIAL PORTION OF THE M FILE SHOULD PROVIDE ALL OF
                %THE INFORMATION REQUIRED BY THE CONTEXT HOST TO EXECUTE
                %THE COMMANDS...
                
                %% INITIATE BATCHINITSTR...
                batchInitStr='';
                
                %% IF DEPENDENCY PATH...
                %add dependencies path
                if ~isempty(BATCH_CONFIG(hi).dependency_path)
                    batchInitStr=sprintf('%s%s%s%s\r', batchInitStr, ...
                        'addpath(genpath(''',BATCH_CONFIG(hi).dependency_path, '''));');
                end
                
                %% IF WORK PATH...
                %cd to work path
                if ~isempty(BATCH_CONFIG(hi).work_path)
                    batchInitStr=sprintf('%s%s\r', batchInitStr, ...
                        ['cd ',BATCH_CONFIG(hi).work_path,';']);
                end
                
                %% GENERIC INIT INFORMATION FOR M FILES...
                %disable warning messages...
                batchInitStr=sprintf('%s%s\r\r',batchInitStr,'warning(''off'')');
                
                %% GET THE STRING FROM THE HTB FILES AND START BUILDING BATCHHISTSTR...
                %Create batchHistStr from the current HistFName file...
                [cPath,cRootHFName,cExt]=fileparts(HistFName{hi});
                eval(['fidRHT=fopen(''' HistFPath HistFName{hi} ''',''r'');']);
                batchHistStr=char(fread(fidRHT,'char')');
                
                %% BUILD THE DIRECTORY FOR THE TIME STAMPED M FILES IN THE
                % LOG PATH OF THE CURRENT ANALYSIS_ROOT FOLDER...
                %make directory named by history fname and date-time stamp.
                dt=clock;
                mPath=sprintf('%s_%s-%s-%s_%s-%s', ...
                    cRootHFName, ...
                    num2str(dt(1)), ...
                    num2str(dt(2)), ...
                    num2str(dt(3)), ...
                    num2str(dt(4)), ...
                    num2str(dt(5)));
                mkdir(fullfile(BATCH_CONFIG(hi).log_path,mPath));%CREATE LOG FOLDER IN log_path....
                qsubstr='';
                
                %% START LOOP THROUGH DATA FILES...
                for bfni=1:length(BatchFName);
                    %% DO FOR EACH DATA FILE ...
                    
                    %% INITIATE TMPHISTSTR...
                    tmpHistStr=batchHistStr;
                    
                    %% SWAP THE HISTORY STRING KEY STRINGS...
                    
                    tmpHistStr=batch_strswap(tmpHistStr,BATCH_CONFIG(hi), ...
                        'datafname',BatchFName{bfni}, ...
                        'datafpath',BatchFPath);
                    
                    %% OBSOLETE... HISTORY STRING SWAP...
                    %THIS SHOULD BE A SUBFUNCTION...
                    % BATCH_STRSWAP(HISTSTR,BATCH_CONFIG)...
                    %                    %perform replace_string{} swap...
                    %                    for rpi=1:length(BATCH_CONFIG(hi).replace_string);
                    %                        if ~isempty(BATCH_CONFIG(hi).replace_string{rpi});
                    %                            cs=strfind(BATCH_CONFIG(hi).replace_string{rpi},',');
                    %                            if ~isempty(cs);
                    %                                str1=strtrim(BATCH_CONFIG(hi).replace_string{rpi}(1:cs(1)-1));
                    %                                if strcmp(str1([1,end]),'[]');
                    %                                    keystr=str1;
                    %                                    swapstr=strtrim(BATCH_CONFIG(hi).replace_string{rpi}(cs(1)+1:end));
                    %                                else
                    %                                    keystr=['[replace_string{',num2str(rpi),'}]'];
                    %                                    swapstr=BATCH_CONFIG(hi).replace_string{rpi};
                    %                                end
                    %                            end
                    %                            if ~isempty(strfind(tmpHistStr,keystr));
                    %                                %if rpi>length(BATCH_CONFIG(hi).replace_string);
                    %                                %    disp('there are not enough replace_string''s defined in BATCH_CONFIG.');
                    %                                %    return
                    %                                %end
                    %                                tmpHistStr=strrep(tmpHistStr, ...
                    %                                    keystr, ...
                    %                                    swapstr);
                    %                            end
                    %                        end
                    %                    end
                    
                    %                    %swap HistStr keyPack strings...
                    %                    % batch_dfn
                    %                    tmpHistStr=key_strswap(tmpHistStr,'batch_dfn',BatchFName{bfni});
                    %                    % batch_dfp
                    %                    tmpHistStr=key_strswap(tmpHistStr,'batch_dfp',BatchFPath);
                    %                    %current_dir
                    %                    tmpHistStr=key_strswap(tmpHistStr,'current_dir',cd);
                    
                    %% FINAL STRING TO SAVE AS *.M FOR EXECUTION...
                    batchStr=sprintf('%s%s',batchInitStr,tmpHistStr);
                    
                    %% SAVE THE STRSWAPPED HISTORY STRING TO M FILE IN THE TIME STAMPED LOG PATH...
                    % save cBatchFName m file...
                    % [cRootFName_cRootHFName.m]
                    [cPath,cRootFName,cExt]=fileparts(BatchFName{bfni});
                    cMFName=[cRootFName,'_',cRootHFName,'.m'];
                    fidM=fopen(fullfile(BATCH_CONFIG(hi).log_path,mPath,cMFName),'w');%WRITE M FILE TO LOG PATH...
                    fwrite(fidM,batchStr,'char');
                    fclose(fidM);
                    
                    
                    %% OBSOLETE... SPECIFIC TO REMOTE SUBMISSION...
                    % THERE SHOULD BE SEPARATE FUNCTIONS FOR SPECIFIC CLUSTER TYPES...
                    % QSUBSTR=QSUBSTR_SHARCNET_SQSUB(BATCHFNAME,HISTFNAME,BATCHCONFIG)
                    % THIS ONE IS FOR SHARCNET SQSUB...
                    % THE INPUTS TO THE SUBMIT FUNCTIONS WILL BE
                    % BATCHFNAME, HISTFNAME, BATCH_CONFIG
                    
                    %                    qsubstr=qsubstr_sharcnet_sqsub(BATCH_CONFIG,'datafname',BatchFName{bfni},'histfname',HistFName{hi});
                    %
                    %                    %build the job name JOBNAME_STR...
                    %                    job_nameStr=BATCH_CONFIG(hi).job_name;
                    %                    %swap job_name keyPack strings...
                    %                    % batch_dfn
                    %                    job_nameStr=key_strswap(job_nameStr,'batch_dfn',BatchFName{bfni});
                    %                    % batch_hfn
                    %                    job_nameStr=key_strswap(job_nameStr,'batch_hfn',HistFName{hi});
                    %
                    %                    %build the qsubstr...
                    %                    qsubstr_tmp='sqsub';
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-r', ...
                    %                        BATCH_CONFIG(hi).run_time);
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-j', ...
                    %                        job_nameStr);
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-o', ...
                    %                        [job_nameStr,'.log']);
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-q', ...
                    %                        BATCH_CONFIG(hi).queue);
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-n', ...
                    %                        num2str(BATCH_CONFIG(hi).num_core_per_proc));
                    %                    %flag...
                    %                    if ~isempty(BATCH_CONFIG(hi).flag);
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-f', ...
                    %                            BATCH_CONFIG(hi).flag);
                    %                    end
                    %                    %threads per proc...
                    %                    if strcmp(BATCH_CONFIG(hi).queue,'threaded');
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--tpp', ...
                    %                            num2str(BATCH_CONFIG(hi).num_thread_per_proc));
                    %                    end
                    %                    %memory per proc...
                    %                    if isstr(BATCH_CONFIG(hi).memory_per_proc)
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--mpp', ...
                    %                            BATCH_CONFIG(hi).memory_per_proc);
                    %                    else
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--mpp', ...
                    %                            BATCH_CONFIG(hi).memory_per_proc{bfni});
                    %                    end
                    %
                    
                    %% THIS IS THE hi DEPENDENT PORTION THAT INTEGRATES Q* SUBS..
                    % THE QSUBSTR FUNCTIONS SHOULD OCCUR IN HERE...
                    % AND JOBIDS SHOULD BE AN OPTIONAL INPUT...
                    
                    %wait for job ID completion...
                    if ~isempty(BATCH_CONFIG.host_name)
                        if hi>1;
                            if ~isempty(jobids{bfni,hi-1})
                                %qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-w', ...
                                jobidstr=jobids{bfni,hi-1};
                            else
                                jobidstr='';
                            end
                        end
                        qsubstr=qsubstr_sharcnet_sqsub(BATCH_CONFIG, ...
                            'qsubstr',qsubstr, ...
                            'datafname',BatchFName{bfni}, ...
                            'histfname',HistFName{hi}, ...
                            'jobid',jobidstr);
                        if qsubstr=='';return;end
                    end
                    %end
                    
                    %% OBSOLETE... THIS IS THE CONTINUATION OF WHAT SHOULD BE INCLUDED IN THE QSUBSTR FUNCTION...
                    %qsubstr_tmp=sprintf('%s %s%s',qsubstr_tmp,'--mail', ...
                    %    BATCH_CONFIG.mail);
                    
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'octave',cMFName);
                    
                    %                    qsubstr=sprintf('%s%s;\n',qsubstr,qsubstr_tmp);
                    
                end
                
                %% ALL OF THE M FILE SCRIPTS HAVE BEEN WRITTEN NOW THEY CAN BE EXECUTED...
                
                if isempty(BATCH_CONFIG.host_name);
                    disp(['Begining to execute scripts in ',fullfile(BATCH_CONFIG(hi).log_path,mPath)])
                    addpath(fullfile(cd,BATCH_CONFIG(hi).log_path,mPath));
                    d=dir(fullfile(BATCH_CONFIG(hi).log_path,mPath));
                    for i=1:length(d)
                        if ~d(i).isdir;
                            disp(['Evaluating... ',d(i).name]);
                            try
                                [tmp,evalfname]=fileparts(d(i).name);
                                diary(fullfile(cd,BATCH_CONFIG(hi).log_path,mPath,[evalfname,'.log']));
                                evalin('base',evalfname);
                                diary('off');
                            catch err
                                fiderr=fopen(fullfile(cd,BATCH_CONFIG(hi).log_path,mPath,[evalfname,'.err']),'w');
                                fprintf(fiderr,err.message);
                                fclose(fiderr);
                            end
                        end
                    end
                    rmpath(fullfile(cd,BATCH_CONFIG(hi).log_path,mPath));
                    %return
                else
                    
                    %% HANDLE REMOTE Q SUBMISSION...
                    
                    %Check that Ganymed-ssh2 is in the java path... if not add it.
                    %if ~strcmp(which('ganymed-ssh2-build250/ganymed-ssh2-build250.jar'),javaclasspath)
                    %    fprintf('Adding Ganymed-ssh2 to the java path...');
                    %    javaaddpath(which('ganymed-ssh2-build250/ganymed-ssh2-build250.jar'));
                    %end
                    
                    % get username and password...  THIS IS SPECIFIC TO
                    % SSHFROMMATLAB METHOD... IT HAPPENS HERE SO THAT IT ONLY HAS
                    % TO ASK ONCE...
                    if hi==1;
                        [usrName,usrPW]=logindlg('Title',BATCH_CONFIG(hi).host_name);
                    end
                    
                    %SFTPfrommatlab m file to projPath...
                    zip([fullfile(BATCH_CONFIG(hi).log_path,mPath),'.zip'],'*.m',fullfile(BATCH_CONFIG(hi).log_path,mPath));
                    rmtpath=fullfile(BATCH_CONFIG(hi).work_path,BATCH_CONFIG(hi).log_path,[mPath,'.zip']);
                    rmtpath=strrep(rmtpath,'\','/');
                    sftpfrommatlab(usrName,BATCH_CONFIG(hi).host_name,usrPW, ...
                        fullfile(cd,fullfile(BATCH_CONFIG(hi).log_path,[mPath,'.zip'])), ...
                        rmtpath)
                    
                    %handle BATCH_CONFIG.SESSION_INIT...
                    if exist(BATCH_CONFIG(hi).session_init,'file');
                        fid_sesinit=fopen(BATCH_CONFIG(hi).session_init,'r');
                        subStrInit=fread(fid_sesinit,'char');
                        subStrInit=char(subStrInit);
                    else
                        subStrInit=BATCH_CONFIG(hi).session_init;
                    end
                    
                    subStrInit=sprintf('%s%s %s;\n%s %s;\n%s %s %s %s;\n%s %s;\n\n',subStrInit, ...
                        'cd',fullfile(BATCH_CONFIG(hi).work_path,BATCH_CONFIG(hi).log_path), ...
                        'mkdir', mPath, ...
                        'unzip', [mPath,'.zip'], '-d', mPath, ...
                        'cd', mPath);
                    
                    %Initiate the SSH connection... issue subStrInit...
                    disp([subStrInit,qsubstr]);
                    conn=sshfrommatlab(usrName,BATCH_CONFIG(hi).host_name,usrPW);
                    [conn,result]=sshfrommatlabissue(conn,[subStrInit,qsubstr]);
                    %print results to the command line...
                    disp(result)
                    
                    %collect new jobids from scheduller...
                    for bfi=1:length(BatchFName);
                        jobidstr=strtrim(result{length(result)-length(BatchFName)+bfi});
                        sinds=strfind(jobidstr,' ');
                        jobids{bfi,hi}=jobidstr(sinds(end)+1:end);
                    end
                    
                    %close ssh from matlab...
                    sshfrommatlabclose(conn);
                end
                
                %% HANDLE SOFTWARE "NONE" ... EXECUTE BINARY...
            elseif strcmp(BATCH_CONFIG(hi).software,'none');
                %% DO FOR NO SOFTWARE SPECIFIED ... RUN BINARY
                
                %batchInitStr=sprintf('%s%s\r', batchInitStr, ...
                %    ['cd ',BATCH_CONFIG(hi).work_path,';']);
                
                %Create batchHistStr from the current HistFName file...
                [cPath,cRootHFName,cExt]=fileparts(HistFName{hi});
                eval(['fidRHT=fopen(''' HistFPath HistFName{hi} ''',''r'');']);
                batchHistStr=fread(fidRHT,'char')';
                if batchHistStr(end)==10;
                    batchHistStr=char(batchHistStr(1:end-1));
                else
                    batchHistStr=char(batchHistStr);
                end
                %                %check for batch_hfn (previously HFN_root) key word in BATCH_CONFIG.job_name...
                %                job_name_HFN_Ind=[];
                %                job_name_HFN_Ind=strmatch('batch_hfn',BATCH_CONFIG(hi).job_name,'exact');
                %                if ~isempty(job_name_HFN_Ind);
                %                    tmp(hi).job_name{job_name_HFN_Ind}=cRootHFName;
                %                end
                
                qsubstr='';
                
                for bfni=1:length(BatchFName);
                    %% DO FOR EACH DATA FILE ...
                    
                    tmpHistStr=batchHistStr;
                    
                    tmpHistStr=batch_strswap(tmpHistStr,BATCH_CONFIG, ...
                        'datafname',BatchFName{bfni}, ...
                        'datafpath',BatchFPath);
                    
                    %% OBSOLETE... STRING SWAP...
                    %perform replace_string{} swap...
                    %                    for rpi=1:length(BATCH_CONFIG(hi).replace_string);
                    %                        if ~isempty(strfind(tmpHistStr,['[replace_string{',num2str(rpi),'}]']));
                    %                            if rpi>length(BATCH_CONFIG(hi).replace_string);
                    %                                disp('there are not enough replace_string''s defined in BATCH_CONFIG.');
                    %                                return
                    %                            end
                    %                            tmpHistStr=strrep(tmpHistStr, ...
                    %                                ['[replace_string{',num2str(rpi),'}]'], ...
                    %                                BATCH_CONFIG(hi).replace_string{rpi});
                    %                        end
                    %                    end
                    
                    %                    %swap HistStr keyPack strings...
                    %                    % batch_dfn
                    %                    tmpHistStr=key_strswap(tmpHistStr,'batch_dfn',BatchFName{bfni});
                    %                    % batch_dfp
                    %                    tmpHistStr=key_strswap(tmpHistStr,'batch_dfp',BatchFPath);
                    %                    %current_dir
                    %                    tmpHistStr=key_strswap(tmpHistStr,'current_dir',cd);
                    
                    %% INITIATE BATCHSTR...
                    batchStr=sprintf('%s',tmpHistStr);
                    
                    %% JOB DEPENDENCIES...
                    %wait for job ID completion...
                    if hi>1;
                        if ~isempty(jobids{bfni,hi-1})
                            %qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-w', ...
                            jobidstr=jobids{bfni,hi-1};
                        else
                            jobidstr='';
                        end
                    end
                    
                    %% FINISH QSUBSTR...
                    qsubstr=qsubstr_sharcnet_sqsub(BATCH_CONFIG, ...
                        'qsubstr',qsubstr, ...
                        'datafname',BatchFName{bfni}, ...
                        'histfname',HistFName{hi}, ...
                        'jobid',jobidstr);
                    if qsubstr=='';return;end
                    
                    %% OBSOLETE... QSUBSTR
                    %end
                    
                    %                    %build the job name JOBNAME_STR...
                    %                    job_nameStr=BATCH_CONFIG(hi).job_name;
                    %                    %swap job_name keyPack strings...
                    %                    % batch_dfn
                    %                    job_nameStr=key_strswap(job_nameStr,'batch_dfn',BatchFName{bfni});
                    %                    % batch_hfn
                    %                    job_nameStr=key_strswap(job_nameStr,'batch_hfn',HistFName{hi});
                    %
                    %
                    %                    %BATCH_CONFIG.JOB_INIT...
                    %                    if exist(BATCH_CONFIG(hi).job_init,'file');
                    %                        fid_jobinit=fopen(BATCH_CONFIG(hi).job_init,'r');
                    %                        jobStrInit=fread(fid_jobinit,'*char')';
                    %                    else
                    %                        jobStrInit=BATCH_CONFIG(hi).job_init;
                    %                    end
                    %
                    %                    %build the qsubstr...
                    %                    qsubstr_tmp=sprintf('%s%s',jobStrInit,'sqsub');
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-r', ...
                    %                        BATCH_CONFIG(hi).run_time);
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-j', ...
                    %                        job_nameStr);
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-o', ...
                    %                        [job_nameStr,'.log']);
                    %                    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-q', ...
                    %                        BATCH_CONFIG(hi).queue);
                    %                    if ~isempty(BATCH_CONFIG(hi).num_cpu_per_proc);
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-n', ...
                    %                                                        num2str(BATCH_CONFIG(hi).num_cpu_per_proc));
                    %                    end
                    %                    %flag...
                    %                    if ~isempty(BATCH_CONFIG(hi).flag);
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-f', ...
                    %                                                        BATCH_CONFIG(hi).flag);
                    %                    end
                    %                    %threads per proc...
                    %                    if ~isempty(BATCH_CONFIG(hi).num_thread_per_proc);
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--tpp', ...
                    %                                                        num2str(BATCH_CONFIG(hi).num_thread_per_proc));
                    %                    end
                    %                    %memory per proc...
                    %                    if isstr(BATCH_CONFIG(hi).memory_per_proc)
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--mpp', ...
                    %                            BATCH_CONFIG(hi).memory_per_proc);
                    %                    else
                    %                        qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--mpp', ...
                    %                            BATCH_CONFIG(hi).memory_per_proc{bfni});
                    %                    end
                    %                    %wait for job ID completion...
                    %                    if hi>1;
                    %                        if ~isempty(jobids{bfni,hi-1})
                    %                            qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-w', ...
                    %                                jobids{bfni,hi-1});
                    %                        end
                    %                    end
                    %
                    %                    %qsubstr_tmp=sprintf('%s %s%s',qsubstr_tmp,'--mail', ...
                    %                    %    BATCH_CONFIG.mail);
                    %
                    %                    qsubstr_tmp=sprintf('%s %s',qsubstr_tmp,batchStr);
                    %
                    %                    qsubstr=sprintf('%s%s\n',qsubstr,qsubstr_tmp);
                    
                end
                
                %BATCH_CONFIG.SESSION_INIT...
                if exist(BATCH_CONFIG(hi).session_init,'file');
                    fid_sesinit=fopen(BATCH_CONFIG(hi).session_init,'r');
                    subStrInit=fread(fid_sesinit,'char');
                    subStrInit=char(subStrInit);
                else
                    subStrInit=BATCH_CONFIG(hi).session_init;
                end
                
                subStrInit=sprintf('%s\n%s %s\n\n', ...
                    subStrInit, ...
                    'cd',fullfile(BATCH_CONFIG(hi).work_path,BATCH_CONFIG(hi).analysis_root));
                
                qsubstr=[subStrInit,qsubstr];
                %Initiate the SSH connection... issue subStrInit...
                disp(qsubstr);
                conn=sshfrommatlab(usrName,BATCH_CONFIG(hi).host_name,usrPW);
                [conn,result]=sshfrommatlabissue(conn,qsubstr);
                %print results to the command line...
                disp(result);
                qsubstr='';
                
                %collect new jobids from scheduller...
                for bfi=1:length(BatchFName);
                    jobidstr=strtrim(result{length(result)-length(BatchFName)+bfi});
                    sinds=strfind(jobidstr,' ');
                    jobids{bfi,hi}=jobidstr(sinds(end)+1:end);
                end
                
                %close ssh from matlab...
                sshfrommatlabclose(conn);
            end
    end    
    %% EXECUTE/SUBMIT JOBS...
    switch submeth
        case 'system'
            disp('''system'' submission is not programmed yet... doing nothing.');
        case 'sshfrommatlab'
            disp('submitting jobs using sshfrommatlab...')
            job_struct=ef_sshfm(job_struct);
        case 'none'
            disp('The job files are generated ... finished.');
    end
end
