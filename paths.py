class Paths:
	def __init__(self):
		self.org_lf_path = ''
		self.reference_lf_path = ''
		self.of_pc_lf_path = ''
		self.output_path = ''
		self.residues_path = ''
		self.yuv_path = ''
		self.str_path = ''


	def set_paths(self, parameters):
		self.org_lf_path = parameters['-input']
		self.reference_lf_path = parameters['-reference']
		self.output_path = parameters['-output']
		self.of_pc_lf_path = self.output_path + 'of+pc/'
		self.residues_path = self.output_path + 'residues/'
		self.yuv_path = self.output_path + 'yuv/'
		self.str_path = self.output_path + 'str/'

	def print_paths(self):
		print('Original dataset: ' + self.org_lf_path)
		print('Reference SAI: ' + self.reference_lf_path) 
		print('Output path: ' + self.output_path)
		print('OF+PC dataset: ' + self.of_pc_lf_path)
		print('Residues dataset: ' + self.residues_path)
		print('YUV path: ' + self.yuv_path)
		print('Bitstream path: ' + self.str_path)