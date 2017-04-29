function first_bin_placement(j, q_head,job_len)

global JOB_SIZE_Q;
job_size = JOB_SIZE_Q(q_head);
global scale;


    
    if job_size >= scale*scale && job_size < scale*scale*scale
        
        first_bin_placement_3D(j,q_head,job_len);
        
    elseif job_size >= scale && job_size < scale*scale
        
        first_bin_placement_2D(j,q_head,job_len);
        
    else
        
        first_bin_placement_1D(j,q_head,job_len);
        
    end


