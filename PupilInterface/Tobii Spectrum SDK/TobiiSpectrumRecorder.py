#!/usr/bin/env python
"""
Tobii Spectrum data recording script.

INSTRUCTIONS
------------
1. Run script or call init_eyetracker() from external script to connect eye tracker
(Independently running script is self-sufficient. Otherwise:
2. If init_eyetracker() returns True, call record() to collect data
(Optional:) call send_trigger(msg) at any point during recording to instantly append messages to the data file.
3. Call stop_recording() to stop collecting data
4. Call save() to write data to .csv

@author: "Aaron Gerston"
@copyright = "Copyright 2019 Eriksholm Research Centre"
"""

import tobii_research as tr
import pandas as pd
import numpy as np
import os


class TobiiSpectrum:

	# Class attributes
	eyetracker    = None
	recorded_data = None # 12-column float array of L and R eye pupil diameters and their validity; 3d gaze position L and R and their validity
	timestamps    = None # System timestamp in microseconds 
	timestamps_dev = None # Device timestamp in microseconds
	#ttl = None
	triggers      = None # Array of strings; empty strings replaced by triggers (max char. 32) in add_trigger(msg)
	nsamples      = None
	
	def __init__(self):
		"""
		Constructor.
		"""
		
		self.eyetracker    = None
		prealloc_size      = 200000
		self.recorded_data = np.full((prealloc_size,12),np.nan)
		self.timestamps    = np.full((prealloc_size,1),np.nan)
		self.timestamps_dev    = np.full((prealloc_size,1),np.nan)
		#self.ttl   = np.full((prealloc_size,1),np.nan)
		self.triggers      = np.full((prealloc_size,1),'',dtype='|S32')
		self.nsamples      = 0
		
		
	def init_eyetracker(self):
		"""
		Tries to establish connection with Tobii Spectrum eye tracker.
		@returns True if connection is successful, False otherwise.
		"""
		
		# Get eyetracker
		found_eyetrackers = tr.find_all_eyetrackers()
			
		if found_eyetrackers:
			self.eyetracker = found_eyetrackers[0]
			print("\n{0} <{1}>: Connection established at {2}.".format(self.eyetracker.model, self.eyetracker.device_name, self.eyetracker.address))
			
			return True
		else:
			return False
			

	def gaze_data_callback(self, gaze_data):
		"""
		System's response to incoming data (gaze_data)
		"""
		
		# Get data from tracker
		pupil_left  = gaze_data.left_eye.pupil.diameter;
		validity_left = gaze_data.left_eye.pupil.validity;
		pupil_right = gaze_data.right_eye.pupil.diameter;
		validity_right = gaze_data.right_eye.pupil.validity;
		gaze_pos_left = gaze_data.left_eye.gaze_origin.position_in_track_box_coordinates;
		gaze_val_left = gaze_data.left_eye.gaze_origin.validity;
		gaze_pos_right = gaze_data.right_eye.gaze_origin.position_in_track_box_coordinates;
		gaze_val_right = gaze_data.right_eye.gaze_origin.validity;
		timestamp   = gaze_data.system_time_stamp;
		timestamp_dev   = gaze_data.device_time_stamp;
		#ttl   = gaze_data.value;
        
		# Add data to global storage
		self.timestamps[self.nsamples,0]    = timestamp;
		self.timestamps_dev[self.nsamples,0]    = timestamp_dev;
		#self.ttl[self.nsamples,0]    = ttl;
		self.recorded_data[self.nsamples,:] = [pupil_left, validity_left, pupil_right, validity_right,
						       gaze_pos_left[0], gaze_pos_left[1], gaze_pos_left[2], gaze_val_left,
						       gaze_pos_right[0], gaze_pos_right[1], gaze_pos_right[2], gaze_val_right]

		#self.recorded_data[self.nsamples,:] = [pupil_left, validity_left, pupil_right, validity_right, gaze_val_left, gaze_val_right]
		
		# Increment nsamples
		self.nsamples += 1
    
	#def external_signal_callback(self,external_signal_data):
		#ttl   = external_signal_data.value;
		#self.ttl[self.nsamples,0]    = ttl;
        
	def send_trigger(self, msg):
		"""
		Appends string msg to list of triggers at the index of the most recent sample
		@param msg: str
		"""
		
		# Add trigger message at point of last retrieved sample
		if self.nsamples == 0:
			sample = self.nsamples
		else:
			sample = self.nsamples-1
		self.triggers[sample] = msg

		
	def stop_recording(self):
		"""
		Unsubscribes from eye tracker data stream
		@param eyetracker: EyeTracker (Object from Tobii Pro Spectrum SDK)
		@returns True if successful, False otherwise
		"""
		
		try:
			print("{0} <{1}>: recording terminated.".format(self.eyetracker.model, self.eyetracker.device_name))
			self.eyetracker.unsubscribe_from(tr.EYETRACKER_GAZE_DATA, self.gaze_data_callback);
			return True
		except:
			return False


	def start_recording(self):
		"""
		Subscribes to eye tracker data stream. Note: takes ~0.25 seconds to begin
		@param eyetracker: EyeTracker (Object from Tobii Pro Spectrum SDK)
		@returns True if successful, False otherwise
		"""

		# Set tracker to automatically call gaze_data_callback when there is new gaze data available
		# Note: takes a fraction of a second to begin
		try:
			print("{0} <{1}>: begin recording.".format(self.eyetracker.model, self.eyetracker.device_name))
			self.eyetracker.subscribe_to(tr.EYETRACKER_GAZE_DATA, self.gaze_data_callback, as_dictionary=False)
			#self.eyetracker.subscribe_to(tr.EYETRACKER_EXTERNAL_SIGNAL, self.external_signal_callback, as_dictionary=False)
			return True
		except:
			print('Unsuccessful attempt to begin recording!');
			return False

		
	def save(self, filename, filepath = 'cwd'):
		"""
		Writes data to filename.csv
		@param filename: str
		"""
		
		# Remove unused preallocated space
		self.timestamps = self.timestamps[:self.nsamples,:]
		self.timestamps = self.timestamps.astype(np.int64)
		self.timestamps_dev = self.timestamps_dev[:self.nsamples,:]
		self.timestamps_dev = self.timestamps_dev.astype(np.int64)
		self.recorded_data = self.recorded_data[:self.nsamples,:]
		self.triggers = self.triggers[:self.nsamples,:]
		#self.ttl = self.ttl[:self.nsamples,:]
		#self.ttl = self.ttl.astype(np.int64)
        
		# Combine into single matrix for ease of data saving
		all_data = np.concatenate((self.timestamps, self.timestamps_dev,self.recorded_data, self.triggers), axis=1)
		
		# Get default file path
		if filepath == 'cwd':
			filepath = os.getcwd()
		
		# Save file as filename.csv
		if not filename[-4:] == ".csv":
			filename = filename + ".csv"
		
		fullfile = os.path.join(filepath,filename)
		
		pd.DataFrame(all_data).to_csv(fullfile, header=["Timestamps", "Timestamps_dev", "Diameter L", "Validity L", "Diameter R", "Validity R",
                                                                "Gaze X Left", "Gaze Y Left", "Gaze Z Left", "Gaze Val Left",
                                                                "Gaze X Right", "Gaze Y Right", "Gaze Z Right", "Gaze Val Right", "Trigger"], index=None)
		print("{0} <{1}>: data saved to {2}.".format(self.eyetracker.model, self.eyetracker.device_name, fullfile))
	
	
	
	

# If run independently (i.e. testing)
if __name__ == '__main__':

	import time

	eyetracker = TobiiSpectrum()

	isConnected = eyetracker.init_eyetracker()
	if not isConnected:
		t = time.time()
		print("\nAttempting to connect to Tobii Spectrum...")
		while time.time() - t < 30:
			isConnected = eyetracker.init_eyetracker()
			if isConnected:
				break
	if isConnected:
		eyetracker.start_recording()
		print("Recording started. Collecting for 4 seconds...")
		eyetracker.send_trigger("start trigger")
		time.sleep(2)
		eyetracker.send_trigger("middle trigger")
		time.sleep(2)
		eyetracker.send_trigger("end trigger")
		eyetracker.stop_recording()
		print("Recording finished.")
		filename = 'test'
		eyetracker.save(filename)
        #time.sleep(3)
		exit(0)
	else:
		print("\nFailed to connect to eye tracker after 30 seconds of trying.")
		print("Make sure tracker is turned on and connected, then try again.")
		print("Program terminated.")
