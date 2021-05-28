import cv2
import skimage
import matplotlib.pyplot as plt

filepath = r'./image.jpg'
proc_image_size = (128, 128)
prob_noise = 0.02

# 1. read jpg
img = cv2.imread(filepath)

# 2. convert to gray scale
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# 3. resize to 128x128
img = cv2.resize(img, proc_image_size)

# 4. add salt and pepper noise
# ref: https://jinzhangyu.github.io/2018/09/03/2018-09-03-OpenCV-Python%E6%95%99%E7%A8%8B-13-%E5%B9%B3%E6%BB%91%E5%9B%BE%E5%83%8F/
img_salt_pepper = skimage.util.random_noise(image=img, mode='s&p', clip=True, amount=prob_noise, salt_vs_pepper=0.5)


# 5. process median filtering
img_filtered = cv2.medianBlur(img, 3)

# 6. output image
plt.figure()
plt.imshow(img, cmap='gray')
plt.figure()
plt.imshow(img_salt_pepper, cmap='gray')
plt.figure()
plt.imshow(img_filtered, cmap='gray')

wf_names  = ['img.dat', 'golden.dat']
wimgs = [img_salt_pepper, img_filtered]
for i in range(len(wf_names)):
  wf_name = wf_names[i]
  wimg = wimgs[i]
  with open(wf_names[i], 'w') as wf:
    for i in range(wimg.shape[0]):
      for j in range(wimg.shape[1]):
        wf.write(str(format(int(img[i, j]), 'x')) + '\n')