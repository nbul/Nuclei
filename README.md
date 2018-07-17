# Nuclei

This is a script to analyse the spacial appearance of DNA damage in nuclei and test for colocalisation with other markers.

## Running the script

To start the analysis, run the "nuclei.m" file. It will first ask what were the channels used for each staining. In case there is only DAPI and &#947;H2AX, put "0" in the 53BP1 input dialog's field. <br>

Then, it will ask about the format of the pictures, so indicate in which bioformat the pictures were saved, e.g. "nd2". The files need to be named in numerical orders starting with 1, i.e. "1", "2", "3", etc.

In the next step, the script creates folders, where analysed data will be saved. This folders are the following:

1. *images_analysed* - saves each DAPI chanel image with outlines of the nuclei, with each nucleus being numbered with numbers corresponding to what is in other files.<br>
![Example of analysed image](images/1_analysed_image.png)

1. *distributions* - there will be folders for individual images with the names corresponding to each image, in which there placed radial distributions of &#947;H2AX for each nucleus (the number of the nucleaus is the same as on the images described above). The classification of the nucleus is written on each image. Here are a couple of examples: <br>
![Example of analysed image](images/13_distribution.png)<br>
![Example of analysed image](images/8_distribution.png)<br>
![Example of analysed image](images/7_distribution.png)
