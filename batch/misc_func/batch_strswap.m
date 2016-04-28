function tmpHistStr=batch_strswap(tmpHistStr,batchconfig,varargin)

%'datafname',BatchFName{bfni}
%'datafpath',BatchFPath

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('batch_strswap() error: calling convention {''key'', value, ... } error'); return;
end;

% data options...
try g.datafname; catch, g.datafname='';end
try g.datafpath; catch, g.datafpath='';end
try g.log; catch, g.log='';end
try g.local_project; catch, g.local_project='';end
try g.local_dependency; catch, g.local_dependency='';end
try g.remote_project_archive; catch, g.remote_project_archive='';end
try g.remote_project_work; catch, g.remote_project_work='';end
try g.remote_dependency; catch, g.remote_dependency='';end
try g.mount_archive; catch, g.mount_archive='';end
try g.mount_work; catch, g.mount_work='';end

if isempty(batchconfig);
    global BATCH_CONFIG;
    disp('checking for global BATCH_CONFIG object');
    if isempty(BATCH_CONFIG);
        disp('There is no BATCH_CONFIG in the workspace... doing nothing...');
        qsubstr='';
        return;
    end
    batchconfig=BATCH_CONFIG;
end

%%MODIFY TMPHISTSTR...
%perform replace_string{} swap...
for rpi=1:length(batchconfig.replace_string);
    if ~isempty(batchconfig.replace_string{rpi});
        cs=strfind(batchconfig.replace_string{rpi},',');
        if ~isempty(cs);
            str1=strtrim(batchconfig.replace_string{rpi}(1:cs(1)-1));
            if strcmp(str1([1,end]),'[]');
                keystr=str1;
                swapstr=strtrim(batchconfig.replace_string{rpi}(cs(1)+1:end));
            else
                keystr=['[replace_string{',num2str(rpi),'}]'];
                swapstr=batchconfig.replace_string{rpi};
            end
        end
        if ~isempty(strfind(tmpHistStr,keystr));
            %if rpi>length(BATCH_CONFIG(hi).replace_string);
            %    disp('there are not enough replace_string''s defined in BATCH_CONFIG.');
            %    return
            %end
            tmpHistStr=strrep(tmpHistStr, ...
                keystr, ...
                swapstr);
        end
    end
    
end

%swap HistStr keyPack strings...
% batch_dfn
tmpHistStr=key_strswap(tmpHistStr,'batch_dfn',g.datafname);
% batch_dfp
tmpHistStr=key_strswap(tmpHistStr,'batch_dfp',g.datafpath);
%current_dir
tmpHistStr=key_strswap(tmpHistStr,'batch_cd',cd);

%log
tmpHistStr=key_strswap(tmpHistStr,'log',g.log);
%local_project
tmpHistStr=key_strswap(tmpHistStr,'local_project',g.local_project);
%local_dependency
tmpHistStr=key_strswap(tmpHistStr,'local_dependency',g.local_dependency);
%remote_project_archive
tmpHistStr=key_strswap(tmpHistStr,'remote_project_archive',g.remote_project_archive);
%remote_project_work
tmpHistStr=key_strswap(tmpHistStr,'remote_project_work',g.remote_project_work);
%remote_dependency
tmpHistStr=key_strswap(tmpHistStr,'remote_dependency',g.remote_dependency);
%mount_archive
tmpHistStr=key_strswap(tmpHistStr,'mount_archive',g.mount_archive);
%mount_work
tmpHistStr=key_strswap(tmpHistStr,'mount_work',g.mount_work);


