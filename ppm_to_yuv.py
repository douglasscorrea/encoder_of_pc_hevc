import os

#ffmpeg -r 30 -f concat -safe 0 -i list.txt -s 625x434 -framerate 30 -c:v rawvideo -pix_fmt yuv444p10le ABCD_3x3.yuv

def generate_sais_list(lf_type, residues_path):
	excluded_sais = [	'000_000', '000_001', '000_002', '000_003', '000_011', '000_012', '000_013', '000_014',
						'001_000', '001_001', '001_014',
						'002_000', '002_014',
						'003_000', '003_014',
						'011_000', '011_014',
						'012_000', '012_014',
						'013_000', '013_001', '013_013', '013_014',
						'014_000', '014_001', '014_002', '014_003', '014_011', '014_012', '014_013', '014_014']
	
	ppms = os.listdir(residues_path)

	file = open(residues_path + 'ppms_list.txt', 'w')

	for ppm in sorted(ppms):
		if ppm.split('.')[0] not in excluded_sais:
			#print('file \'' + ppm + '\'')
			file.write('file \'' + ppm + '\'' + '\n')
			#print('duration 1')
			file.write('duration 1' + '\n')


def generate_yuv_residues(lf_type, residues_path, yuv_path):
	if lf_type == 'lenslet':
		cmd = 'ffmpeg -hide_banner -loglevel panic -r 30 -f concat -safe 0 -i ' + residues_path + 'ppms_list.txt -s 632x440 -framerate 30 -c:v rawvideo -pix_fmt yuv444p10le ' + yuv_path + 'residue.yuv'
		os.system(cmd)
		