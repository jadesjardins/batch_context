classdef batchconfig_obj
    
    properties

        file_name='';
        
        exec_func='ef_current_base';
        replace_string={''};
        order=[];
        
        %remote execution properties
        session_init='';
        job_name='';
        job_init='';
        m_init='';
%        queue='';
%        run_time='';
%        num_cores=[];
%        num_nodes=[],
%        num_proc_per_node=[];
%        num_thread_per_proc=[];
%        memory_per_proc='';
        qsub_options={''};
        software='matlab';
        program_options={''};

    end
    
    methods
    end
    
end