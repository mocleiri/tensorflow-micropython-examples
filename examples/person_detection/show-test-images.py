from PIL import Image
import io

image_data_file = open ('person_image_data.dat', 'rb')

image_data = bytearray(9612)

image_data_file.readinto(image_data)

image_data_file.close()

image = Image.frombytes ('L', (96,96), bytes(image_data) ,'raw')

image.show()

np_image_data_file = open ('no_person_image_data.dat', 'rb')

np_image_data = bytearray(9612)

np_image_data_file.readinto(np_image_data)

np_image_data_file.close()

np_image = Image.frombytes ('L', (96,96), bytes(np_image_data) ,'raw')

np_image.show()
