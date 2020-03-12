function [] = generate_residues(lf_type, input_path, pred_path, output_path)

    if contains(lf_type, 'lenslet')
        ppm_list = {'000', '001' '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', '013', '014'};
    end
    if contains(lf_type, 'synthetic')
        ppm_list = {'000', '001' '002', '003', '004', '005', '006', '007', '008'}
    end
    
    for l = 1:numel(ppm_list)
        for k = 1:numel(ppm_list)
            org_name = [input_path, ppm_list{k}, '_', ppm_list{l},'.ppm'];
            pred_name = [pred_path, ppm_list{k}, '_', ppm_list{l},'.ppm'];


            disp(org_name);
            disp(pred_name);
            org = imread(org_name);
            pred = imread(pred_name);

            org = bitshift(org, -6); pred=bitshift(pred, -6);
            
            %convert rgb to double
            org_double = double(org)./(2^10-1);
            pred_double = double(pred)./(2^10-1);

            residue = org_double - pred_double;
            
            if contains(lf_type, 'lenslet')
                residue_border = zeros(440, 632, 3);
                residue_border(1:434, 1:625, :) =  residue(1:434, 1:625, :);

                file_name = [output_path, num2str(k-1,'%03.f'), '_', num2str(l-1,'%03.f'),'.ppm'];
                fprintf(['\t-Saving residue ppm: ', file_name, '\n']);
                imwrite(im2uint16(residue_border),file_name);
            end
            if contains(lf_type, 'synthetic')
                file_name = [output_path, num2str(k-1,'%03.f'), '_', num2str(l-1,'%03.f'),'.ppm'];
                fprintf(['\t-Saving residue ppm: ', file_name, '\n']);
                imwrite(im2uint16(residue),file_name);
            end
        end
    end
end