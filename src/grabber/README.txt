# Grab a frame
openni_grab_frame frame.pcd -format ascii
norm_est
# Get rid of headers so matlab can easily read
tail -307200 frame.pcd > frame.txt
tail -307200 norms.pcd > norms.txt
rm -rf norms.pcd
