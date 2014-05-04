function out_object=batchconfig_struct2obj(in_structure);

out_object=batchconfig_obj;

for i=1:length(in_structure)
        out_object(i).software=in_structure(i).software;
        out_object(i).host_name=in_structure(i).host_name;
        out_object(i).dependency_path=in_structure(i).dependency_path;
        out_object(i).run_time=in_structure(i).run_time;
        out_object(i).queue=in_structure(i).queue;
        out_object(i).num_nodes=in_structure(i).num_nodes;
        out_object(i).num_proc_per_node=in_structure(i).num_proc_per_node;
        out_object(i).num_cpu_per_proc=in_structure(i).num_cpu_per_proc;
        out_object(i).num_thread_per_proc=in_structure(i).num_thread_per_proc;
        out_object(i).memory_per_proc=in_structure(i).memory_per_proc;
        out_object(i).flag=in_structure(i).flag;
        out_object(i).log_path=in_structure(i).log_path;
        out_object(i).error_path=in_structure(i).error_path;
        out_object(i).replace_string=in_structure(i).replace_string;
        out_object(i).options=in_structure(i).options;
        out_object(i).work_path=in_structure(i).work_path;
        out_object(i).job_name=in_structure(i).job_name;
        out_object(i).session_init=in_structure(i).session_init;
        out_object(i).job_init=in_structure(i).job_init;
end