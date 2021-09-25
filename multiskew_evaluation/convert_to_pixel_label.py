import os
import cv2
import numpy as np
import lxml.etree as ET

page_folder='moc_dataset/train/moc_train_xml/'
image_folder='moc_dataset/train/moc_train_images/'
pixel_label_folder='moc_dataset/train/moc_train_pixel_label/'
os.mkdir(pixel_label_folder)

for page_file in sorted(os.listdir(page_folder)):
    print(page_file)
    img=cv2.imread(image_folder+page_file[:-4]+'.png',0)
    img=255-img
    tree=ET.parse(page_folder+page_file)
    root=tree.getroot()
    page=root[1]
    width=int(page.attrib.get('imageWidth'))
    height=int(page.attrib.get('imageHeight'))
    pixel_label_img=np.zeros((height,width))
    pixel_label=5
    text_region=page[1]
    number_of_textlines=(len(text_region))
    for i in range(1,number_of_textlines-1):
        textline=text_region[i]
        points=textline[0].attrib.get('points').split(" ")
        number_of_vertices=len(points)
        vertices_list=[]
        for j in range(number_of_vertices):
            x=int(points[j].split(",")[0])
            y=int(points[j].split(",")[1])
            vertices_list.append([x,y])
        vertices_array=np.array([vertices_list],dtype=np.int32)
        line_mask=np.zeros((height,width))
        line_mask=cv2.fillPoly(line_mask,vertices_array,1)
        line_text=img*line_mask
        pixel_label_img[line_text==255]=pixel_label
        pixel_label=pixel_label+1
    cv2.imwrite(pixel_label_folder+page_file[:-4]+'.png',pixel_label_img)

    
        














