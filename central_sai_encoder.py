# cmd1 = './TAppEncoderStatic -c ../cfg/encoder_intra_main_rext.cfg -c ../cfg/per-sequence/' + lf + '.cfg -f 1 --QP=' + qp
# cmd2 = ' --InputFile=/home/douglascorrea/light-field/dataset/black_border_central_sai/' + lf + '_central_border_qp' + qp + '.yuv'
import os

def central_sai_to_yuv(lf_type, org_lf_path, yuv_path):
	file = open('central_sai_list.txt', 'w')

	file.write('file \'007_007.ppm\'\n')
	file.write('duration 1' + '\n')
	
	if lf_type == 'lenslet':
		cmd = 'ffmpeg -r 30 -f concat -safe 0 -i ' + org_lf_path + 'central_sai_list.txt -s 632x440 -framerate 30 -c:v rawvideo -pix_fmt yuv444p10le ' + yuv_path + 'central_sai.yuv'
		print(cmd)
		os.system(cmd)


def encode_central_sai_hevc(org_lf_path, yuv_path, qp):
	#print(org_lf_path)
	lf_name = org_lf_path.split('/')[-2]
	#print(lf_name)
	# cmd1 = './TAppEncoderStatic -c ../cfg/encoder_intra_main_rext.cfg -c ../cfg/per-sequence/' + lf + '.cfg -f 1 --QP=' + qp
	# cmd2 = ' --InputFile=/home/douglascorrea/light-field/dataset/black_border_central_sai/' + lf + '_central_border_qp' + qp + '.yuv'