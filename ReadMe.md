WHAT IS THE PURPOSE
The program is written with macOS so there might have file path issues with Windows since they are slightly different. The code is not run on Windows so if you have a error, it is probably about file path.
HGF model and graphs are to estimate the perceptual state of the mouse during the experiment. It is independent of the sides. If the mouse is rewarded it is assumes the perception of the rewarding is percieved well, if the rewarding continues perceptual value(red line) increases since the consistency is increased. Learning rate(black line) increases when the mouse changes from nonrewarding to rewarding since it is assumed that the mouse learns how to get a reward. mu_3(first graph) and mu_2(second graph in a figure) graphs are for the perceptual state and learning rate. In the last graph these rates are same but fluctuates more since the volatility, decision error are also included.

First, simulation graph is made and secondly, estimation graph is calculated by using simulation parameters for parameter recovery. Correlation graph is made from the correlation calculation of the parameters. Diagonal(left to right) correlation is important if it is bright yellow that means it is pretty good. 

BEFORE RUN
**Before starting please make sure to add path of matlab-json and tapas master library. They are in the same file with the xldata.m so you can see them in current folder dock. Just right click and click "add to path > selected folders and subfolders" Otherwise program might cause problems like "function not found". 

Also working with more data causes more time, I can't enhance the process time of the HGF model so, it will take more if you have more file. You can see which session is being processed and how much is left in the terminal. If there is an erro with the file you can just check which one caused the error through the terminal output.

The only input used for the model is the trials data if the mouse is rewarded or not.

HOW TO MAKE IT WORK
To run the code you should have a directory that contains the directories for each mouse and these directories must contain metrics file. I left a directory named "hey" to make the examples about directory order more understandable.
For example:
Parent directory contains : 
ls ./hey
JPAS_0152_2024-03-21_09;06;17.083896 JPAS_0153_2024-06-10_09;40;16.387772 JPAS_0159_2024-07-04_09_37_07.062379 JPAS_0160_2024-04-05_14_59_07.876602
JPAS_0152_2024-04-17_11;48;46.496009 JPAS_0153_2024-06-12_09;57;04.182520 JPAS_0159_2024-07-19_09;44;59.543472
JPAS_0153_2024-04-24_08;58;33.876784 JPAS_0153_2024-06-13_09_20_13.851346 JPAS_0159_2024-07-22_09;22;14.678793
JPAS_0153_2024-06-07_09;03;06.870901 JPAS_0159_2024-04-30_09;21;56.476550 JPAS_0159_2024-07-23_09;58;07.496633
"hey" is the parent directory for the mice data. 

ls ./JPAS_0153_2024-03-29 
config         metrics.json   screenshot.png
"./JPAS_0153_2024-03-29" directory is the directory which contains metrics.json file for one session. 

if you want to compare data of multiple sessions, make sure each directory starts with common name, in the example case, it is JPAS; if  you want to compare one mouse for different sessions it might be JPAS_0152. 

The program takes two inputs after it starts. These are parent directory which for the directories of mice data. It would be ./hey. If you have the matlab program and data directories in the same same directory you can just write "./" which presents present working directory. If the directory is not placed the same path, make sure to write full path for the parent directory. For example "/Users/bernakiziler/Desktop/internship/matlab files/hey". 

About choosing the data you want to compare the starting pattern of each file must have something in common. 
For example; "2024-02-22_JPAS_0152    2024-07-04_JPAS_0159" directories have same "2024" starting so you enter 2024 and program takes metric.json file from the directories that starts with "2024".
Another example, you have this parent directory: ls ./hey
JPAS_0152_2024-03-21_09;06;17.083896 JPAS_0153_2024-06-10_09;40;16.387772 JPAS_0159_2024-07-04_09_37_07.062379 JPAS_0160_2024-04-05_14_59_07.876602
JPAS_0152_2024-04-17_11;48;46.496009 JPAS_0153_2024-06-12_09;57;04.182520 JPAS_0159_2024-07-19_09;44;59.543472
JPAS_0153_2024-04-24_08;58;33.876784 JPAS_0153_2024-06-13_09_20_13.851346 JPAS_0159_2024-07-22_09;22;14.678793
JPAS_0153_2024-06-07_09;03;06.870901 JPAS_0159_2024-04-30_09;21;56.476550 JPAS_0159_2024-07-23_09;58;07.496633

But you just want to compare the same mouse in different sessions, common pattern should be "JPAS_0159"

"Please enter the path for the parent directory(main directory where the data directories take place): " should be "hey" in my case;

"Please enter the directory name which is common for every file you want to compare(e.g. JPAS_0152): " should be "JPAS_0159" to compare one mouse. 

If you just want to take one data of a session, you can enter the full name as common directory such as "JPAS_0152_2024-03-21_09;06;17.083896" .

OUTPUT
Model quality is not accurate, because I changed the tonic volatility(w) with a constant value than it is set after the model qulity output is seen in the terminal, so model quality output is not dependable, do not use it. The changed value is determined by a lot of run to get the most suitable value, tonic volatility(omega / w) for last graph of estimation trajectories are the value that is changed.

Also, HGF model gives error with a session which has more than approx. 385 trials. If you have a problem with 380 or less you can change the value to that threshold. The sessions which cause a warning are ignored by the program, you can see the ignored directories at the end of the program.

Calculation of the graphs won't be shown but they will be saved into ./imgs file with mouse id and the figure name.

comparisonData.xlsx will contain mean standard deviation of some parameters from each session that is run in the program. DON'T FORGET TO SAVE THE EXCEL FILE BEFORE RUN IT AGAIN WITH DIFFERENT DATA. Each run, the file will be written again with the given data. So make sure to change the location of folder or just save it with different name. However, each session has its own values they do not change at the second run. So it is not a problem you forgot to run it would be better to rename it at least.

miceData.xlsx has the each sessions parameters as an array, each session is stored in a different sheet. So you can go through the sheets for the parameters. 





