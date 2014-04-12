BasicSection
1. run BasicSection.m
2. firstly click to choose the start position 
3. then click 5 positions(default setting) to guide Gabriel to look at
4. output images (.jpg and .gif) are saved in output\BasicSection folder.
5. you can change the default settings like the position number, start frame, frame number from line(6-10) in the script, where comments will guide you. 

AdvancedSection1(consider both image-difference and trajectory similiarity):
AdvancedSection3(slow motion and interpolation):
AdvancedSection4(multi-node interpolation):
1. run AdvancedSection1.m(AdvancedSection3.m/AdvancedSection4.m), this is almost real time rendering
2. click 5 positions(default setting) to guide Gabriel to look at
3. output images (.jpg and .gif) are saved in output\AdvancedSection1(AdvancedSection3/AdvancedSection4) folder
4. you can change the default settings like the position number, start frame, frame number from line(6-10) in the script, where comments will guide you. 
5. The default start position is on the nose. You can delete the buildDGmatrix.mat and optical_flow_path.mat and run again to run your prefer settings. But it will take some time to recompute.

AdvancedSection2(my own data):
1. run AdvancedSection2.m,this is almost real time rendering
2. click 5 positions(default setting) to guide Shaun to look at
3. output images (.jpg and .gif) are saved in output\AdvancedSection2 folder
4. you can change the default settings like the position number, start frame, frame number from line(6-10) in the script, where comments will guide you. 
5. The default start position is between two eyes. You can delete the buildDGmatrix_shaun.mat and optical_flow_path_shaun.mat and run again to run your prefer settings. But it will take some time to recompute.