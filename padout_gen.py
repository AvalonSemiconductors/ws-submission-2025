import yaml
import os
from PIL import Image, ImageDraw

pad_size = 100
bg_fill = (255, 255, 255)
power_pad_color = (255, 50, 50)
ground_pad_color = (25, 25, 25)
digital_pad_color = (100, 255, 100)
analog_pad_color = (100, 100, 255)
clk_pad_color = (143, 0, 255)
design_sel_color = (200, 150, 100)
text_margin = 0

die_width = 4000
die_height = 4000
core_width = 4000
core_height = 4000
south_pads = []
north_pads = []
east_pads = []
west_pads = []
core_offset_x = 0
core_offset_y = 0
with open('librelane/config.yaml', 'r') as file:
	conf = yaml.safe_load(file)
	if('PAD_SOUTH' in conf and type(conf['PAD_SOUTH']) is list):
		south_pads = conf['PAD_SOUTH']
	if('PAD_NORTH' in conf and type(conf['PAD_NORTH']) is list):
		north_pads = conf['PAD_NORTH']
	if('PAD_EAST' in conf and type(conf['PAD_EAST']) is list):
		east_pads = conf['PAD_EAST']
	if('PAD_WEST' in conf and type(conf['PAD_WEST']) is list):
		west_pads = conf['PAD_WEST']
	if('CORE_AREA' in conf and type(conf['CORE_AREA']) is list):
		core_area = conf['CORE_AREA']
		core_width = core_area[2] - core_area[0]
		core_height = core_area[3] - core_area[1]
		core_offset_x = core_area[0]
		core_offset_y = core_area[1]
	if('DIE_AREA' in conf and type(conf['DIE_AREA']) is list):
		die_area = conf['DIE_AREA']
		die_width = die_area[2] - die_area[0]
		die_height = die_area[3] - die_area[1]

def prettify_pad_name(val):
	val = str(val)
	val = val.replace('\\', '')
	if('.' in val):
		val = val.split('.')[0]
	return val

north_pads = list(map(prettify_pad_name, north_pads))
south_pads = list(map(prettify_pad_name, south_pads))
east_pads = list(map(prettify_pad_name, east_pads))
west_pads = list(map(prettify_pad_name, west_pads))

im = Image.new('RGB', (die_width + text_margin * 2, die_height + text_margin * 2), (128, 128, 128))
draw = ImageDraw.Draw(im)
draw.rectangle((0, 0, im.width, im.height), fill=bg_fill)
draw.rectangle((core_offset_x, core_offset_y, core_offset_x + core_width, core_offset_y + core_height), outline=(0,0,0))

def draw_pads(pads, offset, direction, side, reverse = False):
	scale = core_height / len(pads)
	if(direction):
		scale = core_width / len(pads)
	position = 0.25 * scale
	if(reverse):
		position = (len(pads) - 1) * scale + 0.25 * scale
	for pad in pads:
		color = digital_pad_color
		if('analog' in pad):
			color = analog_pad_color
		if('vdd' in pad):
			color = power_pad_color
		if('vss' in pad):
			color = ground_pad_color
		if('clk' in pad):
			color = clk_pad_color
		if('design_sel' in pad):
			color = design_sel_color
		xpos = offset
		ypos = position
		if(direction):
			temp = ypos
			ypos = xpos
			xpos = temp
			xpos += pad_size
		else:
			ypos += pad_size
		xpos += text_margin + core_offset_x - pad_size
		ypos += text_margin + core_offset_y - pad_size
		draw.rectangle((xpos, ypos, xpos + pad_size, ypos + pad_size), fill=color, outline=color)
		draw.text((xpos + 5, ypos - 26), pad, fill=(0,0,0), font_size=22)
		if(reverse):
			position -= scale
		else:
			position += scale

draw_pads(west_pads, 0, False, True, True)
draw_pads(east_pads, core_width + pad_size, False, False, True)
draw_pads(north_pads, 0, True, True, False)
draw_pads(south_pads, core_height + pad_size, True, False, False)

with open('librelane/config.yaml', 'r') as file:
	conf = yaml.safe_load(file)
	if('MACROS' in conf and type(conf['MACROS']) is dict):
		macros = conf['MACROS']
		for m in macros:
			lef = macros[m]['lef']
			if(not lef):
				continue
			lef = lef[0]
			lef = os.path.join('.', 'librelane', lef[5:])
			with open(lef, 'r') as lef_file:
				for line in lef_file:
					line = line.strip()
					if(line.startswith('SIZE')):
						line = line.split(' ')
						width = float(line[1])
						height = float(line[3])
						for instance in macros[m]['instances']:
							location = macros[m]['instances'][instance]['location']
							location[0] += text_margin
							location[1] += text_margin + core_offset_y
							location[1] = im.height - location[1] - 1
							draw.rectangle((location[0], location[1], location[0] + width, location[1] + height), outline=(0,0,0))
							draw.text((location[0] + 5, location[1] - 36), m, fill=(0,0,0), font_size=32)
						break

im.save('padout.png')
