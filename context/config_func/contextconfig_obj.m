classdef contextconfig_obj
    
    properties
        %work='';
        log='';
        %misc='';
        
        local_project='';
        local_dependency='';
        %local_misc={''};
        
        remote_project_archive='';
        remote_project_work='';
        remote_dependency='';
        %remote_misc={''};
        
        mount_archive='';
        mount_work='';
        %mount_misc={''};
        
        misc={''};
        
        system_cmds={'sshfs [remote_archive] [cd]/[mount_archive]'; ...
                     'sshfs [remote_work] [cd]/[mount_work]'; ...
                     'meld [cd]/[local_work] [cd]/[mount_archive] [cd]/[mount_work]'; ...
                     'fusermount -u [cd]/[mount_archive]'; ...
                     'fusermount -u [cd]/[mount_work]'};
    end
    
    methods
    end
    
end