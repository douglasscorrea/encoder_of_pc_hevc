import os
import sys
import matlab.engine

args = {}

for index, arg in enumerate(sys.argv):
	if arg[0] == '-':
		args[arg] = sys.argv[index + 1]

print('\n----- ENCODER PARAMETERS')
print('-Input: ' + args['-input'])
print('-LF Type: ' + args['-type'])
print('-Reference path: ' + args['-reference'])
print('-Output path: ' + args['-output'])
# for arg in sys.argv[1:len(sys.argv)]:
# 	args[arg] = 

# input_path = '/home/douglascorrea/light-field/dataset/lenslet/Bikes/'
# reference_path = '/home/douglascorrea/light-field/dataset/black_border_central_sai/Bikes_central_border_qp22.ppm'
# output_path = '/home/douglascorrea/teste/'

matlab = matlab.engine.start_matlab()
matlab.warp_SAIs(args['-type'], 'blocks', 'median', args['-input'], args['-reference'], args['-output'], nargout=0)
