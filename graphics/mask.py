from PIL import Image

# sheet = Image.open(r"C:\\Users\\heinw\\Documents\\Factorio\\Versions\\Factorio_1.1.69\\mods\\biter-power_0.0.1\\graphics\\incubator\\hr-center-precut.png")
# mask = Image.open(r"C:\\Users\\heinw\\Documents\\Factorio\\Versions\\Factorio_1.1.69\\mods\\biter-power_0.0.1\\graphics\\incubator\\mask.png")

sheet = Image.open(r"C:\\Users\\heinw\\Documents\\Factorio\\Versions\\Factorio_1.1.69\\mods\\biter-power_0.0.1\\graphics\\relocation-center\\hr-center-shadow.png")
mask = Image.open(r"C:\\Users\\heinw\\Documents\\Factorio\\Versions\\Factorio_1.1.69\\mods\\biter-power_0.0.1\\graphics\\relocation-center\\hr-center-mask.png")

columns = 8
rows = 8
width, height = sheet.size

w = width // columns
h = height // rows

result = Image.new('RGBA', sheet.size)
result.paste(im=sheet)

sprites = []
for column in range(columns):
    for row in range(rows):
        for x in range(w):
            for y in range(h):
                if mask.getpixel((x,y))[-1] != 0:                    
                    result.putpixel((column*w + x, row*h + y), (0,0,0,0))
        

# result.show()
result.save('motor.png', 'PNG')

