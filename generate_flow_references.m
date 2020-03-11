function [flow_left, flow_right, flow_up, flow_down] = generate_flow_references(input_path, lf_type)
    if contains(lf_type, 'lenslet')
        central_SAI = imread([input_path '007_007.ppm']);
        left_SAI = imread([input_path '000_007.ppm']);
        right_SAI = imread([input_path '014_007.ppm']);
        up_SAI = imread([input_path '007_000.ppm']);
        down_SAI = imread([input_path '007_014.ppm']);

        list_up = {central_SAI up_SAI};
        list_down = {central_SAI down_SAI};
        list_left = {central_SAI left_SAI};
        list_right = {central_SAI right_SAI};

%         h = figure;
%         movegui(h);
%         hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
%         hPlot = axes(hViewPanel);

        opticFlow_up = opticalFlowHS;
        for i = 1:numel(list_up)
            lf = im2double(list_up{1,i});

            frameGray = rgb2gray(lf);  
            flow_up = estimateFlow(opticFlow_up,frameGray);
%             imshow(lf)
%             hold on
%             plot(flow_up,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
%             hold off
%             pause(1)
        end

        opticFlow_down = opticalFlowHS;
        for i = 1:numel(list_down)
            lf = im2double(list_down{1,i});

            frameGray = rgb2gray(lf);  
            flow_down = estimateFlow(opticFlow_down,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_down,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end

        opticFlow_left = opticalFlowHS;
        for i = 1:numel(list_left)
            lf = im2double(list_left{1,i});

            frameGray = rgb2gray(lf);  
            flow_left = estimateFlow(opticFlow_left,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_left,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end

        opticFlow_right = opticalFlowHS;
        for i = 1:numel(list_right)
            lf = im2double(list_right{1,i});

            frameGray = rgb2gray(lf);  
            flow_right = estimateFlow(opticFlow_right,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_right,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end
    end      

    if contains(lf_type, 'synthetic')
        central_SAI = imread([input_path '004_004.ppm']);
        left_SAI = imread([input_path '000_004.ppm']);
        right_SAI = imread([input_path '008_004.ppm']);
        up_SAI = imread([input_path '004_000.ppm']);
        down_SAI = imread([input_path '004_008.ppm']);

        list_up = {central_SAI up_SAI};
        list_down = {central_SAI down_SAI};
        list_left = {central_SAI left_SAI};
        list_right = {central_SAI right_SAI};

%         h = figure;
%         movegui(h);
%         hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
%         hPlot = axes(hViewPanel);

        opticFlow_up = opticalFlowHS;
        for i = 1:numel(list_up)
            lf = im2double(list_up{1,i});

            frameGray = rgb2gray(lf);  
            flow_up = estimateFlow(opticFlow_up,frameGray);
%             imshow(lf)
%             hold on
%             plot(flow_up,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
%             hold off
%             pause(1)
        end

        opticFlow_down = opticalFlowHS;
        for i = 1:numel(list_down)
            lf = im2double(list_down{1,i});

            frameGray = rgb2gray(lf);  
            flow_down = estimateFlow(opticFlow_down,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_down,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end

        opticFlow_left = opticalFlowHS;
        for i = 1:numel(list_left)
            lf = im2double(list_left{1,i});

            frameGray = rgb2gray(lf);  
            flow_left = estimateFlow(opticFlow_left,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_left,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end

        opticFlow_right = opticalFlowHS;
        for i = 1:numel(list_right)
            lf = im2double(list_right{1,i});

            frameGray = rgb2gray(lf);  
            flow_right = estimateFlow(opticFlow_right,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_right,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end
    end
    
     if contains(lf_type, 'HDCA')
        central_SAI = imread([input_path '09_09.png']);
        left_SAI = imread([input_path '00_09.png']);
        right_SAI = imread([input_path '16_09.png']);
        up_SAI = imread([input_path '09_00.png']);
        down_SAI = imread([input_path '09_16.png']);

        list_up = {central_SAI up_SAI};
        list_down = {central_SAI down_SAI};
        list_left = {central_SAI left_SAI};
        list_right = {central_SAI right_SAI};

%         h = figure;
%         movegui(h);
%         hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
%         hPlot = axes(hViewPanel);

        opticFlow_up = opticalFlowHS;
        for i = 1:numel(list_up)
            lf = im2double(list_up{1,i});

            frameGray = rgb2gray(lf);  
            flow_up = estimateFlow(opticFlow_up,frameGray);
%             imshow(lf)
%             hold on
%             plot(flow_up,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
%             hold off
%             pause(1)
        end

        opticFlow_down = opticalFlowHS;
        for i = 1:numel(list_down)
            lf = im2double(list_down{1,i});

            frameGray = rgb2gray(lf);  
            flow_down = estimateFlow(opticFlow_down,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_down,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end

        opticFlow_left = opticalFlowHS;
        for i = 1:numel(list_left)
            lf = im2double(list_left{1,i});

            frameGray = rgb2gray(lf);  
            flow_left = estimateFlow(opticFlow_left,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_left,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end

        opticFlow_right = opticalFlowHS;
        for i = 1:numel(list_right)
            lf = im2double(list_right{1,i});

            frameGray = rgb2gray(lf);  
            flow_right = estimateFlow(opticFlow_right,frameGray);
    %         imshow(lf)
    %         hold on
    %         plot(flow_right,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %         hold off
    %         pause(1)
        end
    end      
end

