import os
import sys
import paths
import matlab.engine
import ppm_to_yuv
import central_sai_encoder

def main():
	parameters = get_parameters()
	#rint_encoder_parameters(parameters)

	path = paths.Paths()

	path.set_paths(parameters)
	#path.print_paths()

	print("\n############################################################")
	print('---------- Creating all directories')
	cmd_mkdir_of_pc = 'mkdir ' + path.of_pc_lf_path
	cmd_mkdir_residues = 'mkdir ' + path.residues_path
	cmd_mkdir_yuv = 'mkdir ' + path.yuv_path
	cmd_mkdir_str = 'mkdir ' + path.str_path
	print(cmd_mkdir_of_pc)
	os.system(cmd_mkdir_of_pc)
	print(cmd_mkdir_residues)
	os.system(cmd_mkdir_residues)
	print(cmd_mkdir_yuv)
	os.system(cmd_mkdir_yuv)
	print(cmd_mkdir_str)
	os.system(cmd_mkdir_str)

	print("\n############################################################")
	print('---------- Encoding central SAI')
	central_sai_encoder.central_sai_to_yuv(parameters['-type'], path.org_lf_path, path.yuv_path)
	central_sai_encoder.encode_central_sai_hevc(path.org_lf_path, path.yuv_path, path.str_path, 50)
	matlab_engine = matlab.engine.start_matlab()

	print("\n############################################################")
	print('---------- Running OF+PC encoder')
	print('Command: warp_SAIs(' + parameters['-type'] + ', \'blocks\', \'median\', ' + path.org_lf_path + ', ' + path.reference_lf_path + ', ' + path.output_path + ')\n')
	matlab_engine.warp_SAIs(parameters['-type'], 'blocks', 'median', path.org_lf_path, path.reference_lf_path, path.of_pc_lf_path, nargout=0)
	
	print("\n############################################################")
	print('---------- Generating residues')
	print('Command: generate_residue(' + parameters['-type'] + ', ' + path.org_lf_path + ', ' + path.of_pc_lf_path + ', ' + path.residues_path + ')\n')
	matlab_engine.generate_residues(parameters['-type'], path.org_lf_path, path.of_pc_lf_path,  path.residues_path, nargout=0)

	print("\n############################################################")
	print('---------- Generating residues YUV')
	ppm_to_yuv.generate_sais_list('lenslet', path.residues_path)
	ppm_to_yuv.generate_yuv_residues('lenslet', path.residues_path, path.yuv_path)	


def get_parameters():
	parameters = {}

	for index, parameter in enumerate(sys.argv):
		if parameter[0] == '-':
			parameters[parameter] = sys.argv[index + 1]
		
	return parameters


def print_encoder_parameters(parameters):
	print('\n---------- ENCODER PARAMETERS')
	print('-Input: ' + parameters['-input'])
	print('-LF Type: ' + parameters['-type'])
	print('-Reference path: ' + parameters['-reference'])
	print('-Output path: ' + parameters['-output'])


if __name__ == '__main__':
	main()