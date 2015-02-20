function batchconfig = propgrid2batchconfig(propgrid,batchconfig)

npg=length(propgrid.Properties);
nlevels=npg/4;

if nargin==1;
    batchconfig=batchconfig_obj;
end
for li=1:nlevels;
    
    batchconfig(li).exec_func=propgrid.Properties((li*4)-3).Value;
    batchconfig(li).replace_string=propgrid.Properties((li*4)-2).Value;
    batchconfig(li).order=propgrid.Properties((li*4)-1).Value;
    
    batchconfig(li).job_name=propgrid.Properties((li*4)).Children(1).Value;
    batchconfig(li).session_init=propgrid.Properties((li*4)).Children(2).Value;
    batchconfig(li).job_init=propgrid.Properties((li*4)).Children(3).Value;
    batchconfig(li).m_init=propgrid.Properties((li*4)).Children(4).Value;
%    batchconfig(li).queue=propgrid.Properties((li*4)).Children(5).Value;
%    batchconfig(li).run_time=propgrid.Properties((li*4)).Children(6).Value;
%    batchconfig(li).num_cores=propgrid.Properties((li*4)).Children(7).Value;
%    batchconfig(li).num_nodes=propgrid.Properties((li*4)).Children(8).Value;
%    batchconfig(li).num_proc_per_node=propgrid.Properties((li*4)).Children(9).Value;
%    batchconfig(li).num_thread_per_proc=propgrid.Properties((li*4)).Children(10).Value;
%    batchconfig(li).memory_per_proc=propgrid.Properties((li*4)).Children(11).Value;
    batchconfig(li).qsub_options=propgrid.Properties((li*4)).Children(5).Value;
    batchconfig(li).software=propgrid.Properties((li*4)).Children(6).Value;
    batchconfig(li).program_options=propgrid.Properties((li*4)).Children(7).Value;

end 
