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
qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-n', ...
    num2str(batch_config.num_nodes));
%flag...
if ~isempty(batch_config.flag);
    qsubstr_tmp=sprintf('%s %s %s',qsubstr_tmp,'-f', ...
        batch_config.flag);
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
%software...
if strcmp(batch_config.software,'none')
    qsubstr_tmp=sprintf('%s %s',qsubstr_tmp,g.execstr);    
else
    [cPath,root_hfn,cExt]=fileparts(g.histfname);
    [cPath,root_dfn,cExt]=fileparts(g.datafname);
    c_mfn=[root_hfn,'_',root_dfn,'.m'];
    qsubstr_tmp=sprintf('%s %s %s/%s',qsubstr_tmp,batch_config.software,batch_config.program_options,g.execpath,c_mfn);
end

qsubstr=sprintf('%s%s;\n',g.qsubstr,qsubstr_tmp);

