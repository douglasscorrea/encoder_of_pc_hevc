function warp_optical_flow_blocks(flow_up, flow_down, flow_left, flow_right, vertical_pc, horizontal_pc, group_vector, type, input_path, reference_path, output_path)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% LENSLET %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(type, 'lenslet')
        ref_SAI = zeros(434, 625, 3);
        ref_SAI_wBorder = im2double(imread(reference_path));
        ref_SAI = ref_SAI_wBorder(1:434, 1:625, :);
        
        %ref_SAI = im2double(imread([path_lf '007_007.ppm']));
        [height, width, color_channels] = size(ref_SAI);
        fprintf('Encoding light field\n');
        fprintf(['- Type: ', type, '\n']);
        fprintf(['- Light Field: ', input_path, '\n']);
        fprintf(['- Reference Light Field: ', reference_path, '\n']);
        fprintf(['- Output path: ', output_path, '\n']);
        fprintf(['- SAI size: ', num2str(width), 'x', num2str(height), '\n']);

        sintetizadas = cell(15,15);
        scaleFactor = 1;
        threshold = 0.0001;
        blockSize = 16;
        group_vector = 'median'; %'mean' or 'median'

        for sai_ver = 1:15
            for sai_hor = 1:15
                if(sai_ver == 8 && sai_hor == 8)
                    horizontal_displacement = ref_SAI;
                    fprintf('\tREFERENCE SAI\n')
                else
                    fprintf(['\tEncoding (', num2str(sai_ver), ', ', num2str(sai_hor), ') SAI\n']);
                    vertical_displacement = zeros(434, 625, 3);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PRIMEIRO FAZEMOS O DESLOCAMENTO VERTICAL %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if (sai_ver < 8)
                        original_vx = flow_up.Vx;  
                        original_vy = flow_up.Vy;    
                    else
                        original_vx = flow_down.Vx;  
                        original_vy = flow_down.Vy;
                    end

                    i = 1:434;
                    j = 1:625;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;
    %                 original_vx = significant_vx.*original_vx;
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;
    %                 original_vy = significant_vy.*original_vy;


                    deltaX = 0; % O fator de escala é zero para anular o deslocamento horizontal em SAIs verticalmente vizinhas
                    deltaY = vertical_pc(sai_ver, 1);
                    
%                     disp(sum(sum(original_vx == 0)));
%                     disp(sum(sum(original_vy == 0)));
                    
                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX;
                    scaled_vy = original_vy.*lambdaY.*scaleFactor;
                   
                    block_vector_vx = scaled_vx;
                  
                    d = scaled_vy;

                    for i = 2:blockSize:433
                        for j = 2:blockSize:624
    %                         disp([i,j])
                            if(i+blockSize > 434)
                                blockSize_y = 434-i;
                            else
                                blockSize_y = blockSize;
                            end

                            if(j+blockSize > 625)
                              blockSize_x = 625-j;
                            else
                                blockSize_x = blockSize;
                            end
                            if(strcmp(group_vector, 'mean'))
                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1)));
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1)));    
                            elseif(strcmp(group_vector,'median'))
                                array_vx = scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vx = reshape(array_vx, [numel(array_vx), 1]);
                                array_vy = scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vy = reshape(array_vy, [numel(array_vy), 1]);                            

                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vx);
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vy);    
                            end


                        end
                    end

                    scaled_vx = block_vector_vx;
                    scaled_vy = block_vector_vy;

                    for i = 2:433
                        for j = 2:624
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);
            %                 disp([i j])
            %                 disp(vx)
            %                 disp(vy)

                            if ((-vx+j > 625) || (-vx+j < 1) || (-vy+i > 434) || (-vy+i < 1)) % + Deus
                                vertical_displacement(i, j, :) = ref_SAI(i, j, :);
            %                     disp('borda');
                            else
                                int_vx = fix(vx);
                                frac_vx = abs(vx - int_vx);
                                int_vy = fix(vy);
                                frac_vy = abs(vy - int_vy);
                               
                                for k = 1:3
                                    if(vx>0)
                                        v2 = (1-frac_vx)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vx*ref_SAI(i-int_vy, j-int_vx-1, k);
                                    else
                                        v2 = (1-frac_vx)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vx*ref_SAI(i-int_vy, j-int_vx+1, k);
                                    end

                                    if(vy>0)
                                        v1 = (1-frac_vy)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vy*ref_SAI(i-int_vy-1, j-int_vx, k);
                                    else
                                        v1 = (1-frac_vy)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vy*ref_SAI(i-int_vy+1, j-int_vx, k);
                                    end

                                    if(vx==0 && vy==0)
                                        sintetizado = 0.5*v2 + 0.5*v1;
                                    else
                                        alfa = 1/(frac_vx+frac_vy);
                                        sintetizado = alfa*frac_vy*v2 + alfa*frac_vx*v1;
                                    end

                                    vertical_displacement(i, j, k) = sintetizado;
                                end
                            end    
                        end
                    end


                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % DEPOIS FAZEMOS O DESLOCAMENTO HORIZONTAL %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

                    horizontal_displacement = vertical_displacement;
                    if (sai_hor < 8)
                        original_vx = flow_left.Vx;  
                        original_vy = flow_left.Vy;    
                    else
                        original_vx = flow_right.Vx;  
                        original_vy = flow_right.Vy;
                    end

                    i = 1:434;
                    j = 1:625;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;
    %                 original_vx = significant_vx.*original_vx;
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;
    %                 original_vy = significant_vy.*original_vy;

                    deltaX = horizontal_pc(sai_hor,1);
                    deltaY = 0; % O fator de escala é zero para anular o deslocamento verticalem SAIs horizontalmente vizinhas
                    
%                     disp(sum(sum(original_vx == 0)));
%                     disp(sum(sum(original_vy == 0)));
                    
                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX.*scaleFactor;
                    scaled_vy = original_vy.*lambdaY;

                    block_vector_vx = scaled_vx;
                    block_vector_vy = scaled_vy;

                    for i = 2:blockSize:433
                        for j = 2:blockSize:624
    %                         disp([i,j])
                            if(i+blockSize > 434)
                                blockSize_y = 434-i;
                            else
                                blockSize_y = blockSize;
                            end

                            if(j+blockSize > 625)
                                blockSize_x = 625-j;
                            else
                                blockSize_x = blockSize;
                            end

                            if(strcmp(group_vector, 'mean'))
                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1)));
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1)));    
                            elseif(strcmp(group_vector, 'median'))
                                array_vx = scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vx = reshape(array_vx, [numel(array_vx), 1]);
                                array_vy = scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vy = reshape(array_vy, [numel(array_vy), 1]);                            

                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vx);
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vy);    
                            end


                        end
                    end

                    scaled_vx = block_vector_vx;
                    scaled_vy = block_vector_vy;

                    for i = 2:433
                        for j = 2:624
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);
            %                 disp([i j])
            %                 disp(vx)
            %                 disp(vy)

                            if ((-vx+j > 625) || (-vx+j < 1) || (-vy+i > 434) || (-vy+i < 1)) % + Deus
                                horizontal_displacement(i, j, :) = vertical_displacement(i, j, :);
            %                     disp('borda');
                            else

                                int_vx = fix(vx);
                                frac_vx = abs(vx - int_vx);
                                int_vy = fix(vy);
                                frac_vy = abs(vy - int_vy);

                                for k = 1:3
                                    if(vx>0)
                                        v2 = (1-frac_vx)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vx*vertical_displacement(i-int_vy, j-int_vx-1, k);
                                    else
                                        v2 = (1-frac_vx)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vx*vertical_displacement(i-int_vy, j-int_vx+1, k);
                                    end

                                    if(vy>0)
                                        v1 = (1-frac_vy)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vy*vertical_displacement(i-int_vy-1, j-int_vx, k);
                                    else
                                        v1 = (1-frac_vy)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vy*vertical_displacement(i-int_vy+1, j-int_vx, k);
                                    end
    % 
                                    if(vx==0 && vy==0)
                                        sintetizado = 0.5*v2 + 0.5*v1;
                                    else
                                        alfa = 1/(frac_vx+frac_vy);
                                        sintetizado = alfa*frac_vy*v2 + alfa*frac_vx*v1;
                                    end

                                    horizontal_displacement(i, j, k) = sintetizado;
                                end
                            end    
                        end
                    end
                    horizontal_displacement(1, :, :) = ref_SAI(1, :, :);
                    horizontal_displacement(:, 1, :) = ref_SAI(:, 1, :);
                    horizontal_displacement(434, :, :) = ref_SAI(434, :, :);
                    horizontal_displacement(:, 625, :) = ref_SAI(:, 625, :);
                end
                
                file_name = [output_path, num2str(sai_hor-1,'%03.f'), '_', num2str(sai_ver-1,'%03.f'),'.ppm'];
                fprintf(['\t\t -Saving warped light field: ', file_name, '\n']);
                imwrite(im2uint16(horizontal_displacement),file_name);
%                 sintetizadas{sai_ver, sai_hor} = horizontal_displacement;
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% SYNTHETIC %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(type, 'synthetic')
        ref_SAI = im2double(imread(reference_path));

%         ref_SAI = im2double(imread([path_lf '004_004.ppm']));
        
        [height, width, color_channels] = size(ref_SAI);
       fprintf('Encoding light field\n');
        fprintf(['- Type: ', type, '\n']);
        fprintf(['- Light Field: ', input_path, '\n']);
        fprintf(['- Reference Light Field: ', reference_path, '\n']);
        fprintf(['- Output path: ', output_path, '\n']);
        fprintf(['- SAI size: ', num2str(width), 'x', num2str(height), '\n']);
        
        sintetizadas = cell(9,9);
        scaleFactor = 1;
        threshold = 0.0001;
        blockSize = 16;
        %group_vector = 'median'; %'mean' or 'median'

        for sai_ver = 1:9
            for sai_hor = 1:9
                if(sai_ver == 5 && sai_hor == 5)
                    horizontal_displacement = ref_SAI;
                    fprintf('\tREFERENCE SAI\n')
                else
                    fprintf(['\tEncoding (', num2str(sai_ver), ', ', num2str(sai_hor), ') SAI\n']);
                    vertical_displacement = zeros(512, 512, 3);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PRIMEIRO FAZEMOS O DESLOCAMENTO VERTICAL %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if (sai_ver < 5)
                        original_vx = flow_up.Vx;  
                        original_vy = flow_up.Vy;    
                    else
                        original_vx = flow_down.Vx;  
                        original_vy = flow_down.Vy;
                    end

                    i = 1:512;
                    j = 1:512;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;
    %                 original_vx = significant_vx.*original_vx;
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;
    %                 original_vy = significant_vy.*original_vy;


                    deltaX = 0; % O fator de escala é zero para anular o deslocamento horizontal em SAIs verticalmente vizinhas
                    deltaY = vertical_pc(sai_ver, 1);

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX;
                    scaled_vy = original_vy.*lambdaY.*scaleFactor;

                    block_vector_vx = scaled_vx;
                    block_vector_vy = scaled_vy;

                    for i = 2:blockSize:511
                        for j = 2:blockSize:511
                            if(i+blockSize > 512)
                                blockSize_y = 512-i;
                            else
                                blockSize_y = blockSize;
                            end

                            if(j+blockSize > 512)
                                blockSize_x = 512-j;
                            else
                                blockSize_x = blockSize;
                            end
                            
                            if(strcmp(group_vector, 'mean'))
                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1)));
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1)));    
                            elseif(strcmp(group_vector,'median'))
                                array_vx = scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vx = reshape(array_vx, [numel(array_vx), 1]);
                                array_vy = scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vy = reshape(array_vy, [numel(array_vy), 1]);                            

                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vx);
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vy);    
                            end


                        end
                    end

                    scaled_vx = block_vector_vx;
                    scaled_vy = block_vector_vy;

                    for i = 2:511
                        for j = 2:511
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);

                            if ((-vx+j > 512) || (-vx+j < 1) || (-vy+i > 512) || (-vy+i < 1)) % + Deus
                                vertical_displacement(i, j, :) = ref_SAI(i, j, :);
                            else

                                int_vx = fix(vx);
                                frac_vx = abs(vx - int_vx);
                                int_vy = fix(vy);
                                frac_vy = abs(vy - int_vy);

                                for k = 1:3
                                    if(vx>0)
                                        v2 = (1-frac_vx)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vx*ref_SAI(i-int_vy, j-int_vx-1, k);
                                    else
                                        v2 = (1-frac_vx)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vx*ref_SAI(i-int_vy, j-int_vx+1, k);
                                    end

                                    if(vy>0)
                                        v1 = (1-frac_vy)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vy*ref_SAI(i-int_vy-1, j-int_vx, k);
                                    else
                                        v1 = (1-frac_vy)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vy*ref_SAI(i-int_vy+1, j-int_vx, k);
                                    end

                                    if(vx==0 && vy==0)
                                        sintetizado = 0.5*v2 + 0.5*v1;
                                    else
                                        alfa = 1/(frac_vx+frac_vy);
                                        sintetizado = alfa*frac_vy*v2 + alfa*frac_vx*v1;
                                    end

                                    vertical_displacement(i, j, k) = sintetizado;
                                end
                            end    
                        end
                    end


                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % DEPOIS FAZEMOS O DESLOCAMENTO HORIZONTAL %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

                    horizontal_displacement = vertical_displacement;
                    if (sai_hor < 5)
                        original_vx = flow_left.Vx;  
                        original_vy = flow_left.Vy;    
                    else
                        original_vx = flow_right.Vx;  
                        original_vy = flow_right.Vy;
                    end

                    i = 1:512;
                    j = 1:512;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;
    %                 original_vx = significant_vx.*original_vx;
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;
    %                 original_vy = significant_vy.*original_vy;

                    deltaX = horizontal_pc(sai_hor,1);
                    deltaY = 0; % O fator de escala é zero para anular o deslocamento verticalem SAIs horizontalmente vizinhas

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX.*scaleFactor;
                    scaled_vy = original_vy.*lambdaY;

                    block_vector_vx = scaled_vx;
                    block_vector_vy = scaled_vy;

                    for i = 2:blockSize:511
                        for j = 2:blockSize:511
    %                         disp([i,j])
                            if(i+blockSize > 512)
                                blockSize_y = 512-i;
                            else
                                blockSize_y = blockSize;
                            end

                            if(j+blockSize > 512)
                                blockSize_x = 512-j;
                            else
                                blockSize_x = blockSize;
                            end

                            if(strcmp(group_vector, 'mean'))
                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1)));
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1)));    
                            elseif(strcmp(group_vector, 'median'))
                                array_vx = scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vx = reshape(array_vx, [numel(array_vx), 1]);
                                array_vy = scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vy = reshape(array_vy, [numel(array_vy), 1]);                            

                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vx);
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vy);    
                            end


                        end
                    end

                    scaled_vx = block_vector_vx;
                    scaled_vy = block_vector_vy;

                    for i = 2:511
                        for j = 2:511
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);

                            if ((-vx+j > 512) || (-vx+j < 1) || (-vy+i > 512) || (-vy+i < 1)) % + Deus
                                horizontal_displacement(i, j, :) = vertical_displacement(i, j, :);
                            else

                                int_vx = fix(vx);
                                frac_vx = abs(vx - int_vx);
                                int_vy = fix(vy);
                                frac_vy = abs(vy - int_vy);

                                for k = 1:3
                                    if(vx>0)
                                        v2 = (1-frac_vx)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vx*vertical_displacement(i-int_vy, j-int_vx-1, k);
                                    else
                                        v2 = (1-frac_vx)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vx*vertical_displacement(i-int_vy, j-int_vx+1, k);
                                    end

                                    if(vy>0)
                                        v1 = (1-frac_vy)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vy*vertical_displacement(i-int_vy-1, j-int_vx, k);
                                    else
                                        v1 = (1-frac_vy)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vy*vertical_displacement(i-int_vy+1, j-int_vx, k);
                                    end
                                    
                                    if(vx==0 && vy==0)
                                        sintetizado = 0.5*v2 + 0.5*v1;
                                    else
                                        alfa = 1/(frac_vx+frac_vy);
                                        sintetizado = alfa*frac_vy*v2 + alfa*frac_vx*v1;
                                    end

                                    horizontal_displacement(i, j, k) = sintetizado;
                                end
                            end    
                        end
                    end
                    horizontal_displacement(1, :, :) = ref_SAI(1, :, :);
                    horizontal_displacement(:, 1, :) = ref_SAI(:, 1, :);
                    horizontal_displacement(512, :, :) = ref_SAI(512, :, :);
                    horizontal_displacement(:, 512, :) = ref_SAI(:, 512, :);
                end 
                
                file_name = [output_path, num2str(sai_hor-1,'%03.f'), '_', num2str(sai_ver-1,'%03.f'),'.ppm'];
                fprintf(['\t\t -Saving warped light field: ', file_name, '\n']);
                imwrite(im2uint16(horizontal_displacement),file_name);
%                 sintetizadas{sai_ver, sai_hor} = horizontal_displacement;
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% HDCA %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(type, 'HDCA')
        ref_SAI = im2double(imread(reference_path));
        
        %ref_SAI = im2double(imread([path_lf '007_007.ppm']));
        [height, width, color_channels] = size(ref_SAI);
        fprintf('Encoding light field\n');
        fprintf(['- Type: ', type, '\n']);
        fprintf(['- Light Field: ', input_path, '\n']);
        fprintf(['- Reference Light Field: ', reference_path, '\n']);
        fprintf(['- Output path: ', output_path, '\n']);
        fprintf(['- SAI size: ', num2str(width), 'x', num2str(height), '\n']);
        
        sintetizadas = cell(17,17);
        scaleFactor = 1;
        threshold = 0.0001;
        blockSize = 8;
        group_vector = 'median'; %'mean' or 'median'

        for sai_ver = 1:17
            for sai_hor = 1:17
                if(sai_ver == 10 && sai_hor == 10)
                    horizontal_displacement = ref_SAI;
                    fprintf('\tReference SAI\n');
                else
                    fprintf(['\tEncoding (', num2str(sai_ver), ', ', num2str(sai_hor), ') SAI\n']);
                    vertical_displacement = zeros(height, width, 3);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % PRIMEIRO FAZEMOS O DESLOCAMENTO VERTICAL %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if (sai_ver < 10)
                        original_vx = flow_up.Vx;  
                        original_vy = flow_up.Vy;    
                    else
                        original_vx = flow_down.Vx;  
                        original_vy = flow_down.Vy;
                    end

                    i = 1:height;
                    j = 1:width;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;
    %                 original_vx = significant_vx.*original_vx;
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;
    %                 original_vy = significant_vy.*original_vy;


                    deltaX = 0; % O fator de escala é zero para anular o deslocamento horizontal em SAIs verticalmente vizinhas
                    deltaY = vertical_pc(sai_ver, 1);

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX;
                    scaled_vy = original_vy.*lambdaY.*scaleFactor;

                    block_vector_vx = scaled_vx;
                    block_vector_vy = scaled_vy;

                    for i = 2:blockSize:height-1
                        for j = 2:blockSize:width-1
    %                         disp([i,j])
                            if(i+blockSize > height)
                                blockSize_y = height-i;
                            else
                                blockSize_y = blockSize;
                            end

                            if(j+blockSize > width)
                                blockSize_x = width-j;
                            else
                                blockSize_x = blockSize;
                            end
                            if(strcmp(group_vector, 'mean'))
                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1)));
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1)));    
                            elseif(strcmp(group_vector,'median'))
                                array_vx = scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vx = reshape(array_vx, [numel(array_vx), 1]);
                                array_vy = scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vy = reshape(array_vy, [numel(array_vy), 1]);                            

                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vx);
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vy);    
                            end


                        end
                    end

                    scaled_vx = block_vector_vx;
                    scaled_vy = block_vector_vy;

                    for i = 2:height-1
                        for j = 2:width-1
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);
            %                 disp([i j])
            %                 disp(vx)
            %                 disp(vy)

                            if ((-vx+j > width) || (-vx+j < 1) || (-vy+i > height) || (-vy+i < 1)) % + Deus
                                vertical_displacement(i, j, :) = ref_SAI(i, j, :);
            %                     disp('borda');
                            else

                                int_vx = fix(vx);
                                frac_vx = abs(vx - int_vx);
                                int_vy = fix(vy);
                                frac_vy = abs(vy - int_vy);

                                for k = 1:3
                                    if(vx>0)
                                        v2 = (1-frac_vx)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vx*ref_SAI(i-int_vy, j-int_vx-1, k);
                                    else
                                        v2 = (1-frac_vx)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vx*ref_SAI(i-int_vy, j-int_vx+1, k);
                                    end

                                    if(vy>0)
                                        v1 = (1-frac_vy)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vy*ref_SAI(i-int_vy-1, j-int_vx, k);
                                    else
                                        v1 = (1-frac_vy)*ref_SAI(i-int_vy, j-int_vx, k) + frac_vy*ref_SAI(i-int_vy+1, j-int_vx, k);
                                    end

                                    if(vx==0 && vy==0)
                                        sintetizado = 0.5*v2 + 0.5*v1;
                                    else
                                        alfa = 1/(frac_vx+frac_vy);
                                        sintetizado = alfa*frac_vy*v2 + alfa*frac_vx*v1;
                                    end

                                    vertical_displacement(i, j, k) = sintetizado;
                                end
                            end    
                        end
                    end


                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % DEPOIS FAZEMOS O DESLOCAMENTO HORIZONTAL %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

                    horizontal_displacement = vertical_displacement;
                    if (sai_hor < 10)
                        original_vx = flow_left.Vx;  
                        original_vy = flow_left.Vy;    
                    else
                        original_vx = flow_right.Vx;  
                        original_vy = flow_right.Vy;
                    end

                    i = 1:height;
                    j = 1:width;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;
    %                 original_vx = significant_vx.*original_vx;
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;
    %                 original_vy = significant_vy.*original_vy;

                    deltaX = horizontal_pc(sai_hor,1);
                    deltaY = 0; % O fator de escala é zero para anular o deslocamento verticalem SAIs horizontalmente vizinhas

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX.*scaleFactor;
                    scaled_vy = original_vy.*lambdaY;

                    block_vector_vx = scaled_vx;
                    block_vector_vy = scaled_vy;

                    for i = 2:blockSize:height-1
                        for j = 2:blockSize:width-1
    %                         disp([i,j])
                            if(i+blockSize > height)
                                blockSize_y = height-i;
                            else
                                blockSize_y = blockSize;
                            end

                            if(j+blockSize > width)
                                blockSize_x = width-j;
                            else
                                blockSize_x = blockSize;
                            end

                            if(strcmp(group_vector, 'mean'))
                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1)));
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = mean(mean(scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1)));    
                            elseif(strcmp(group_vector, 'median'))
                                array_vx = scaled_vx(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vx = reshape(array_vx, [numel(array_vx), 1]);
                                array_vy = scaled_vy(i:i+blockSize_y-1,j:j+blockSize_x-1);
                                array_vy = reshape(array_vy, [numel(array_vy), 1]);                            

                                block_vector_vx(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vx);
                                block_vector_vy(i:i+blockSize_y-1, j:j+blockSize_x-1) = median(array_vy);    
                            end


                        end
                    end

                    scaled_vx = block_vector_vx;
                    scaled_vy = block_vector_vy;

                    for i = 2:height-1
                        for j = 2:width-1
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);
            %                 disp([i j])
            %                 disp(vx)
            %                 disp(vy)

                            if ((-vx+j > width) || (-vx+j < 1) || (-vy+i > height) || (-vy+i < 1)) % + Deus
                                horizontal_displacement(i, j, :) = vertical_displacement(i, j, :);
            %                     disp('borda');
                            else

                                int_vx = fix(vx);
                                frac_vx = abs(vx - int_vx);
                                int_vy = fix(vy);
                                frac_vy = abs(vy - int_vy);

                                for k = 1:3
                                    if(vx>0)
                                        v2 = (1-frac_vx)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vx*vertical_displacement(i-int_vy, j-int_vx-1, k);
                                    else
                                        v2 = (1-frac_vx)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vx*vertical_displacement(i-int_vy, j-int_vx+1, k);
                                    end

                                    if(vy>0)
                                        v1 = (1-frac_vy)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vy*vertical_displacement(i-int_vy-1, j-int_vx, k);
                                    else
                                        v1 = (1-frac_vy)*vertical_displacement(i-int_vy, j-int_vx, k) + frac_vy*vertical_displacement(i-int_vy+1, j-int_vx, k);
                                    end
    % 
                                    if(vx==0 && vy==0)
                                        sintetizado = 0.5*v2 + 0.5*v1;
                                    else
                                        alfa = 1/(frac_vx+frac_vy);
                                        sintetizado = alfa*frac_vy*v2 + alfa*frac_vx*v1;
                                    end

                                    horizontal_displacement(i, j, k) = sintetizado;
                                end
                            end    
                        end
                    end
                    horizontal_displacement(1, :, :) = ref_SAI(1, :, :);
                    horizontal_displacement(:, 1, :) = ref_SAI(:, 1, :);
                    horizontal_displacement(height, :, :) = ref_SAI(height, :, :);
                    horizontal_displacement(:, width, :) = ref_SAI(:, width, :);
                end
                file_name = [output_path, num2str(sai_hor-1,'%02.f'), '_', num2str(sai_ver-1,'%02.f'),'.png'];
                fprintf(['\t\t -Saving warped light field: ', file_name, '\n']);
                imwrite(im2uint16(horizontal_displacement),file_name);
%                 sintetizadas{sai_ver, sai_hor} = horizontal_displacement;
            end
        end
    end
end

