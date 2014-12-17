function job_struct=ef_sqsub(job_struct)

%% collect relevant information form CONTEXT_CONFIG and update the job_struct...
ind_a=strfind(job_struct.context_config.remote_project_work,'@');
ind_c=strfind(job_struct.context_config.remote_project_work,':');

if ~isfield(job_struct.context_config,'remote_exec_host');
    disp('remote_exec_host is empty, retrieving execution host name from [remote_project_work]...');
    job_struct.context_config.remote_exec_host=job_struct.context_config.remote_project_work(ind_a(1)+1:ind_c(1)-1);
end

job_struct.user_name=job_struct.context_config.remote_project_work(1:ind_a(1)-1);
job_struct.work_host_name=job_struct.context_config.remote_project_work(1:ind_c(1)-1);
job_struct.remote_work=job_struct.context_config.remote_project_work(ind_c(1)+1:end);

if ~isfield(job_struct,'jobids')
    job_struct.jobids='';
end

%% INITIATE subStrInit...
subStrInit=sprintf('%s\n\n', ...
    '#!/bin/bash');

%% HANDLE SESSION_INIT...
if exist(job_struct.batch_config.session_init,'file');
    fid_sesinit=fopen(job_struct.batch_config.session_init,'r');
    tmp_subStrInit=fread(fid_sesinit,'char');
    tmp_subStrInit=char(tmp_subStrInit);
else
    tmp_subStrInit=job_struct.batch_config.session_init;
end

subStrInit=sprintf('%s\n\n', ...
    tmp_subStrInit);

%% SOFTWARE SWITCH...
%switch lower(job_struct.batch_config.software)
    
%    case {'matlab','octave'}
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
                'execpath',fullfile(job_struct.context_config.log,job_struct.m_path));
        end
                        
%    case 'none'
%        %% DO FOR SOFTWARE = NONE ... RUN BINARY
%        
%        %% COMPLETE SUBSTRINIT...
%        subStrInit=sprintf('%s%s %s;\n%s %s;\n%s %s %s %s;\n%s %s;\n\n',subStrInit, ...
%            'cd',fullfile(job_struct.remote_work));
%        
%        %% Create batchHistStr from the current HistFName file...
%        [cPath,root_hfn,cExt]=fileparts(job_struct.batch_hfn);
%        eval(['fidRHT=fopen(''' job_struct.batch_hfp job_struct.batch_hfn ''',''r'');']);
%        batchHistStr=fread(fidRHT,'char')';
%        if batchHistStr(end)==10;
%            batchHistStr=char(batchHistStr(1:end-1));
%        else
%            batchHistStr=char(batchHistStr);
%        end
%        
%        qsubstr='';
%        for bfni=1:length(job_struct.batch_dfn);
%            %% DO FOR EACH DATA FILE ...
%            
%            tmpHistStr=batchHistStr;
%            tmpHistStr=batch_strswap(tmpHistStr,job_struct.batch_config, ...
%                'datafname',job_struct.batch_dfn{bfni}, ...
%                'datafpath',job_struct.batch_dfp);
%            
%            %% INITIATE BATCHSTR...
%            exec_str=sprintf('%s',tmpHistStr);
%            
%            %% BUILD THE QSUBSTR...
%            %wait for job ID completion...
%            qsubstr='';
%            for bfni=1:length(job_struct.batch_dfn)
%                if ~isempty(job_struct.jobids)
%                    jobidstr=job_struct.jobids{bfni};
%                else
%                    jobidstr='';
%                end
%                qsubstr=sqsubstr(job_struct.batch_config, ...
%                    'qsubstr',qsubstr, ...
%                    'datafname',job_struct.batch_dfn{bfni}, ...
%                    'histfname',job_struct.batch_hfn, ...
%                    'jobid',jobidstr, ...
%                    'execstr',exec_str);
%            end
%        end
%end

%% WRITE [SUBSTRINIT,QSUBSTR] TO A *.SUB TEXT FILE IN THE LOG PATH...
fid=fopen(fullfile(job_struct.context_config.log,job_struct.m_path,'submit.sh'),'w');
fwrite(fid,[subStrInit,qsubstr]);


function qsubstr=sqsubstr(batch_config,varargin)

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('sqsubstr() error: calling convention {''key'', value, ... } error'); return;
end;

%% data options...
try g.qsubstr;   catch, g.qsubstr  ='';end
try g.datafname; catch, g.datafname='';end
try g.histfname; catch, g.histfname='';end
try g.jobid;     catch, g.jobid    ='';end
try g.execstr;   catch, g.execstr  ='';end
try g.execpath;  catch, g.execpath ='';end


%% BUILD THE QSUBSTR
%build the job name JOBNAME_STR...
job_nameStr=batch_config.job_name;
%swap job_name keyPack strings...
% batch_dfn
job_nameStr=key_strswap(job_nameStr,'batch_dfn',g.datafname);
% batch_hfn
job_nameStr=key_strswap(job_nameStr,'batch_hfn',g.histfname);

%% BATCH_CONFIG.JOB_INIT...
if exist(batch_config.job_init,'file');
    fid_jobinit=fopen(batch_config.job_init,'r');
    jobStrInit=fread(fid_jobinit,'*char')';
else
    jobStrInit=batch_config.job_init;
end

%% build the qsubstr...
qsubstr_tmp=sprintf('%s%s',jobStrInit,'sqsub');

qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-r', ...
    batch_config.run_time);
qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-j', ...
    job_nameStr);
qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-o', ...
    [g.execpath,'/',job_nameStr,'.log']);
qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-q', ...
    batch_config.queue);
if ~isempty(batch_config.num_cores);
    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-n', ...
    num2str(batch_config.num_cores));
end
if ~isempty(batch_config.num_nodes);
    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-N', ...
    num2str(batch_config.num_nodes));
end
%threads per proc...
if strcmp(batch_config.queue,'threaded');
    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--tpp', ...
        num2str(batch_config.num_thread_per_proc));
end
%memory per proc...
if ischar(batch_config.memory_per_proc)
    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--mpp', ...
        batch_config.memory_per_proc);
else
    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'--mpp', ...
        batch_config.memory_per_proc{bfni});
end
%jobid wait...
if ~isempty(g.jobid);
    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-w', ...
        g.jobid);
end
%qsub_options...
if ~isempty(batch_config.qsub_options);
    for i=1:length(batch_config.qsub_options);
        qsubstr_tmp=sprintf('%s %s',qsubstr_tmp,batch_config.qsub_options{i});
    end
end
%program_options...
program_options='';
if ~isempty(batch_config.program_options);
    for i=1:length(batch_config.program_options);
        program_options=sprintf('%s %s',program_options,batch_config.program_options{i});
    end
end
%software...
if strcmp(batch_config.software,'none')
    qsubstr_tmp=sprintf('%s %s',qsubstr_tmp,g.execstr);    
else
    [cPath,root_hfn,cExt]=fileparts(g.histfname);
    [cPath,root_dfn,cExt]=fileparts(g.datafname);
    c_mfn=[root_hfn,'_',root_dfn,'.m'];
    qsubstr_tmp=sprintf('%s %s %s %s/%s',qsubstr_tmp,batch_config.software,program_options,g.execpath,c_mfn);
end

qsubstr=sprintf('%s%s;\n',g.qsubstr,qsubstr_tmp);

