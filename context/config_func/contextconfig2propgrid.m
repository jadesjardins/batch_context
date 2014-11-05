function properties = contextconfig2propgrid(contextconfig)

if nargin==0;%Use the global object CONTEXT_CONFIG
    global CONTEXT_CONFIG
    if isempty(CONTEXT_CONFIG);
        sprintf('%s','There is no CONTEXT_CONFIG object in the workspace\n')
        sprintf('%s','Use "File > Context configuration file > etc..." from eeglab GUI\n')
        sprintf('%s','Quitting context procedure...\n')
        return
    else
        contextconfig=CONTEXT_CONFIG;
    end
end

    properties = [ ...
        PropertyGridField('log', contextconfig.log, ...
        'Category', 'Relative locations', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'log path [log]', ...
        'Description', ['Log directory relative to the project paths ', ...
                        '(e.g. ''analysis/log'', default = ''''). ', ...
                        '[local_project]/[log] will be the location where ', ...
                        'the execution folders containing *.m, *.log and *.err ', ...
                        'files will be created. ', ...
                        'For remote execution [remote_project_work]/[log] will be ',...
                        'the locations where the execution folders will be transfered ', ...
                        'for execution on the remote compute host.']) ...
...
        PropertyGridField('local_project', contextconfig.local_project, ...
        'Category', 'Local locations', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Project root directory [local_project]', ...
        'Description', ['The absolute path to the project''s root directory. ',...
                        'This is the path from which relative paths in scripts are defined ', ...
                        '(if empty cd is used).']) ...
        PropertyGridField('local_dependency', contextconfig.local_dependency, ...
        'Category', 'Local locations', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Dependency root directory [local_dependency]', ...
        'Description', 'The absolute path of the root dependency directory containing the program files.') ...
...
        PropertyGridField('remote_exec_host', contextconfig.remote_exec_host, ...
        'Category', 'Remote locations', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Host of compute execution [remote_exec_host]', ...
        'Description', ['Address to the remote host ', ...
                        '(e.g. username@system.host.com).']) ...
        PropertyGridField('remote_project_archive', contextconfig.remote_project_archive, ...
        'Category', 'Remote locations', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Project root archive address [remote_project_archive]', ...
        'Description', ['The absolute address to the project''s root directory ', ...
                        'on the remote archive host ', ...
                        '(e.g. username@system.host.com:/archive/username/mystudy).']) ...
        PropertyGridField('remote_project_work', contextconfig.remote_project_work, ...
        'Category', 'Remote locations', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Project root work address [remote_project_work]', ...
        'Description', ['The absolute address to the project''s root directory ', ...
                        'on the remote compute host ', ...
                        '(e.g. username@system.host.com:/work/username/mystudy).']) ...
        PropertyGridField('remote_dependency', contextconfig.remote_dependency, ...
        'Category', 'Remote locations', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Dependency address [remote_dependency]', ...
        'Description', ['The absolute address of the remote dependency location ', ...
                        'where the program files are found ', ...
                        '(e.g. username@system.host.com:/home/groupename/eeglab/)']) ...
...
        PropertyGridField('mount_archive', contextconfig.mount_archive, ...
        'Category', 'Mount points', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Archive mount directory [mount_archive]', ...
        'Description', ['Local path for mounting the remote_project_archive directory. ', ...
                        'Relative paths are completed from [local_project].']) ...
        PropertyGridField('mount_work', contextconfig.mount_work, ...
        'Category', 'Mount points', ...
        'Type', PropertyType('char', 'row'), ...
        'DisplayName', 'Work mount directory [mount_work]', ...
        'Description', ['Local path for mounting the remote_project_work directory. ', ...
                        'Relative paths are completed from [local_project].']) ...
...
        PropertyGridField('misc', contextconfig.misc, ...
        'Category', 'Miscellaneous locations', ...
        'Type', PropertyType('cellstr', 'column'), ...
        'DisplayName', '[misc]', ...
        'Description', ['Key strings and addresses/paths of other places ',...
                        '(e.g. ''[mount_backup] /media/user/external/backup/'').']) ...
...
        PropertyGridField('system_cmds', contextconfig.system_cmds, ...
        'Category', 'System variables', ...
        'Type', PropertyType('cellstr', 'column'), ...
        'DisplayName', 'system commands', ...
        'Description', 'commands to evaluate from the system...') ...
        ];
