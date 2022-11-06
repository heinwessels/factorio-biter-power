from PIL import Image

sheet = Image.open(r"C:\\Users\\heinw\\Documents\\Factorio\\Versions\\Factorio_1.1.69\\mods\\biter-power_0.0.1\\graphics\\incubator\\hr-centrifuge-A-shadow.png")

columns = 8
rows = 8
width, height = sheet.size

skip = 1 # Skip every n frames

w = width / columns
h = height / rows

# left, top, right, bottom
crop_l = (67, 13, 230, 136)
crop_l_w = crop_l[2]-crop_l[0]
crop_l_h = crop_l[3]-crop_l[1]

# crop_r = (157, 33, 202, 351)
# crop_r_w = crop_r[2]-crop_r[0]
# crop_r_h = crop_r[3]-crop_r[1]

crop_w = crop_l_w # + crop_r_w
crop_h = crop_l_h

result = Image.new('RGBA', (crop_w*columns//skip, crop_h*rows))

sprites = []
for x in range(columns):
    for y in range(rows):
        if skip > 1 and x % skip == 0: continue
        sprite = sheet.crop((x * w, y * h, (x+1)*w-1, (y+1)*h-1))
        cropped_l = sprite.crop(crop_l)
        # cropped_r = sprite.crop(crop_r)
        result.paste(im=cropped_l, box=(x//skip*crop_w, y*crop_h))
        # result.paste(im=cropped_r, box=(x//skip*crop_w + crop_l_w, y*crop_h))

# result.show()
result.save('motor.png', 'PNG')

