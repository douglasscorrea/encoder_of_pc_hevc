function [] = warp_SAIs(lf_type, prediction_type, group_vector, input_path, reference_path, output_path)
    clc
    tic

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% LENSLET %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(lf_type, 'lenslet')
        ppm_list = {'000', '007', '014'};

        ref = rgb2gray(imread([input_path, '007_007.ppm']));

        deltasX = zeros(3,3);
        deltasY = zeros(3,3);

        for i = 1:3
            for j=1:3
                arq1 = [input_path, ppm_list{i}, '_', ppm_list{j} , '.ppm'];
                current = rgb2gray(imread(arq1));
                if(max(max(current)) > 0)
                    [deltaX, deltaY] = calc_phase_correlation(ref, current);     
                    deltasX(j,i) = deltaX;
                    deltasY(j,i) = deltaY;
                end
            end
        end

        up_PC = abs(deltasY(1,2));
        down_PC = abs(deltasY(3,2));
        left_PC = abs(deltasX(2,1));
        right_PC = abs(deltasX(2,3));

        vert_PC = zeros(15,1);
        hori_PC = zeros(15,1);

        hori_PC(1,1) = left_PC;
        hori_PC(15,1) = right_PC;

        vert_PC(1,1) = up_PC;
        vert_PC(15,1) = down_PC;

        for i = 8:15
            hori_PC(i,1) = -right_PC - right_PC/7 + (right_PC/7)*i;
            vert_PC(i,1) = -down_PC - down_PC/7 + (down_PC/7)*i;  
        end
        for i = 1:7
            hori_PC(i,1) = left_PC + left_PC/7 - (left_PC/7)*i;
            vert_PC(i,1) = up_PC + up_PC/7 - (up_PC/7)*i;  
        end

        [left_OF,right_OF,up_OF,down_OF] = generate_flow_references(input_path, lf_type);
        
        if contains(prediction_type, 'block')
            warp_optical_flow_blocks(up_OF, down_OF, left_OF, right_OF, vert_PC, hori_PC, group_vector, 'lenslet', input_path, reference_path, output_path);
        else
            sint = warp_optical_flow(up_OF, down_OF, left_OF, right_OF, vert_PC, hori_PC, path_lf, 'lenslet');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% SYNTHETIC %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(lf_type, 'synthetic')
        ppm_list = {'000', '004', '008'};

        ref = rgb2gray(imread([input_path, '004_004.ppm']));

        deltasX = zeros(3,3);
        deltasY = zeros(3,3);

        for i = 1:3
            for j=1:3
                arq1 = [input_path, ppm_list{i}, '_', ppm_list{j} , '.ppm'];
                current = rgb2gray(imread(arq1));
                if(max(max(current)) > 0)
                    [deltaX, deltaY] = calc_phase_correlation(ref,current);     
                    deltasX(j,i) = deltaX;
                    deltasY(j,i) = deltaY;
                end
            end
        end

        up_PC = abs(deltasY(1,2));
        down_PC = abs(deltasY(3,2));
        left_PC = abs(deltasX(2,1));
        right_PC = abs(deltasX(2,3));

        vert_PC = zeros(9,1);
        hori_PC = zeros(9,1);

        hori_PC(1,1) = left_PC;
        hori_PC(9,1) = right_PC;

        vert_PC(1,1) = up_PC;
        vert_PC(9,1) = down_PC;
        
        for i = 4:9
            hori_PC(i,1) = -right_PC - right_PC/4 + (right_PC/4)*i;
            vert_PC(i,1) = -down_PC - down_PC/4 + (down_PC/4)*i;  
        end
        for i = 1:3
            hori_PC(i,1) = left_PC + left_PC/4 - (left_PC/4)*i;
            vert_PC(i,1) = up_PC + up_PC/4 - (up_PC/4)*i;  
        end
        
        [left_OF,right_OF,up_OF,down_OF] = generate_flow_references(input_path, lf_type);
        
        if contains(prediction_type, 'block')
            warp_optical_flow_blocks(up_OF, down_OF, left_OF, right_OF, vert_PC, hori_PC,  group_vector, lf_type, input_path, reference_path, output_path);
        else
            sint = warp_optical_flow(up_OF, down_OF, left_OF, right_OF, vert_PC, hori_PC, path_lf, 'synthetic');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% HDCA %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(lf_type, 'HDCA')
        ppm_list = {'00', '08', '16'};

        ref = rgb2gray(imread([input_path, '08_08.png']));

        deltasX = zeros(3,3);
        deltasY = zeros(3,3);

        for i = 1:3
            for j=1:3
                arq1 = [input_path, ppm_list{i}, '_', ppm_list{j} , '.png'];
                current = rgb2gray(imread(arq1));
                if(max(max(current)) > 0)
                    [deltaX, deltaY] = calc_phase_correlation(ref,current);     
                    deltasX(j,i) = deltaX;
                    deltasY(j,i) = deltaY;
                end
            end
        end

        up_PC = abs(deltasY(1,2));
        down_PC = abs(deltasY(3,2));
        left_PC = abs(deltasX(2,1));
        right_PC = abs(deltasX(2,3));

        vert_PC = zeros(17,1);
        hori_PC = zeros(17,1);

        hori_PC(1,1) = left_PC;
        hori_PC(17,1) = right_PC;

        vert_PC(1,1) = up_PC;
        vert_PC(17,1) = down_PC;
        
        for i = 8:15
            hori_PC(i,1) = -right_PC - right_PC/9 + (right_PC/9)*i;
            vert_PC(i,1) = -down_PC - down_PC/9 + (down_PC/9)*i;  
        end
        for i = 1:7
            hori_PC(i,1) = left_PC + left_PC/9 - (left_PC/9)*i;
            vert_PC(i,1) = up_PC + up_PC/9 - (up_PC/9)*i;  
        end
        [left_OF,right_OF,up_OF,down_OF] = generate_flow_references(input_path, lf_type);
        
        if contains(prediction_type, 'block')
            warp_optical_flow_blocks(up_OF, down_OF, left_OF, right_OF, vert_PC, hori_PC, group_vector, lf_type, input_path, reference_path, output_path);
        else
            sint = warp_optical_flow(up_OF, down_OF, left_OF, right_OF, vert_PC, hori_PC, path_lf, 'HDCA');
        end
    end
    
    toc
end