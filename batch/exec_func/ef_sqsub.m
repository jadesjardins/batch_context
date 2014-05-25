function job_struct=ef_sqsub(job_struct)

%% collect relevant information form CONTEXT_CONFIG and update the job_struct...
if ~isfield(job_struct,'host_name');
    ind_a=strfind(job_struct.context_config.remote_project_work,'@');
    ind_c=strfind(job_struct.context_config.remote_project_work,':');
    if ~isempty(ind_a)
        job_struct.user_name=job_struct.context_config.remote_project_work(1:ind_a(1)-1);
        job_struct.host_name=job_struct.context_config.remote_project_work(ind_a(1)+1:ind_c(1)-1);
    else
        job_struct.host_name=job_struct.context_config.remote_project_work(1:ind_c(1)-1);
    end
    job_struct.remote_work=job_struct.context_config.remote_project_work(ind_c(1)+1:end);
end
%if ~isfield(job_struct,'user_password');
%    if isfield(job_struct,'user_name');
%        job_struct.user_password=logindlg('Title',[job_struct.user_name,'@',job_struct.host_name],'Password','only');
%    else
%        [job_struct.user_name,job_struct.user_password]=logindlg('Title',job_struct.host_name);
%    end
%end
if ~isfield(job_struct,'jobids')
    job_struct.jobids='';
end

%% HANDLE SESSION_INIT...
if exist(job_struct.batch_config.session_init,'file');
    fid_sesinit=fopen(job_struct.batch_config.session_init,'r');
    subStrInit=fread(fid_sesinit,'char');
    subStrInit=char(subStrInit);
else
    subStrInit=job_struct.batch_config.session_init;
end

%% SOFTWARE SWITCH...
switch lower(job_struct.batch_config.software)
    
    case {'matlab','octave'}
        %% MATLAB OR OCTAVE EXECUTION (BUILD M FILE)...
        
        %% RUN EF_GEN_M...
        job_struct=ef_gen_m(job_struct);
        
        %% COMPLETE SUBSTRINIT...
        subStrInit=sprintf('%s%s %s;\n%s %s;\n%s %s %s %s;\n%s %s;\n\n',subStrInit, ...
            'cd',fullfile(job_struct.remote_work,job_struct.context_config.log), ...
            'mkdir',job_struct.m_path, ...
            'unzip',[job_struct.m_path,'.zip'],'-d',job_struct.m_path, ...
            'cd',job_struct.m_path);
        
        %% BUILD THE QSUBSTR...
        %wait for job ID completion...
        qsubstr='';
        for bfni=1:length(job_struct.batch_dfn)
            if ~isempty(job_struct.jobids)
                jobidstr=job_struct.jobids{bfni};
            else
                jobidstr='';
            end
            qsubstr=sqsubstr(job_struct.batch_config, ...
                'qsubstr',qsubstr, ...
                'datafname',job_struct.batch_dfn{bfni}, ...
                'histfname',job_struct.batch_hfn, ...
                'jobid',jobidstr);
        end
        
        %% SFTP FROMMATLAB M FILE TO THE REMOTE LOG...
%        zip([fullfile(job_struct.context_config.log,job_struct.m_path),'.zip'], ...
%            '*.m',fullfile(job_struct.context_config.log,job_struct.m_path));
%        job_struct.remote_log=fullfile(job_struct.remote_work, ...
%            job_struct.context_config.log, ...
%            [job_struct.m_path,'.zip']);
%        job_struct.remote_log=strrep(job_struct.remote_log,'\','/');
%        sftpfrommatlab(job_struct.user_name, ...
%            job_struct.host_name, ...
%            job_struct.user_password, ...
%            fullfile(cd,fullfile(job_struct.context_config.log, ...
%            [job_struct.m_path,'.zip'])), ...
%            job_struct.remote_log)
        
        
    case 'none'
        %% DO FOR SOFTWARE = NONE ... RUN BINARY
        
        %% COMPLETE SUBSTRINIT...
        subStrInit=sprintf('%s%s %s;\n%s %s;\n%s %s %s %s;\n%s %s;\n\n',subStrInit, ...
            'cd',fullfile(job_struct.remote_work));
        
        %% Create batchHistStr from the current HistFName file...
        [cPath,root_hfn,cExt]=fileparts(job_struct.batch_hfn);
        eval(['fidRHT=fopen(''' job_struct.batch_hfp job_struct.batch_hfn ''',''r'');']);
        batchHistStr=fread(fidRHT,'char')';
        if batchHistStr(end)==10;
            batchHistStr=char(batchHistStr(1:end-1));
        else
            batchHistStr=char(batchHistStr);
        end
        
        qsubstr='';
        for bfni=1:length(job_struct.batch_dfn);
            %% DO FOR EACH DATA FILE ...
            
            tmpHistStr=batchHistStr;
            tmpHistStr=batch_strswap(tmpHistStr,job_struct.batch_config, ...
                'datafname',job_struct.batch_dfn{bfni}, ...
                'datafpath',job_struct.batch_dfp);
            
            %% INITIATE BATCHSTR...
            exec_str=sprintf('%s',tmpHistStr);
            
            %% BUILD THE QSUBSTR...
            %wait for job ID completion...
            qsubstr='';
            for bfni=1:length(job_struct.batch_dfn)
                if ~isempty(job_struct.jobids)
                    jobidstr=job_struct.jobids{bfni};
                else
                    jobidstr='';
                end
                qsubstr=sqsubstr(job_struct.batch_config, ...
                    'qsubstr',qsubstr, ...
                    'datafname',job_struct.batch_dfn{bfni}, ...
                    'histfname',job_struct.batch_hfn, ...
                    'jobid',jobidstr, ...
                    'execstr',exec_str);
            end
        end
end

%% WRITE [SUBSTRINIT,QSUBSTR] TO A *.SUB TEXT FILE IN THE LOG PATH...
fid=fopen(fullfile(job_struct.context_config.log,job_struct.m_path,'qsub.txt'),'w');
fwrite(fid,[subStrInit,qsubstr]);

    %% OBSOLETE... HANDLE SOFTWARE "NONE" ... EXECUTE BINARY...
%elseif strcmp(batch_config(hi).software,'none');
%    %% DO FOR NO SOFTWARE SPECIFIED ... RUN BINARY
%    
%    %Create batchHistStr from the current HistFName file...
%    [cPath,root_hfn,cExt]=fileparts(job_struct.batch_hfn);
%    eval(['fidRHT=fopen(''' job_struct.batch_hfp job_struct.batch_hfn ''',''r'');']);
%    batchHistStr=fread(fidRHT,'char')';
%    if batchHistStr(end)==10;
%        batchHistStr=char(batchHistStr(1:end-1));
%    else
%        batchHistStr=char(batchHistStr);
%    end
%    
%    qsubstr='';
%    
%    for bfni=1:length(job_structbatch_dfn);
%        %% DO FOR EACH DATA FILE ...
%        
%        tmpHistStr=batchHistStr;
%        tmpHistStr=batch_strswap(tmpHistStr,job_struct.batch_config, ...
%            'datafname',job_struct.batch_dfn{bfni}, ...
%            'datafpath',job_struct.batch_dfp);
%        
%        
%        %% INITIATE BATCHSTR...
%        exec_str=sprintf('%s',tmpHistStr);
%        
%        %% BUILD THE QSUBSTR...
%        %wait for job ID completion...
%        qsubstr='';
%        for bfni=1:length(job_struct.batch_dfn)
%            if ~isempty(job_struct.jobids)
%                jobidstr=job_struct.jobids{bfni};
%            else
%                jobidstr='';
%            end
%            qsubstr=sqsubstr(job_struct.batch_config, ...
%                'qsubstr',qsubstr, ...
%                'datafname',job_struct.batch_dfn{bfni}, ...
%                'histfname',job_struct.batch_hfn, ...
%                'jobid',jobidstr, ...
%                'execstr',exec_str);
%        end
%        
%        %% JOB DEPENDENCIES...
%        %wait for job ID completion...
%        if hi>1;
%            if ~isempty(jobids{bfni,hi-1})
%                %qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-w', ...
%                jobidstr=jobids{bfni,hi-1};
%            else
%                jobidstr='';
%            end
%        end
%        
%        %% FINISH QSUBSTR...
%        qsubstr=qsubstr_sharcnet_sqsub(batch_config, ...
%            'qsubstr',qsubstr, ...
%            'datafname',BatchFName{bfni}, ...
%            'histfname',HistFName{hi}, ...
%            'jobid',jobidstr);
%        if qsubstr=='';return;end
        
%        %% OBSOLETE... QSUBSTR
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
        
%    end
%    
%    %batch_config.SESSION_INIT...
%    if exist(batch_config(hi).session_init,'file');
%        fid_sesinit=fopen(batch_config(hi).session_init,'r');
%        subStrInit=fread(fid_sesinit,'char');
%        subStrInit=char(subStrInit);
%    else
%        subStrInit=batch_config(hi).session_init;
%    end
%    
%    subStrInit=sprintf('%s\n%s %s\n\n', ...
%        subStrInit, ...
%        'cd',fullfile(batch_config(hi).work_path,batch_config(hi).analysis_root));
%    
%    qsubstr=[subStrInit,qsubstr];
%    %Initiate the SSH connection... issue subStrInit...
%    disp(qsubstr);
%    conn=sshfrommatlab(usrName,batch_config.host_name,usrPW);
%    [conn,result]=sshfrommatlabissue(conn,qsubstr);
%    %print results to the command line...
%    disp(result);
%    qsubstr='';
%    
%    %collect new jobids from scheduller...
%    for bfi=1:length(BatchFName);
%        jobidstr=strtrim(result{length(result)-length(BatchFName)+bfi});
%        sinds=strfind(jobidstr,' ');
%        jobids{bfi,hi}=jobidstr(sinds(end)+1:end);
%    end
%    
%    %close ssh from matlab...
%    sshfrommatlabclose(conn);
%end

%end