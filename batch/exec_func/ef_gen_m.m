function job_struct=ef_gen_m(job_struct)

%% MATLAB OR OCTAVE EXECUTION (BUILD M FILE)...
if strcmp(job_struct.batch_config.software,'octave')||strcmp(job_struct.batch_config.software,'matlab');
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
    if ~isempty(job_struct.context_config.local_dependency)
        batchInitStr=sprintf('%s%s%s%s\r', batchInitStr, ...
            'addpath(genpath(''',job_struct.context_config.local_dependency, '''));');
    end
    
    %% IF WORK PATH...
    if ~isempty(job_struct.context_config.local_project)
        batchInitStr=sprintf('%s%s\r', batchInitStr, ...
            ['cd ',job_struct.context_config.local_project,';']);
    end
    
    %% GENERIC INIT INFORMATION FOR M FILES...
    %disable warning messages...
    batchInitStr=sprintf('%s%s\r\r',batchInitStr,'warning(''off'')');
    
    %% GET THE STRING FROM THE HTB FILES AND START BUILDING BATCHHISTSTR...
    %Create batchHistStr from the current HistFName file...
    [cPath,root_hfn,cExt]=fileparts(job_struct.batch_hfn);
    eval(['fidRHT=fopen(''' job_struct.batch_hfp job_struct.batch_hfn ''',''r'');']);
    batchHistStr=char(fread(fidRHT,'char')');
    
    %% BUILD THE DIRECTORY FOR THE TIME STAMPED M FILES IN THE
    % LOG PATH OF THE CURRENT ANALYSIS_ROOT FOLDER...
    %make directory named by history fname and date-time stamp.
    dt=clock;
    job_struct.m_path=sprintf('%s_%s-%s-%s_%s-%s', ...
        root_hfn, ...
        num2str(dt(1)), ...
        num2str(dt(2)), ...
        num2str(dt(3)), ...
        num2str(dt(4)), ...
        num2str(dt(5)));
    mkdir(fullfile(job_struct.context_config.log,job_struct.m_path));%CREATE LOG FOLDER IN log_path....
    qsubstr='';
    
    disp(['Generating .m files in ',fullfile(job_struct.context_config.log,job_struct.m_path),'...']);
    %% START LOOP THROUGH DATA FILES...
    for bfni=1:length(job_struct.batch_dfn);
        % DO FOR EACH DATA FILE ...        
        %% INITIATE TMPHISTSTR...
        tmpHistStr=batchHistStr;
        
        %% SWAP THE HISTORY STRING KEY STRINGS...
        
        tmpHistStr=batch_strswap(tmpHistStr,job_struct.batch_config, ...
            'datafname',job_struct.batch_dfn{bfni}, ...
            'datafpath',job_struct.batch_dfp);
        
        %% FINAL STRING TO SAVE AS *.M FOR EXECUTION...
        batchStr=sprintf('%s%s',batchInitStr,tmpHistStr);
        
        %% SAVE THE STRSWAPPED HISTORY STRING TO M FILE IN THE TIME STAMPED LOG PATH...
        % save cBatchFName m file...
        [cPath,root_dfn,cExt]=fileparts(job_struct.batch_dfn{bfni});
        c_mfn=[root_dfn,'_',root_hfn,'.m'];
        fidM=fopen(fullfile(job_struct.context_config.log,job_struct.m_path,c_mfn),'w');%WRITE M FILE TO LOG PATH...
        fwrite(fidM,batchStr,'char');
        fclose(fidM);
    end
end  

