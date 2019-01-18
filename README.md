# Conversation Transcriber

## Setup and Run

* Change __batch_config.sh__ file according to your requirements
* Create file(files.txt) with all paths for audio
files.txt
~~~
/path/to/audio1.wav
/path/to/audio2.wav
...
~~~
* Execute:
```bash
./task1.sh files.txt 
```
* Once its done, execute:
```python
python3 pp.py
```
* The code should create two directories:
	* channels
		* l_channel : contains left channel audio
		* r_channel : contains right channel audio
	* transcribed
		* l_channel : contains left channel transcriptions with __word timings__
		* r_channel : contains right channel transcriptions with __word timings__
		* __final__ : __Conversation Transcription__

## Authors/Maintainer

* Prajwal Rao - [prajwaljpj@gmail.com](mailto:prajwaljpj@gmail.com), [prajwalrao@iisc.ac.in](mailto:prajwalrao@iisc.ac.in)
