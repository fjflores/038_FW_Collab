# DARPA-ABC
Code to analyze the DARPA-ABC experiments. 

## Dependencies
The code in this project has the following dependencies: 
- My version of the [Chronux](https://github.com/fjflores/ffChronux) toolbox
- My set of [Utilities](https://github.com/fjflores/Utilities) for neurophysiological data
This dependencies must be downloaded/cloned and added to the matlab path.

## Subdirectories
The code is separated into subdirectories named after the task the directory is intended for. The subdirectories are the following:

**Dose_effect**
: Code to process and plot presentation figures.

**Vid_processing**
: Code to process, analyze, and plot the video and behavioral tracking results

## Data structures and code in EA_dbs.
All the code is hierarchically structured, with *batch* functions calling *save* functions, which in turn call the processing functions that do the heavy lifting. The main functions for processing the electrophysiological data from DBS experiments have the *dbs* suffix. There are also helper functions that perform minor tasks, which do not have a specific suffix.

### Continuous time series and time-frequency: *ephysData*.
The raw Neuralynx data is converted into a Matlab structure called *ephysData*. The fields found in this structure are listed here and detailed below:

```
info.expID
info.subject
info.dose

eegRaw.data
eegRaw.Fs
eegRaw.ts
eegRaw.names
eegRaw.dateProcessed

eegFilt.data
eegFilt.Fs
eegFilt.ts
eegFilt.names
eegFilt.band
eegFilt.dateProcessed

eegClean.data
eegClean.Fs
eegClean.ts
eegClean.names
eegClean.detWin
eegClean.dateProcessed

spec.S
spec.f
spec.t
spec.params
spec.win
spec.names
spec.dateProcessed

coher.C
coher.t
coher.f
coher.phi
coher.confC
coher.phistd
coher.Cerr
coher.params
coher.win
coher.dateProcessed

emgRaw.data
emgRaw.Fs
emgRaw.t
emgRaw.names
emgRaw.dateProcessed

emgFilt.data
emgFilt.Fs
emgFilt.t
emgFilt.names
emgFilt.band
emgFilt.dateProcessed

events.ttlOn
events.ttlOff
events.dex.tOnline
events.dex.tOffline
events.dex.tInj
events.ati.tOnline
events.ati.tOffline
events.ati.tInj

```

The `info` structure contains characteristics of the experiment: 
- `expID` - unique experiment ID from metadata table
- `subject` - mouse ID (e.g. M094)
- `dose` - type of stim schedule (continuous or intermittent)

In the `eegRaw` structure:
- `data` - raw EEG output from Neuralynx, read by *readallcsc*
- `Fs` - sampling frequency of EEG signals
- `ts` - relative timestamp vector in seconds for all EEGs, beginning at 1/Fs
- `names` - lists names of EEG CSC channels in order, indicating that `eeg( :, 1 )` is the right frontal EEG and `eeg( :, 2 )` is the left parietal EEG

In the `eegFilt` structure:
- `data` - bandpass filtered using `eeg.filtBand` by *eegemgfilt* and is used solely for visualization

In the `eegClean` structure
- `data` - detrended using window `eeg.detWin` by *locdetrend*, with the 60 Hz artifact removed by *ffrmlinesc*; used for computing spectrograms and coherence


In the spectrogram (`spec`) and coherence (`coher`) fields (computed by *cohgramc*):
- `spec.S` - spectrogram of clean EEGs (`eeg.clean`), computed with window `spec.win` and using parameters indicated in `spec.params`
- `spec.f` - frequencies for `spec.S`
- `spec.t` - time vector for `spec.S`
- `spec.names` - see `eeg.names`
- `coher.C` - coherence between the 2 EEGs; has confidence `coher.confC` and error bars `coher.Cerr`
- `coher.phi` - phase for `coher.C`; has standard deviation `coher.phistd`

In the EMG field:
- `emg.raw` - raw EMG output from Neuralynx, read by *readallcsc*
- `emg.FsRaw` - sampling frequency of raw EMG signal
- `emg.tRaw` - relative timestamp vector in seconds for both `emg.raw` and `emg.filt`, beginning at 1/Fs
- `emg.filt` - bandpass filtered using `spec.params.filtEmg` by *eegemgfilt*
- `emg.smooth` - smoothed by *smoothemg* using the algorithm described [here](doi:10.1016/j.neuroimage.2015.06.088)
- `emg.tSmooth` - time vector created by the smoothing algorithm for `emg.smooth` 
- `emg.FsSmooth` - sampling frequency of the spectrogram of the raw EMG and thus also of `emg.smooth` 
- `emg.smoothBand` - limits for bandpass filter of EMG from which its spectrogram and then `emg.smooth` is computed
- `emg.names` - name of EMG CSC channel

In the events field (extracted from Neuralynx by *readevnlynx* and processed by *setupeventsdbs*):
- `events.tsOn` and `events.tsOff` - times at which the Neuralynx events indicating stimulation onset or offset, respectively, occured relative to `eeg.ts` time vector; only includes the timestamps for stimulation epochs to be analyzed (i.e. ignores timestamps of epochs when a seizure or other disturbance occured)
- `events.stimFreqs` and `events.stimIs` - frequencies (Hz) and currents (uA) of all the stimulation epochs to be analyzed
- `events.allTsOn` and `events.allTsOff` - same as `events.tsOn` and `events.tsOff` but includes all stimulation epochs even those that contain siezures or other disturbances

The date and time at which *ephysData* was processed is stored as `ephysData.dateProcessed`.


The code that produces *ephysData* from the raw CSC Neuralynx files has the following workflow:

```
batchprocephysdbs <- saveephysdbs <- setupephysbs <- readallcsc
                                                  <- setupeventsdbs <- readevnlynx
                                                  <- eegemgfilt
                                                  <- locdetrend
                                                  <- ffrmlinesc
                                                  <- cohgramc
                                                  <- smoothemg
```

The plotting functions that work on *ephysData* plot either the raw or clean EEG data; spectrograms and coheregrams; smoothed, raw, or filtered EMG data; and events' timestamps from a complete experiment in a single figure. They are structured as follows:

```
batchplotexpdbs <- plotexpdbs
```

### Continuous position tracking data from DLC: *vidData*.
The videos of the experiments are processed using [DeepLabCut](https://github.com/DeepLabCut/DeepLabCut) to extract the positions of different body parts. The timestamps of the LED on and off frames are extracted to synchronize the video (and therefore DLC data) to the electrophysiological recordings. The results are stored in a Matlab structure called *vidData*, and the fields in this structure are as follows:

```
vidData.expID
vidData.subject
vidData.schedType
vidData.laterality
vidData.consciousness

vidData.DLC.procDLCData
vidData.DLC.bodyparts
vidData.DLC.params
vidData.DLC.dateProcessed

vidData.events.ledFrame
vidData.events.tsOn
vidData.events.tsOff
vidData.events.stimFreqs
vidData.events.stimIs
vidData.events.allTsOn
vidData.events.allTsOff
vidData.events.dateProcessed

vidData.nFrames
vidData.vidTs
```

The first 5 fields are characteristics of the experiment, as seen above in ephysData.

In the DLC field:
- `DLC.procDLCData` - table containing raw and filtered xy coordinates and DLC's model's likelihood (read from DLC csv by *loaddlccsv*); distances between coordinates (calculated by *getdeltas*); and speed (calculated by *getspeed*) for each body part (listed in `DLC.bodyparts`) for each frame; processed using the parameters in `DLC.params` by *processdlcdata* which calls the functions listed previously as well as *medfiltdlcdata* and *removejumps*; values are converted to centimeters (cm/s for speed) by *pix2cm*
- `DLC.dateProcessed` - date and time at which the DLC data was processed 

The events field closely mirrors `ephysData.events` (see above) but differs in the following ways:
- `events.tsOn`, `events.tsOff`, `events.allTsOn`, and `events.allTsOff` - timestamps (seconds) are calculated as halfway between the timestamp of the frame at which the LED turned on (or off) and the preceding frame by *alignvidephys*; therefore, these timestamps do not exactly match the corresponding timestamps in ephysData but are within 1/fps second difference
- `ledFrame` - lists the LED on and off frames extracted from the experiment's *_led.csv* by *getledtimes*; used by *alignvidephys* to synchronize the video and electrophysiological data and to calculate the video timestamps
- `events.dateProcessed` - date and time at which the video and ephys data were aligned

The other fields:
- `nFrames` - length of the *_led.csv* (and of the video and therefore DLC data)
- `vidTs` - timestamp vector (seconds) for video frames (and thus DLC data) relative to the start of ephys timestamps, resulting from *alignvidephys*

The code that produces the *vidData.DLC* sub-structure from the DLC results uses the following workflow:

```
                            <- loaddlccsv
batchprocdlc <- saveprocdlc <- processdlcdata <- removeunlikely
                            <- pix2cm         <- medfiltdlcdata
                                              <- getdeltas
                                              <- removejumps
                                              <- getspeed
```
 The code that produces *vidData.events*, *vidData.nFrames*, and *vidData.vidTs* uses the following workflow:
 
 ```
                         <- getledtimes
batchvidts <- savevidts <- alignvidephys 
 ```

Alternatively, the entire *vidData* structure can be created in one step using `batchprocvid`.
 
### Epoched time series, frequency spectra, and continuous position tracking.
The data from *ephysData* and *vidData* is conveniently epoched into a Matlab structure named for the expID and epoch ordinal (e.g. *exp13_ep2* is experiment 13's second epoch) and saved into the mouse's .mat in the *Epochs* folder (e.g. *Results\Epochs\M094.mat*). The epoch includes date from 60 seconds before the stimulation onset through 60 seconds after the stimulation offset for continuous experiments or 60 seconds before the first stimulation onset through 60 seconds after the last 10-sec off period for intermittent experiments. The data in this base epoch structure are taken directly from *ephysData* and *vidData* with no additional processing and are stored in the the following fields:

```
epoch.freq
epoch.curr
epoch.epOrdinal
epoch.expID
epoch.subject
epoch.schedType
epoch.laterality
epoch.consciousness

epoch.tsOnEphys
epoch.tsEphys
epoch.FsEphys
epoch.eeg.clean
epoch.eeg.filt
epoch.eeg.filtBand
epoch.spec.S
epoch.spec.f
epoch.spec.t
epoch.spec.params
epoch.spec.win
epoch.coher.C
epoch.coher.Cerr
epoch.coher.confC
epoch.coher.phi
epoch.coher.phistd
epoch.emg.filt
epoch.emg.smooth
epoch.emg.FsSmooth
epoch.emg.tSmooth
epoch.emg.smoothBand
epoch.ephysDateProc

epoch.tsOnVid
epoch.dlc.procDLC
epoch.dlc.bps
epoch.dlc.params
epoch.vid.ledFrameOn
epoch.vid.ts
epoch.dlcDateProc
epoch.vidTsDateProc

epoch.epochDateProc
```

The first 8 fields are characteristics of the epoch (first 3 are specific to the epoch and next 5 are specific to the experiment from which the epoch was extracted): 
- `freq` - frequency (Hz) of stimulation
- `curr` - current (uA) of stimulation
- `epOrdinal` - ordinal of the epoch
- `expID` - unique experiment ID from metadata table
- `subject` - mouse ID (e.g. M094)
- `schedType` - type of stim schedule (continuous or intermittent)
- `laterality` - laterality of stimulation (left, right, bilateral, or macro)
- `consciousness` - state of consciousness of the mouse during the stimulation (awake, asleep\*, isoflurane, or ketamine/xylazine; \*note: check *Results\sleep_exps.xlsx* to confirm state of consciousness at stim onset for each stimulation)

The electrophysiological data fields are the same as described in *ephysData* above, with the following differences:
- `tsOnEphys` - timestamp (seconds) of stim onset (or of all stim onsets for intermittent experiments) relative to experiment onset
- `tsEphys` - timestamp vector (seconds) relative to the experiment onset; applies to all EEG data and filtered EMG data (not smoothed EMG)
- `FsEphys` - sampling frequency of raw EEG and EMG signals

The video and DLC data fields are similar to what is described in *vidData* above, but differ slightly:
- `tsOnVid` - timestamp (seconds) halfway between the timestamps of the LED on frame and the frame preceding it (or for all 6 LED on frames for intermittent experiments)
- `dlc.procDLC` - abbreviated version of `vidData.DLC.procDLCData` table, containing only the filtered xy coordinates and speed for each bodypart for each frame
- `dlc.bps` - body parts tracked by DLC (same as `vidData.DLC.bodyparts`)
- `dlc.params` - same as `vidData.DLC.params`
- `vid.ledFrameOn` - frame of LED onset for this epoch; from `vidData.events.ledFrame`
- `vid.ts` - timestamp vector (seconds) for video frames (and thus DLC data) relative to start of experiment; from `vidData.vidTs`

The date and time at which epoch structure was processed is stored as `epoch.epochDateProc`.

The code that produces this base epoch structure from *ephysData* and *vidData* has the following workflow:

```
batchprocepochs <- saveepochs <- setupepochs
```

The base epoch structure described above can be added to using *add2epoch* which takes a cell array of field values and cell array of field names and saves them into the given epoch.

Groups of epochs fitting given criteria (Frequency, Laterality, SchedType, Consciousness, and/or Mice) can be gathered using *getepochs2proc* and loaded into the workspace using *loadepochlist*. Any single epoch can be output as a variable usingg *loadepoch*.
