import os
import matlab.engine

matlab = matlab.engine.start_matlab()
a = matlab.warp_SAIs('HDCA','the_stanford_bunny', 'blocks', 'median', nargout=0)

# cmd_matlab = 'matlab -r '
# cmd_add_path = "\"addpath('/home/douglascorrea/matlab-workspace/opticalFlow_PhaseCorrelation_encoder/'); " 
# cmd_of_pc_encoder = "warp_SAIs('HDCA','the_stanford_bunny', 'blocks', 'median'); exit\""
# cmd_call_of_pc_encoder = cmd_matlab + cmd_add_path + cmd_of_pc_encoder

# print(cmd_call_of_pc_encoder)
# os.system(cmd_call_of_pc_encoder)
