function BATCH_CONFIG=context_key_swap(BATCH_CONFIG,CONTEXT_CONFIG)

global BATCH_CONFIG;
global CONTEXT_CONFIG;

for i=1:length(BATCH_CONFIG);
    
    BATCH_CONFIG(i).work_path=CONTEXT_CONFIG.local_work;%...

    hn_start_ind=strfind(CONTEXT_CONFIG.remote_work,'@')+1;
    if isempty(hn_start_ind);hn_start_ind=1;end;

    hn_end_ind=strfind(CONTEXT_CONFIG.remote_work,':')-1;
    if isempty(hn_end_ind);hn_end_ind=length(CONTEXT_CONFIG.remote_work);end;

    BATCH_CONFIG(i).host_name=CONTEXT_CONFIG.remote_work(hn_start_ind:hn_end_ind);%...
    
    dp_start_ind=strfind(CONTEXT_CONFIG.remote_dependency,':')+1;
    if isempty(dp_start_ind);dp_start_ind=1;end;    
    BATCH_CONFIG(i).dependency_path=CONTEXT_CONFIG.remote_dependency(dp_start_ind:length(CONTEXT_CONFIG.remote_dependency));
    
    wp_start_ind=strfind(CONTEXT_CONFIG.remote_work,':')+1;
    if isempty(wp_start_ind);wp_start_ind=1;end;
    BATCH_CONFIG(i).work_path=CONTEXT_CONFIG.remote_work(wp_start_ind:length(CONTEXT_CONFIG.remote_work));

%% OBSOLETE...
%    BATCH_CONFIG(i).analysis_root=CONTEXT_CONFIG.local_analysis;%...
%
%    hn_start_ind=strfind(CONTEXT_CONFIG.remote_scratch,'@')+1;
%    if isempty(hn_start_ind);hn_start_ind=1;end;
%
%    hn_end_ind=strfind(CONTEXT_CONFIG.remote_scratch,':')-1;
%    if isempty(hn_end_ind);hn_end_ind=length(CONTEXT_CONFIG.remote_scratch);end;
%
%    BATCH_CONFIG(i).host_name=CONTEXT_CONFIG.remote_scratch(hn_start_ind:hn_end_ind);%...
%    
%    dp_start_ind=strfind(CONTEXT_CONFIG.remote_dependency,':')+1;
%    if isempty(dp_start_ind);dp_start_ind=1;end;    
%    BATCH_CONFIG(i).dependency_path=CONTEXT_CONFIG.remote_dependency(dp_start_ind:length(CONTEXT_CONFIG.remote_dependency));
%    
%    wp_start_ind=strfind(CONTEXT_CONFIG.remote_scratch,':')+1;
%    if isempty(wp_start_ind);wp_start_ind=1;end;
%    BATCH_CONFIG(i).work_path=CONTEXT_CONFIG.remote_scratch(wp_start_ind:length(CONTEXT_CONFIG.remote_scratch));
end