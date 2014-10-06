classdef batchconfig_obj
    
    properties

        file_name='';
        
        exec_func='ef_current_base';
        replace_string={''};
        
        %context properties
%        host_name='';
%        analysis_root='';
%        work_path='';
%        log_path='';
%        dependency_path='';
        
        %remote execution properties
        job_name='';
        job_init='';
        m_init='';
        session_init='';
        software='matlab';
        queue='serial';
        run_time='';
        num_nodes=[],
        num_proc_per_node=[];
        num_core_per_proc=[];
        num_thread_per_proc=[];
        memory_per_proc='';
        flag='';
%        error_path='';
        options={''};

    end
    
    methods
    end
    
end