function outstr=context_strswap(instr)

global CONTEXT_CONFIG

outstr=instr;

outstr=strrep(outstr,'[cd]',cd);
if isempty(CONTEXT_CONFIG.local_project)
    disp('local_project property is empty defaulting to cd');
    local_project=cd;
else
    local_project=CONTEXT_CONFIG.local_project;
end
outstr=strrep(outstr,'[local_project]',local_project);
outstr=strrep(outstr,'[local_dependency]',CONTEXT_CONFIG.local_dependency);

outstr=strrep(outstr,'[log]',CONTEXT_CONFIG.log);

outstr=strrep(outstr,'[remote_project_archive]',CONTEXT_CONFIG.remote_project_archive);
outstr=strrep(outstr,'[remote_project_work]',CONTEXT_CONFIG.remote_project_work);
outstr=strrep(outstr,'[remote_dependency]',CONTEXT_CONFIG.remote_dependency);

outstr=strrep(outstr,'[mount_archive]',CONTEXT_CONFIG.mount_archive);
outstr=strrep(outstr,'[mount_work]',CONTEXT_CONFIG.mount_work);

for i=1:length(CONTEXT_CONFIG.misc);
   if ~isempty(CONTEXT_CONFIG.misc{i});
       cs=strfind(CONTEXT_CONFIG.misc{i},',');
       if ~isempty(cs);
           str1=strtrim(CONTEXT_CONFIG.misc{i}(1:cs(1)-1));
           if strcmp(str1([1,end]),'[]');
               outstr=strrep(outstr,str1,strtrim(CONTEXT_CONFIG.misc{i}(cs(1)+1:end)));
           end
       end
   end
end
