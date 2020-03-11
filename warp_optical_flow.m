function [sintetizadas] = warp_optical_flow(flow_up, flow_down, flow_left, flow_right, vertical_pc, horizontal_pc, path_lf, type, lf_name)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% LENSLET %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(type, 'lenslet')
        disp('lenslet')
        ref_SAI = im2double(imread([path_lf '007_007.ppm']));
        sintetizadas = cell(15,15);
        scaleFactor = 1;
        threshold = 0.0;

        i = 1:434;
        j = 1:625;

        up_vy = flow_up.Vy;
        down_vy = flow_down.Vy;
        right_vx = flow_right.Vx;
        left_vx = flow_left.Vx;

        positive_up_vy = up_vy(i,j)>=threshold;
        negative_up_vy = -1.*(up_vy(i,j)<=-threshold);
        up_vy = positive_up_vy + negative_up_vy;
        filename = ['up_vy_', num2str(threshold),'.csv'];   
        csvwrite(filename, up_vy);

        positive_down_vy = down_vy(i,j)>=threshold;
        negative_down_vy = -1.*(down_vy(i,j)<=-threshold);
        down_vy = positive_down_vy + negative_down_vy;
        filename = ['down_vy_', num2str(threshold),'.csv'];   
        csvwrite(filename, down_vy);

        positive_right_vx = right_vx(i,j)>=threshold;
        negative_right_vx = -1.*(right_vx(i,j)<=-threshold);
        right_vx = positive_right_vx + negative_right_vx;
        filename = ['right_vx_', num2str(threshold),'.csv'];   
        csvwrite(filename, right_vx);

        positive_left_vx = left_vx(i,j)>=threshold;
        negative_left_vx = -1.*(left_vx(i,j)<=-threshold);
        left_vx = positive_left_vx + negative_left_vx;
        filename = ['left_vx_', num2str(threshold),'.csv'];   
        csvwrite(filename, left_vx);


        for sai_ver = 1:15
            for sai_hor = 1:15
                if(sai_ver == 8 && sai_hor == 8)
                    horizontal_displacement = ref_SAI;
                    disp('REFERENCE SAI')
                else
                    disp([sai_ver sai_hor]);
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
  
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;

                    deltaX = 0; % O fator de escala é zero para anular o deslocamento horizontal em SAIs verticalmente vizinhas
                    deltaY = vertical_pc(sai_ver, 1);

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX;
                    scaled_vy = original_vy.*lambdaY.*scaleFactor;

                    for i = 2:433
                        for j = 2:624
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);

                            if ((-vx+j > 625) || (-vx+j < 1) || (-vy+i > 434) || (-vy+i < 1)) % + Deus
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

                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;

                    deltaX = horizontal_pc(sai_hor,1);
                    deltaY = 0; % O fator de escala é zero para anular o deslocamento verticalem SAIs horizontalmente vizinhas

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX.*scaleFactor;
                    scaled_vy = original_vy.*lambdaY;

                    for i = 2:433
                        for j = 2:624
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);

                            if ((-vx+j > 625) || (-vx+j < 1) || (-vy+i > 434) || (-vy+i < 1)) % + Deus
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
                sintetizadas{sai_ver, sai_hor} = horizontal_displacement;
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% SYNTHETIC %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(type, 'synthetic')
        disp('synthetic')
        ref_SAI = im2double(imread([path_lf '004_004.ppm']));
        sintetizadas = cell(9, 9);
        scaleFactor = 1;
        threshold = 0.0001;

        i = 1:512;
        j = 1:512;

        up_vy = flow_up.Vy;
        down_vy = flow_down.Vy;
        right_vx = flow_right.Vx;
        left_vx = flow_left.Vx;

        positive_up_vy = up_vy(i,j)>=threshold;
        negative_up_vy = -1.*(up_vy(i,j)<=-threshold);
        up_vy = positive_up_vy + negative_up_vy;
%         filename = ['up_vy_', num2str(threshold),'.csv'];   
%         csvwrite(filename, up_vy);

        positive_down_vy = down_vy(i,j)>=threshold;
        negative_down_vy = -1.*(down_vy(i,j)<=-threshold);
        down_vy = positive_down_vy + negative_down_vy;
%         filename = ['down_vy_', num2str(threshold),'.csv'];   
%         csvwrite(filename, down_vy);

        positive_right_vx = right_vx(i,j)>=threshold;
        negative_right_vx = -1.*(right_vx(i,j)<=-threshold);
        right_vx = positive_right_vx + negative_right_vx;
%         filename = ['right_vx_', num2str(threshold),'.csv'];   
%         csvwrite(filename, right_vx);

        positive_left_vx = left_vx(i,j)>=threshold;
        negative_left_vx = -1.*(left_vx(i,j)<=-threshold);
        left_vx = positive_left_vx + negative_left_vx;
%         filename = ['left_vx_', num2str(threshold),'.csv'];   
%         csvwrite(filename, left_vx);


        for sai_ver = 1:9
            for sai_hor = 1:9
                if(sai_ver == 5 && sai_hor == 5)
                    horizontal_displacement = ref_SAI;
                    disp('REFERENCE SAI')
                else
                    disp([sai_ver sai_hor]);
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
  
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;

                    deltaX = 0; % O fator de escala é zero para anular o deslocamento horizontal em SAIs verticalmente vizinhas
                    deltaY = vertical_pc(sai_ver, 1);

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX;
                    scaled_vy = original_vy.*lambdaY.*scaleFactor;

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

                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;

                    deltaX = horizontal_pc(sai_hor,1);
                    deltaY = 0; % O fator de escala é zero para anular o deslocamento verticalem SAIs horizontalmente vizinhas

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX.*scaleFactor;
                    scaled_vy = original_vy.*lambdaY;

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
                    horizontal_displacement(512, :, :) = ref_SAI(512, :, :);
                    horizontal_displacement(:, 512, :) = ref_SAI(:, 512, :);
                end  
                sintetizadas{sai_ver, sai_hor} = horizontal_displacement;
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% HDCA %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(type, 'HDCA')
        disp('stanford')
        ref_SAI = im2double(imread([path_lf '004_004.ppm']));
        sintetizadas = cell(17,17);
        scaleFactor = 1;
        threshold = 0.0001;

        i = 1:1024;
        j = 1:1024;

        up_vy = flow_up.Vy;
        down_vy = flow_down.Vy;
        right_vx = flow_right.Vx;
        left_vx = flow_left.Vx;

        positive_up_vy = up_vy(i,j)>=threshold;
        negative_up_vy = -1.*(up_vy(i,j)<=-threshold);
        up_vy = positive_up_vy + negative_up_vy;
        filename = ['up_vy_', num2str(threshold),'.csv'];   
        csvwrite(filename, up_vy);

        positive_down_vy = down_vy(i,j)>=threshold;
        negative_down_vy = -1.*(down_vy(i,j)<=-threshold);
        down_vy = positive_down_vy + negative_down_vy;
        filename = ['down_vy_', num2str(threshold),'.csv'];   
        csvwrite(filename, down_vy);

        positive_right_vx = right_vx(i,j)>=threshold;
        negative_right_vx = -1.*(right_vx(i,j)<=-threshold);
        right_vx = positive_right_vx + negative_right_vx;
        filename = ['right_vx_', num2str(threshold),'.csv'];   
        csvwrite(filename, right_vx);

        positive_left_vx = left_vx(i,j)>=threshold;
        negative_left_vx = -1.*(left_vx(i,j)<=-threshold);
        left_vx = positive_left_vx + negative_left_vx;
        filename = ['left_vx_', num2str(threshold),'.csv'];   
        csvwrite(filename, left_vx);


        for sai_ver = 1:17
            for sai_hor = 1:17
                if(sai_ver == 10 && sai_hor == 10)
                    horizontal_displacement = ref_SAI;
                    disp('REFERENCE SAI')
                else
                    disp([sai_ver sai_hor]);
                    vertical_displacement = zeros(1024, 1024, 3);

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

                    i = 1:1024;
                    j = 1:1024;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;
  
                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;

                    deltaX = 0; % O fator de escala é zero para anular o deslocamento horizontal em SAIs verticalmente vizinhas
                    deltaY = vertical_pc(sai_ver, 1);

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX;
                    scaled_vy = original_vy.*lambdaY.*scaleFactor;
                    
                    % 433 or 1023
                    for i = 2:1023
                         % 624 or 1023
                        for j = 2:1023
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);

                            if ((-vx+j > 1024) || (-vx+j < 1) || (-vy+i > 1024) || (-vy+i < 1)) % + Deus
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
                    if (sai_hor < 10)
                        original_vx = flow_left.Vx;  
                        original_vy = flow_left.Vy;    
                    else
                        original_vx = flow_right.Vx;  
                        original_vy = flow_right.Vy;
                    end

                    i = 1:1024;
                    j = 1:1024;
                    original_vx_positive = original_vx(i,j)>=threshold;
                    original_vx_negative = -1.*(original_vx(i,j)<=-threshold);
                    original_vx = original_vx_positive + original_vx_negative;

                    original_vy_positive = original_vy(i,j)>=threshold;
                    original_vy_negative = -1.*(original_vy(i,j)<=-threshold);
                    original_vy = original_vy_positive + original_vy_negative;

                    deltaX = horizontal_pc(sai_hor,1);
                    deltaY = 0; % O fator de escala é zero para anular o deslocamento verticalem SAIs horizontalmente vizinhas

                    lambdaX = deltaX/(max(max(original_vx)));
                    lambdaY = deltaY/(max(max(original_vy)));

                    scaled_vx = original_vx.*lambdaX.*scaleFactor;
                    scaled_vy = original_vy.*lambdaY;

                    for i = 2:1023
                        for j = 2:1023
                            vx = scaled_vx(i,j);
                            vy = scaled_vy(i,j);

                            if ((-vx+j > 1024) || (-vx+j < 1) || (-vy+i > 1024) || (-vy+i < 1)) % + Deus
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
                    horizontal_displacement(1024, :, :) = ref_SAI(1024, :, :);
                    horizontal_displacement(:, 1024, :) = ref_SAI(:, 1024, :);
                end  
                sintetizadas{sai_ver, sai_hor} = horizontal_displacement;
            end
        end 
    end
    
end

