reflowViewer
============

Simple processing sketch that displays real time data from the ESTechnical Reflow Oven Controller


In order to use this program, you will require the processing IDE (available from processing.org for Windows, Mac and Linux). Install the appropriate version for your computer system.


Obtaining the source code
====================

Use one of the following methods to get the source code:

Using GIT:
If you are familiar with git and want to use git to check out the source code, use the following command in a terminal:
(This will check out the source code from git into the current directory. I will cover no further use of git here.)

	git clone https://github.com/estechnical/reflowViewer.git


Downloading a zip file:
	To download a zip file of the latest source code, visit https://github.com/estechnical/reflowViewer and click on the
	'Download ZIP' button (in the right hand column of the page). Once the file has dowloaded, extract the zip archive to a location of your choice.
	

Now that you have downloaded the source code using one of the above methods, copy the reflowViewer directory (contained in the folder reflowViewer that was downloaded from github) to your processing sketchbook directory. You can find or change the location of the processing sketchbook by running the processing IDE and looking in File->Preferences.

You should now have [processing sketchbook directory]/reflowViewer (containing reflowViewer.pde)

Run the processing IDE and open the file reflowViewer.pde.

With the USB cable connecting the computer to the reflow controller/oven & the controller powered on, run the processing sketch to see a live data output.

The data received is logged to a text file.


